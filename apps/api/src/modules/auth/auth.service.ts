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

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  // مخزن ذاكرة مؤقت لرموز الـ OTP لأغراض التطوير والاختبار
  private readonly otpCache = new Map<
    string,
    { code: string; expiresAt: number }
  >();

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly jwtService: JwtService,
  ) {}

  async requestOtp(
    phoneNumber: string,
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

    // توليد رمز OTP مكون من 6 أرقام (في بيئة التطوير نستخدم 123456 كافتراضي)
    const otpCode =
      process.env.NODE_ENV === "production"
        ? Math.floor(100000 + Math.random() * 900000).toString()
        : "123456";

    const expiresAt = Date.now() + 5 * 60 * 1000; // 5 دقائق صلاحية
    this.otpCache.set(cleanPhone, { code: otpCode, expiresAt });

    this.logger.log(`تم توليد رمز OTP للرقم ${cleanPhone}: [${otpCode}]`);

    return {
      retryAfterSeconds: 60,
      demoOtp: process.env.NODE_ENV !== "production" ? otpCode : undefined,
    };
  }

  async verifyOtp(
    phoneNumber: string,
    code: string,
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
      if (!cached || cached.expiresAt < Date.now() || cached.code !== code) {
        throw new UnauthorizedException("رمز التحقق غير صحيح أو انتهت صلاحيته");
      }
    }

    this.otpCache.delete(cleanPhone);

    // البحث عن المستخدم أو إنشاؤه تلقائياً
    let user = await this.userRepository.findOne({
      where: { phoneNumber: cleanPhone },
      relations: ["store"],
    });

    let isNewUser = false;
    if (!user) {
      isNewUser = true;
      user = this.userRepository.create({
        phoneNumber: cleanPhone,
        fullName: "مستخدم قطفة",
        role: UserRole.CUSTOMER,
        isActive: true,
      });
      user = await this.userRepository.save(user);
    }

    const token = this.jwtService.sign({
      sub: user.id,
      phoneNumber: user.phoneNumber,
      role: user.role,
    });

    return {
      token,
      user,
      isNewUser,
    };
  }
}
