import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
  Logger,
} from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { User } from "../../database/entities/user.entity";
import { UserRole } from "@qatfa/shared-types";

export interface OtpLogEntry {
  id: string;
  phoneNumber: string;
  fullName?: string;
  code: string;
  createdAt: string;
  expiresAt: string;
  isUsed: boolean;
  status: "ACTIVE" | "EXPIRED" | "USED";
}

interface CachedOtp {
  code: string;
  fullName?: string;
  expiresAt: number;
  lastRequestedAt: number;
  failedAttempts: number;
}

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  // مخزن ذاكرة مؤقت لرموز الـ OTP مع تتبع المحاولات ومعدل الطلب
  private readonly otpCache = new Map<string, CachedOtp>();

  // سجل مركزي لرموز الـ OTP يتاح للوحة التحكم لمتابعة وتجربة رموز الدخول
  private readonly otpLogs: OtpLogEntry[] = [];

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly jwtService: JwtService,
  ) {}

  /**
   * طلب رمز تحقق OTP وإرساله لسجل لوحة التحكم
   */
  async requestOtp(
    phoneNumber: string,
    fullName?: string,
  ): Promise<{ retryAfterSeconds: number; demoOtp?: string }> {
    // تنسيق وتوحيد رقم الهاتف بالصيغة الدولية اليمنية +967
    let cleanPhone = phoneNumber.replace(/\s+/g, "");
    if (!cleanPhone.startsWith("+")) {
      if (cleanPhone.startsWith("967")) {
        cleanPhone = "+" + cleanPhone;
      } else {
        cleanPhone = "+967" + cleanPhone;
      }
    }

    const now = Date.now();
    const existing = this.otpCache.get(cleanPhone);

    // حماية معدل الطلب: منع تكرار الطلب خلال أقل من 25 ثانية
    if (existing && now - existing.lastRequestedAt < 25 * 1000) {
      const waitRemaining = Math.ceil(
        (25 * 1000 - (now - existing.lastRequestedAt)) / 1000,
      );
      throw new BadRequestException(
        `يرجى الانتظار ${waitRemaining} ثانية قبل إعادة إرسال رمز التحقق`,
      );
    }

    // توليد رمز OTP مكون من 6 أرقام عشوائية
    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAtMs = now + 5 * 60 * 1000; // صلاحية 5 دقائق

    this.otpCache.set(cleanPhone, {
      code: otpCode,
      fullName: fullName?.trim() || existing?.fullName,
      expiresAt: expiresAtMs,
      lastRequestedAt: now,
      failedAttempts: 0,
    });

    // تسجيل الرمز في سجل لوحة التحكم الإدارية
    const logEntry: OtpLogEntry = {
      id: "otp_" + Date.now() + "_" + Math.floor(Math.random() * 1000),
      phoneNumber: cleanPhone,
      fullName: fullName?.trim() || existing?.fullName || "مستخدم جديد",
      code: otpCode,
      createdAt: new Date(now).toISOString(),
      expiresAt: new Date(expiresAtMs).toISOString(),
      isUsed: false,
      status: "ACTIVE",
    };

    // إدراج الرمز في بداية القائمة والاحتفاظ بآخر 100 رمز
    this.otpLogs.unshift(logEntry);
    if (this.otpLogs.length > 100) {
      this.otpLogs.pop();
    }

    this.logger.log(
      `تم توليد رمز OTP للرقم ${cleanPhone} (${fullName || "غير محدد"}): [${otpCode}] ومشاركته مع لوحة التحكم`,
    );

    return {
      retryAfterSeconds: 60,
      demoOtp: process.env.NODE_ENV !== "production" ? otpCode : undefined,
    };
  }

  /**
   * التحقق من رمز الـ OTP وتسجيل الدخول / إنشاء الحساب
   */
  async verifyOtp(
    phoneNumber: string,
    code: string,
    fullName?: string,
  ): Promise<{ token: string; user: User; isNewUser: boolean }> {
    let cleanPhone = phoneNumber.replace(/\s+/g, "");
    if (!cleanPhone.startsWith("+")) {
      if (cleanPhone.startsWith("967")) {
        cleanPhone = "+" + cleanPhone;
      } else {
        cleanPhone = "+967" + cleanPhone;
      }
    }

    const cached = this.otpCache.get(cleanPhone);
    const isValidTestCode =
      process.env.NODE_ENV !== "production" && code === "123456";

    if (!isValidTestCode) {
      if (!cached) {
        throw new UnauthorizedException("لم يتم طلب رمز تحقق لهذا الرقم أو انتهت صلاحيته");
      }

      if (cached.expiresAt < Date.now()) {
        this.otpCache.delete(cleanPhone);
        throw new UnauthorizedException("انتهت صلاحية رمز التحقق (أكثر من 5 دقائق)");
      }

      if (cached.code !== code) {
        cached.failedAttempts += 1;
        if (cached.failedAttempts >= 5) {
          this.otpCache.delete(cleanPhone);
          throw new UnauthorizedException(
            "تم تجاوز عدد المحاولات الخاطئة المسموح بها، يرجى طلب رمز جديد",
          );
        }
        throw new UnauthorizedException("رمز التحقق غير صحيح، يرجى إعادة المحاولة");
      }
    }

    // تم التحقق بنجاح: استهلاك الرمز لمرة واحدة
    this.otpCache.delete(cleanPhone);

    // تحديث حالة السجل في لوحة التحكم الإدارية
    const matchedLog = this.otpLogs.find(
      (l) => l.phoneNumber === cleanPhone && !l.isUsed,
    );
    if (matchedLog) {
      matchedLog.isUsed = true;
      matchedLog.status = "USED";
    }

    // البحث عن المستخدم أو إنشاؤه
    let user = await this.userRepository.findOne({
      where: { phoneNumber: cleanPhone },
      relations: ["store"],
    });

    let isNewUser = false;
    const resolvedName =
      fullName?.trim() || cached?.fullName?.trim() || "مستخدم قطفة";

    if (!user) {
      isNewUser = true;
      user = this.userRepository.create({
        phoneNumber: cleanPhone,
        fullName: resolvedName,
        role: UserRole.CUSTOMER,
        isActive: true,
      });
      user = await this.userRepository.save(user);
    } else if (
      fullName?.trim() &&
      (user.fullName === "مستخدم قطفة" || !user.fullName)
    ) {
      user.fullName = fullName.trim();
      user = await this.userRepository.save(user);
    }

    const token = this.jwtService.sign({
      sub: user.id,
      phoneNumber: user.phoneNumber,
      fullName: user.fullName,
      role: user.role,
    });

    return {
      token,
      user,
      isNewUser,
    };
  }

  /**
   * جلب سجل رموز التحقق للمشرفين في لوحة التحكم
   */
  getOtpLogs(): OtpLogEntry[] {
    const now = Date.now();
    return this.otpLogs.map((log) => {
      const isExpired = new Date(log.expiresAt).getTime() < now;
      let status: "ACTIVE" | "EXPIRED" | "USED" = "ACTIVE";
      if (log.isUsed) {
        status = "USED";
      } else if (isExpired) {
        status = "EXPIRED";
      }
      return {
        ...log,
        status,
      };
    });
  }

  /**
   * جلب بيانات الملف الشخصي للمستخدم الحالي
   */
  async getMe(userId: string): Promise<User> {
    const user = await this.userRepository.findOne({
      where: { id: userId },
      relations: ["store"],
    });
    if (!user) {
      throw new UnauthorizedException("المستخدم غير موجود");
    }
    return user;
  }
}
