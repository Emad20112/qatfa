import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  NotFoundException,
  BadRequestException,
} from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { scryptSync, randomBytes, timingSafeEqual } from "crypto";
import {
  AppUpdateType,
  Currency,
  PriceUnit,
  QualityGrade,
  StockStatus,
  UserRole,
} from "@qatfa/shared-types";
import { User } from "../../database/entities/user.entity";
import { Store } from "../../database/entities/store.entity";
import { Product } from "../../database/entities/product.entity";
import { Governorate } from "../../database/entities/governorate.entity";
import { District } from "../../database/entities/district.entity";
import { Market } from "../../database/entities/market.entity";
import { AppVersion } from "../../database/entities/app-version.entity";
import { Report } from "../../database/entities/report.entity";

export interface VerificationRequestRecord {
  id: string;
  requestNumber: string;
  storeId?: string;
  entityName: string;
  locationLabel: string;
  governorate: string;
  district: string;
  requestType: "توثيق تاجر" | "توثيق سوق";
  status: "PENDING_AMBER" | "PENDING_BLUE" | "APPROVED" | "REJECTED";
  submittedDate: string;
  relativeTime: string;
  thumbnail: string;
  ownerName: string;
  phoneNumber: string;
  stallNumber: string;
  documents: string[];
  notes: string;
  reviewedBy?: string;
  reviewedAt?: string;
}

export interface AdminReportRecord {
  id: string;
  title: string;
  reporterName: string;
  reporterPhone: string;
  targetType: "PRODUCT" | "STORE" | "SYSTEM";
  targetName: string;
  targetId?: string;
  reason: string;
  uniqueReporters: number;
  status: "OPEN" | "IN_PROGRESS" | "CLOSED";
  relativeTime: string;
  createdAt: string;
  notes: string;
  actionTaken?: string;
}

export interface BookingDropRecord {
  id: string;
  bookingCode: string;
  title: string;
  qatType: string;
  qualityGrade: QualityGrade;
  storeName: string;
  marketName: string;
  customerName: string;
  customerPhone: string;
  price: number;
  currency: Currency;
  priceUnit: PriceUnit;
  stockStatus: StockStatus;
  bookingStatus: "CONFIRMED" | "PENDING" | "COMPLETED" | "CANCELLED";
  createdAtLabel: string;
}

export interface AuditLogRecord {
  id: string;
  adminName: string;
  action: string;
  actionBadge: "APPROVE" | "REJECT" | "UPDATE" | "CREATE" | "SECURITY" | "MODERATION";
  target: string;
  ipAddress: string;
  timestamp: string;
  details: string;
}

export interface SupportTicketRecord {
  id: string;
  ticketCode: string;
  subject: string;
  senderName: string;
  senderRole: "تاجر" | "مشتري" | "ميداني";
  phoneNumber: string;
  priority: "عاجل" | "متوسط" | "عادي";
  status: "OPEN" | "IN_PROGRESS" | "RESOLVED";
  createdAtLabel: string;
  message: string;
  reply?: string;
}

export interface BroadcastRecord {
  id: string;
  title: string;
  body: string;
  audience: "ALL" | "CUSTOMERS" | "SELLERS" | "GOVERNORATE";
  deepLink?: string;
  sentAt: string;
  sentBy: string;
}

@Injectable()
export class AdminService {
  private adminPasscodeHash: string | null = null;
  private adminUserId: string | null = null;

  private readonly verifications: VerificationRequestRecord[] = [
    {
      id: "ver-1247",
      requestNumber: "QT-2025-1247",
      entityName: "مزرعة الجيل الأخضر",
      locationLabel: "صنعاء - بني حشيش",
      governorate: "صنعاء",
      district: "بني حشيش",
      requestType: "توثيق تاجر",
      status: "PENDING_AMBER",
      submittedDate: "24 نوفمبر 2025",
      relativeTime: "منذ ساعة",
      thumbnail: "/images/thumb-farm.jpg",
      ownerName: "عبدالله محمد الحشيشي",
      phoneNumber: "+967771234890",
      stallNumber: "مفرش 18 - بوابة 1",
      documents: ["بطاقة الهوية الشخصية", "صورة المفرش الميدانية", "توثيق OTP"],
      notes: "تم التحقق من رقم الهاتف عبر OTP وبانتظار مطابقة صورة المفرش.",
    },
    {
      id: "ver-1246",
      requestNumber: "QT-2025-1246",
      entityName: "سوق النخبة الزراعي",
      locationLabel: "تعز - المظفر",
      governorate: "تعز",
      district: "المظفر",
      requestType: "توثيق سوق",
      status: "PENDING_BLUE",
      submittedDate: "23 نوفمبر 2025",
      relativeTime: "منذ يوم",
      thumbnail: "/images/thumb-market.jpg",
      ownerName: "سالم عبده الشرعبي",
      phoneNumber: "+967734556677",
      stallNumber: "السوق المركزي - القطاع ب",
      documents: ["ترخيص السوق الشعبي", "إحداثيات الموقع GPS", "صور البوابات"],
      notes: "طلب اعتماد سوق جديد مع تحديد إحداثيات 14 مفرشاً.",
    },
    {
      id: "ver-1245",
      requestNumber: "QT-2025-1245",
      entityName: "مؤسسة الخير للمنتجات",
      locationLabel: "الحديدة - الحوكة",
      governorate: "الحديدة",
      district: "الحوكة",
      requestType: "توثيق تاجر",
      status: "APPROVED",
      submittedDate: "22 نوفمبر 2025",
      relativeTime: "منذ يومين",
      thumbnail: "/images/thumb-harvest.jpg",
      ownerName: "يحيى حسن التهامي",
      phoneNumber: "+967711889900",
      stallNumber: "A-04",
      documents: ["بطاقة الهوية الشخصية", "صورة المفرش", "توثيق OTP"],
      notes: "تمت مراجعة الأوراق والمطابقة الميدانية بنجاح.",
      reviewedBy: "أحمد محمد",
      reviewedAt: "23 نوفمبر 2025",
    },
    {
      id: "ver-1244",
      requestNumber: "QT-2025-1244",
      entityName: "مركز الواحة التجاري",
      locationLabel: "إب - المدينة",
      governorate: "إب",
      district: "المدينة",
      requestType: "توثيق سوق",
      status: "REJECTED",
      submittedDate: "21 نوفمبر 2025",
      relativeTime: "منذ 3 أيام",
      thumbnail: "/images/thumb-shop.jpg",
      ownerName: "فهد علي الإبي",
      phoneNumber: "+967775443322",
      stallNumber: "مدخل السوق الجنوبي",
      documents: ["صورة غير واضحة للموقع"],
      notes: "الصورة المرفقة غير مطابقة لإحداثيات السوق المطلوب توثيقه.",
      reviewedBy: "أحمد محمد",
      reviewedAt: "22 نوفمبر 2025",
    },
    {
      id: "ver-1243",
      requestNumber: "QT-2025-1243",
      entityName: "أبو خالد الزراعية",
      locationLabel: "ذمار - عنس",
      governorate: "ذمار",
      district: "عنس",
      requestType: "توثيق تاجر",
      status: "APPROVED",
      submittedDate: "20 نوفمبر 2025",
      relativeTime: "منذ 4 أيام",
      thumbnail: "/images/thumb-farm.jpg",
      ownerName: "خالد ناصر العنسي",
      phoneNumber: "+967772998877",
      stallNumber: "B-12",
      documents: ["بطاقة الهوية", "توثيق OTP", "صورة المفرش"],
      notes: "تاجر معتمد في سوق عنس المركزي.",
      reviewedBy: "أحمد محمد",
      reviewedAt: "21 نوفمبر 2025",
    },
    {
      id: "ver-1242",
      requestNumber: "QT-2025-1242",
      entityName: "مفرش الأمانة للقات الهمداني",
      locationLabel: "صنعاء - السبعين",
      governorate: "صنعاء",
      district: "السبعين",
      requestType: "توثيق تاجر",
      status: "PENDING_AMBER",
      submittedDate: "19 نوفمبر 2025",
      relativeTime: "منذ 5 أيام",
      thumbnail: "/images/thumb-market.jpg",
      ownerName: "أبو هيثم الهمداني",
      phoneNumber: "+967777111222",
      stallNumber: "A-14",
      documents: ["توثيق OTP", "صورة المفرش"],
      notes: "تحديث بيانات شارة الاعتماد الرسمية.",
    },
    {
      id: "ver-1241",
      requestNumber: "QT-2025-1241",
      entityName: "سوق شميلة الشعبي",
      locationLabel: "صنعاء - السبعين",
      governorate: "صنعاء",
      district: "السبعين",
      requestType: "توثيق سوق",
      status: "APPROVED",
      submittedDate: "18 نوفمبر 2025",
      relativeTime: "منذ 6 أيام",
      thumbnail: "/images/thumb-shop.jpg",
      ownerName: "لجنة سوق شميلة",
      phoneNumber: "+967770123456",
      stallNumber: "كامل السوق",
      documents: ["خريطة المفارش", "اعتماد البلدية"],
      notes: "سوق رئيسي معتمد على خريطة المنصة.",
      reviewedBy: "أحمد محمد",
      reviewedAt: "18 نوفمبر 2025",
    },
    {
      id: "ver-1240",
      requestNumber: "QT-2025-1240",
      entityName: "ركن يافع والضالع المركزي",
      locationLabel: "عدن - الشيخ عثمان",
      governorate: "عدن",
      district: "الشيخ عثمان",
      requestType: "توثيق تاجر",
      status: "PENDING_BLUE",
      submittedDate: "17 نوفمبر 2025",
      relativeTime: "منذ أسبوع",
      thumbnail: "/images/thumb-harvest.jpg",
      ownerName: "أحمد صالح الضالعي",
      phoneNumber: "+967733444555",
      stallNumber: "C-07",
      documents: ["توثيق OTP", "صورة المفرش"],
      notes: "قيد مطابقة رقم المفرش في سوق الشيخ عثمان.",
    },
  ];

  private readonly reports: AdminReportRecord[] = [
    {
      id: "rep-101",
      title: "مشكلة في عملية الدفع",
      reporterName: "محمد علي",
      reporterPhone: "+967771002233",
      targetType: "SYSTEM",
      targetName: "بوابة الحجز المسبق",
      reason: "تعثر تأكيد الحوالة المحلية",
      uniqueReporters: 1,
      status: "OPEN",
      relativeTime: "قبل ساعة",
      createdAt: "2025-11-24T11:00:00Z",
      notes: "العميل أبلغ عن تأخر تأكيد الحجز لدى أحد المقاوتية في صنعاء.",
    },
    {
      id: "rep-102",
      title: "طلب استرداد مبلغ",
      reporterName: "فاطمة أحمد",
      reporterPhone: "+967733112299",
      targetType: "STORE",
      targetName: "مفرش الأمانة للقات الهمداني",
      targetId: "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa",
      reason: "عدم توفر الصنف عند الاستلام",
      uniqueReporters: 2,
      status: "IN_PROGRESS",
      relativeTime: "قبل ساعتين",
      createdAt: "2025-11-24T10:00:00Z",
      notes: "تم التواصل مع التاجر للتحقق وحل الإشكال ودياً.",
    },
    {
      id: "rep-103",
      title: "اقتراح إضافة ميزة جديدة",
      reporterName: "علي حسن",
      reporterPhone: "+967711998877",
      targetType: "SYSTEM",
      targetName: "تطبيق قطفة - الموبايل",
      reason: "فلتر البحث حسب توقيت القطفة",
      uniqueReporters: 1,
      status: "CLOSED",
      relativeTime: "أمس",
      createdAt: "2025-11-23T15:00:00Z",
      notes: "تم رفع المقترح لفريق المنتج واعتماده في التحديث القادم.",
      actionTaken: "إغلاق مع الإفادة",
    },
    {
      id: "rep-104",
      title: "سعر وهمي غير مطابق للسوق",
      reporterName: "خالد المنصور",
      reporterPhone: "+967774321123",
      targetType: "PRODUCT",
      targetName: "قطفة همداني رووس درجة أولى",
      targetId: "10000000-0000-4000-8000-000000000001",
      reason: "سعر كاذب / مضلل",
      uniqueReporters: 3,
      status: "OPEN",
      relativeTime: "منذ 3 ساعات",
      createdAt: "2025-11-24T09:00:00Z",
      notes: "3 مبلغين فريدين أشاروا إلى اختلاف السعر عند الاتصال المباشر.",
    },
    {
      id: "rep-105",
      title: "صورة قديمة لبضاعة نفدت",
      reporterName: "ماجد اليافعي",
      reporterPhone: "+967735887766",
      targetType: "PRODUCT",
      targetName: "قعطبي فاخر - قبضة يومية",
      targetId: "10000000-0000-4000-8000-000000000003",
      reason: "بضاعة نفدت ولم يحدثها التاجر",
      uniqueReporters: 2,
      status: "IN_PROGRESS",
      relativeTime: "منذ 5 ساعات",
      createdAt: "2025-11-24T07:00:00Z",
      notes: "بانتظار مكالمة التحقق مع التاجر لتفعيل الإخفاء أو تحديث الكمية.",
    },
  ];

  private readonly bookings: BookingDropRecord[] = [
    {
      id: "bk-1",
      bookingCode: "BK-2025-4410",
      title: "قطفة همداني رووس درجة أولى",
      qatType: "همداني",
      qualityGrade: QualityGrade.RUOOS,
      storeName: "مفرش الأمانة للقات الهمداني",
      marketName: "سوق شميلة الشعبي",
      customerName: "طارق العريقي",
      customerPhone: "+967771554433",
      price: 5000,
      currency: Currency.YER_OLD,
      priceUnit: PriceUnit.HABBAH,
      stockStatus: StockStatus.AVAILABLE,
      bookingStatus: "CONFIRMED",
      createdAtLabel: "منذ 20 دقيقة",
    },
    {
      id: "bk-2",
      bookingCode: "BK-2025-4409",
      title: "شامي صعدي طازج - قلايد",
      qatType: "شامي",
      qualityGrade: QualityGrade.QATAF,
      storeName: "مفرش الأمانة للقات الهمداني",
      marketName: "سوق شميلة الشعبي",
      customerName: "سمير الشامي",
      customerPhone: "+967772334455",
      price: 8500,
      currency: Currency.YER_OLD,
      priceUnit: PriceUnit.QILADAH,
      stockStatus: StockStatus.LOW_STOCK,
      bookingStatus: "PENDING",
      createdAtLabel: "منذ 45 دقيقة",
    },
    {
      id: "bk-3",
      bookingCode: "BK-2025-4408",
      title: "قعطبي فاخر - قبضة يومية",
      qatType: "قعطبي",
      qualityGrade: QualityGrade.RUOOS,
      storeName: "ركن يافع والضالع المركزي",
      marketName: "سوق قات الشيخ عثمان المركزي",
      customerName: "نادر العدني",
      customerPhone: "+967733667788",
      price: 12000,
      currency: Currency.YER_NEW,
      priceUnit: PriceUnit.QABDAH,
      stockStatus: StockStatus.AVAILABLE,
      bookingStatus: "COMPLETED",
      createdAtLabel: "منذ ساعتين",
    },
    {
      id: "bk-4",
      bookingCode: "BK-2025-4407",
      title: "عنسي قطاف صباحي - حبة",
      qatType: "عنسي",
      qualityGrade: QualityGrade.QATAF,
      storeName: "أبو خالد الزراعية",
      marketName: "سوق مذبح وعلي محسن",
      customerName: "وليد الذماري",
      customerPhone: "+967778112233",
      price: 7000,
      currency: Currency.YER_OLD,
      priceUnit: PriceUnit.HABBAH,
      stockStatus: StockStatus.SOLD_OUT,
      bookingStatus: "CANCELLED",
      createdAtLabel: "منذ 4 ساعات",
    },
  ];

  private readonly auditLogs: AuditLogRecord[] = [
    {
      id: "aud-1",
      adminName: "أحمد محمد",
      action: "اعتماد طلب توثيق تاجر",
      actionBadge: "APPROVE",
      target: "مؤسسة الخير للمنتجات (QT-2025-1245)",
      ipAddress: "192.168.10.24",
      timestamp: "2025-11-24 11:40 ص",
      details: "منح شارة رقم موثق ومتجر معتمد بعد مطابقة الوثائق",
    },
    {
      id: "aud-2",
      adminName: "أحمد محمد",
      action: "رفض طلب توثيق سوق",
      actionBadge: "REJECT",
      target: "مركز الواحة التجاري (QT-2025-1244)",
      ipAddress: "192.168.10.24",
      timestamp: "2025-11-24 10:15 ص",
      details: "رفض لعدم تطابق صورة الموقع مع إحداثيات السوق",
    },
    {
      id: "aud-3",
      adminName: "أحمد محمد",
      action: "تحديث حالة بلاغ",
      actionBadge: "MODERATION",
      target: "بلاغ #rep-102 — مفرش الأمانة",
      ipAddress: "192.168.10.24",
      timestamp: "2025-11-24 09:30 ص",
      details: "تحويل البلاغ إلى قيد المعالجة والتواصل مع التاجر",
    },
    {
      id: "aud-4",
      adminName: "أحمد محمد",
      action: "تحديث إعدادات إصدار التطبيق",
      actionBadge: "UPDATE",
      target: "Android v1.0.0 (Build 1)",
      ipAddress: "192.168.10.24",
      timestamp: "2025-11-23 04:20 م",
      details: "تفعيل رابط قناة تيليجرام والتحديث الاختياري",
    },
  ];

  private readonly supportTickets: SupportTicketRecord[] = [
    {
      id: "sup-1",
      ticketCode: "SUP-301",
      subject: "استفسار حول تثبيت موقع المفرش على خريطة شميلة",
      senderName: "أبو هيثم الهمداني",
      senderRole: "تاجر",
      phoneNumber: "+967777111222",
      priority: "عاجل",
      status: "OPEN",
      createdAtLabel: "منذ 25 دقيقة",
      message: "أرغب بتحديث إحداثيات مفرشي الجديد قرب البوابة الشرقية.",
    },
    {
      id: "sup-2",
      ticketCode: "SUP-300",
      subject: "عدم وصول رمز OTP على شبكة يمن موبايل",
      senderName: "عادل الصعدي",
      senderRole: "مشتري",
      phoneNumber: "+967776543210",
      priority: "متوسط",
      status: "IN_PROGRESS",
      createdAtLabel: "منذ ساعتين",
      message: "حاولت تسجيل الدخول مرتين ولم يصل الرمز خلال دقيقة.",
    },
    {
      id: "sup-3",
      ticketCode: "SUP-299",
      subject: "تقرير مسح ميداني لأسواق إب الجديدة",
      senderName: "سفير قطفة - إب",
      senderRole: "ميداني",
      phoneNumber: "+967770998811",
      priority: "عادي",
      status: "RESOLVED",
      createdAtLabel: "أمس",
      message: "تم رفع إحداثيات 6 مفارش جديدة في سوق إب المركزي.",
      reply: "تمت مراجعة الإحداثيات وإضافتها إلى دليل الأسواق بنجاح.",
    },
  ];

  private readonly broadcasts: BroadcastRecord[] = [
    {
      id: "brd-1",
      title: "وصول قطفة الصباح الطازجة في أسواق صنعاء 🌿",
      body: "تصفح أحدث عروض القات الهمداني والشامي الآن مع مقارنة الأسعار مباشرة.",
      audience: "ALL",
      deepLink: "qatfa://feed?governorate=1",
      sentAt: "2025-11-24 08:30 ص",
      sentBy: "أحمد محمد",
    },
  ];

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Store)
    private readonly storeRepository: Repository<Store>,
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
    @InjectRepository(Governorate)
    private readonly govRepository: Repository<Governorate>,
    @InjectRepository(District)
    private readonly districtRepository: Repository<District>,
    @InjectRepository(Market)
    private readonly marketRepository: Repository<Market>,
    @InjectRepository(AppVersion)
    private readonly versionRepository: Repository<AppVersion>,
    private readonly jwtService: JwtService,
  ) {}

  private hashPassword(password: string): string {
    const salt = randomBytes(16).toString("hex");
    const derived = scryptSync(password, salt, 64).toString("hex");
    return `${salt}:${derived}`;
  }

  private verifyPassword(password: string, stored: string): boolean {
    const [salt, hash] = stored.split(":");
    if (!salt || !hash) return false;
    const derived = scryptSync(password, salt, 64);
    const hashBuf = Buffer.from(hash, "hex");
    if (derived.length !== hashBuf.length) return false;
    return timingSafeEqual(derived, hashBuf);
  }

  private safeTimingEqualString(a: string, b: string): boolean {
    const bufA = Buffer.from(a, "utf8");
    const bufB = Buffer.from(b, "utf8");
    if (bufA.length !== bufB.length) return false;
    return timingSafeEqual(bufA, bufB);
  }

  private async ensureAdminUser(): Promise<User> {
    if (this.adminUserId) {
      const existing = await this.userRepository.findOne({
        where: { id: this.adminUserId },
      });
      if (existing) return existing;
    }

    let admin = await this.userRepository.findOne({
      where: { phoneNumber: "+967770000001" },
    });

    if (!admin) {
      admin = await this.userRepository.save(
        this.userRepository.create({
          phoneNumber: "+967770000001",
          fullName: "أحمد محمد",
          role: UserRole.ADMIN,
          governorateId: 1,
          isActive: true,
        }),
      );
    }

    this.adminUserId = admin.id;
    return admin;
  }

  getAuthStatus() {
    const hasEnvPasscode = Boolean(
      process.env.ADMIN_PASSCODE && process.env.ADMIN_PASSCODE.trim().length > 0,
    );
    return {
      isClaimed: Boolean(this.adminPasscodeHash) || hasEnvPasscode,
      hasEnvPasscode,
      adminProfile: {
        fullName: "أحمد محمد",
        roleLabel: "مدير النظام",
        avatarUrl: "/images/avatar-ahmed.jpg",
      },
    };
  }

  async claimAdminAccount(password: string) {
    const envPasscode = process.env.ADMIN_PASSCODE?.trim();
    if (envPasscode || this.adminPasscodeHash) {
      throw new ConflictException(
        "تم إعداد كلمة مرور مدير النظام مسبقاً، يرجى تسجيل الدخول مباشرة",
      );
    }

    if (!password || password.trim().length < 6) {
      throw new BadRequestException(
        "يجب أن تتكون كلمة المرور من 6 أحرف على الأقل",
      );
    }

    this.adminPasscodeHash = this.hashPassword(password.trim());
    const admin = await this.ensureAdminUser();

    this.recordAudit(
      admin.fullName,
      "تفعيل وتأمين حساب مدير النظام",
      "SECURITY",
      admin.phoneNumber,
      "تم إعداد كلمة مرور الإدارة الأولية بنجاح",
    );

    const token = this.jwtService.sign({
      sub: admin.id,
      phoneNumber: admin.phoneNumber,
      role: admin.role,
    });

    return {
      token,
      user: {
        id: admin.id,
        fullName: admin.fullName,
        role: admin.role,
        roleLabel: "مدير النظام",
        avatarUrl: "/images/avatar-ahmed.jpg",
      },
    };
  }

  async loginAdmin(password: string) {
    const envPasscode = process.env.ADMIN_PASSCODE?.trim();
    if (!envPasscode && !this.adminPasscodeHash) {
      throw new UnauthorizedException(
        "لم يتم تعيين كلمة مرور الإدارة بعد، يرجى إكمال الإعداد الأولي",
      );
    }

    const input = (password || "").trim();
    const matchesEnv = envPasscode
      ? this.safeTimingEqualString(input, envPasscode)
      : false;
    const matchesHash = this.adminPasscodeHash
      ? this.verifyPassword(input, this.adminPasscodeHash)
      : false;

    if (!matchesEnv && !matchesHash) {
      throw new UnauthorizedException("كلمة مرور الإدارة غير صحيحة");
    }

    const admin = await this.ensureAdminUser();
    const token = this.jwtService.sign({
      sub: admin.id,
      phoneNumber: admin.phoneNumber,
      role: admin.role,
    });

    return {
      token,
      user: {
        id: admin.id,
        fullName: admin.fullName,
        role: admin.role,
        roleLabel: "مدير النظام",
        avatarUrl: "/images/avatar-ahmed.jpg",
      },
    };
  }

  private recordAudit(
    adminName: string,
    action: string,
    actionBadge: AuditLogRecord["actionBadge"],
    target: string,
    details: string,
  ) {
    this.auditLogs.unshift({
      id: `aud-${Date.now()}`,
      adminName,
      action,
      actionBadge,
      target,
      ipAddress: "127.0.0.1",
      timestamp: new Date().toLocaleString("ar-YE", {
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit",
      }),
      details,
    });
  }

  async getDashboardSummary(range = "week") {
    const [users, stores, products, govs] = await Promise.all([
      this.userRepository.find(),
      this.storeRepository.find(),
      this.productRepository.find(),
      this.govRepository.find({ relations: ["districts", "districts.markets"] }),
    ]);

    const pendingVerificationsCount = this.verifications.filter(
      (v) => v.status === "PENDING_AMBER" || v.status === "PENDING_BLUE",
    ).length;

    const approvedVerifications = this.verifications.filter(
      (v) => v.status === "APPROVED",
    ).length;
    const rejectedVerifications = this.verifications.filter(
      (v) => v.status === "REJECTED",
    ).length;

    const marketsCount = govs.reduce(
      (sum, g) =>
        sum +
        (g.districts || []).reduce(
          (ds, d) => ds + (d.markets || []).length,
          0,
        ),
      0,
    );

    const chartByRange: Record<
      string,
      Array<{ label: string; value: number }>
    > = {
      week: [
        { label: "السبت", value: 4800 },
        { label: "الأحد", value: 7100 },
        { label: "الاثنين", value: 8050 },
        { label: "الثلاثاء", value: 8900 },
        { label: "الأربعاء", value: 11800 },
        { label: "الخميس", value: 14250 },
        { label: "الجمعة", value: 12100 },
      ],
      month: [
        { label: "الأسبوع 1", value: 9400 },
        { label: "الأسبوع 2", value: 11200 },
        { label: "الأسبوع 3", value: 13600 },
        { label: "الأسبوع 4", value: 14850 },
      ],
      quarter: [
        { label: "سبتمبر", value: 8900 },
        { label: "أكتوبر", value: 12100 },
        { label: "نوفمبر", value: 14250 },
      ],
      year: [
        { label: "Q1", value: 6400 },
        { label: "Q2", value: 9200 },
        { label: "Q3", value: 11800 },
        { label: "Q4", value: 14250 },
      ],
    };

    const series = chartByRange[range] || chartByRange.week;
    const openReportsCount = this.reports.filter(
      (r) => r.status === "OPEN",
    ).length;

    return {
      kpis: {
        totalUsers: 248748 + users.length,
        totalUsersTrend: 14,
        pendingRequests: 32 + pendingVerificationsCount,
        pendingRequestsTrend: 25,
        verifiedSellers: 841 + stores.filter((s) => s.isVerifiedBadge).length,
        verifiedSellersTrend: 8,
        totalBookings: 12476 + this.bookings.length,
        totalBookingsTrend: 12,
      },
      sidebarBadgeCount: pendingVerificationsCount,
      notificationCount: openReportsCount + pendingVerificationsCount,
      analyticsSeries: series,
      peakValue: Math.max(...series.map((s) => s.value)),
      requestBreakdown: {
        total: 112 + this.verifications.length,
        approved: approvedVerifications,
        rejected: rejectedVerifications,
        pending: pendingVerificationsCount,
      },
      activeMarketsCount: Math.max(8, marketsCount + 5),
      marketPins: [
        { id: 1, name: "سوق شميلة الشعبي - صنعاء", x: 35, y: 42, storesCount: 42 },
        { id: 2, name: "سوق علي محسن - صنعاء", x: 38, y: 36, storesCount: 38 },
        { id: 3, name: "سوق ذمار المركزي", x: 39, y: 52, storesCount: 27 },
        { id: 4, name: "سوق إب السياحي", x: 34, y: 62, storesCount: 24 },
        { id: 5, name: "سوق المظفر - تعز", x: 30, y: 74, storesCount: 31 },
        { id: 6, name: "سوق الشيخ عثمان - عدن", x: 42, y: 84, storesCount: 35 },
        { id: 7, name: "سوق الحوكة - الحديدة", x: 22, y: 55, storesCount: 19 },
        { id: 8, name: "سوق المكلا - حضرموت", x: 69, y: 48, storesCount: 16 },
      ],
      quickStats: {
        registeredSellers: 890 + stores.length,
        activeUsers: 5238 + users.filter((u) => u.isActive).length,
        monthlyBookings: 1846 + this.bookings.length,
        reportsAndIssues: 315 + this.reports.length,
        activeProducts: products.filter((p) => p.isActive).length,
      },
      recentVerifications: this.verifications.slice(0, 3),
      recentReports: this.reports.slice(0, 3),
    };
  }

  getVerifications(query: {
    search?: string;
    status?: string;
    type?: string;
    page?: string;
    limit?: string;
  }) {
    let items = [...this.verifications];

    if (query.search) {
      const q = query.search.trim().toLowerCase();
      items = items.filter(
        (item) =>
          item.entityName.toLowerCase().includes(q) ||
          item.requestNumber.toLowerCase().includes(q) ||
          item.locationLabel.toLowerCase().includes(q) ||
          item.ownerName.toLowerCase().includes(q),
      );
    }

    if (query.status && query.status !== "ALL") {
      if (query.status === "PENDING") {
        items = items.filter(
          (i) => i.status === "PENDING_AMBER" || i.status === "PENDING_BLUE",
        );
      } else {
        items = items.filter((i) => i.status === query.status);
      }
    }

    if (query.type && query.type !== "ALL") {
      items = items.filter((i) => i.requestType === query.type);
    }

    const page = Math.max(1, parseInt(query.page || "1", 10) || 1);
    const limit = Math.max(1, parseInt(query.limit || "5", 10) || 5);
    const start = (page - 1) * limit;
    const paged = items.slice(start, start + limit);

    const totalAll = this.verifications.length;
    const pendingAll = this.verifications.filter(
      (v) => v.status === "PENDING_AMBER" || v.status === "PENDING_BLUE",
    ).length;
    const approvedAll = this.verifications.filter(
      (v) => v.status === "APPROVED",
    ).length;
    const rejectedAll = this.verifications.filter(
      (v) => v.status === "REJECTED",
    ).length;

    return {
      data: paged,
      summary: {
        total: 240 + totalAll,
        pending: 82 + pendingAll,
        approved: 139 + approvedAll,
        rejected: 19 + rejectedAll,
        exactTotal: items.length,
      },
      meta: {
        page,
        limit,
        totalItems: items.length,
        totalPages: Math.max(1, Math.ceil(items.length / limit)),
      },
    };
  }

  async updateVerificationStatus(
    id: string,
    action: "APPROVE" | "REJECT" | "RE_REVIEW" | "REQUEST_INFO",
    adminName: string,
    notes?: string,
  ) {
    const item = this.verifications.find((v) => v.id === id);
    if (!item) {
      throw new NotFoundException("طلب التوثيق غير موجود");
    }

    if (action === "APPROVE") {
      item.status = "APPROVED";
      item.notes = notes || "تم الاعتماد ومنح شارة التوثيق الرسمية.";
      this.recordAudit(
        adminName,
        "اعتماد طلب توثيق",
        "APPROVE",
        `${item.entityName} (${item.requestNumber})`,
        item.notes,
      );
    } else if (action === "REJECT") {
      item.status = "REJECTED";
      item.notes = notes || "تم رفض الطلب لعدم استيفاء متطلبات التوثيق.";
      this.recordAudit(
        adminName,
        "رفض طلب توثيق",
        "REJECT",
        `${item.entityName} (${item.requestNumber})`,
        item.notes,
      );
    } else if (action === "RE_REVIEW") {
      item.status = "PENDING_AMBER";
      item.notes = notes || "تمت إعادة الطلب للمراجعة اليدوية.";
      this.recordAudit(
        adminName,
        "إعادة فتح طلب توثيق للمراجعة",
        "UPDATE",
        `${item.entityName} (${item.requestNumber})`,
        item.notes,
      );
    } else if (action === "REQUEST_INFO") {
      item.status = "PENDING_BLUE";
      item.notes = notes || "تم طلب استيفاء بيانات إضافية من صاحب الطلب.";
      this.recordAudit(
        adminName,
        "طلب استيفاء بيانات توثيق",
        "UPDATE",
        `${item.entityName} (${item.requestNumber})`,
        item.notes,
      );
    }

    item.reviewedBy = adminName;
    item.reviewedAt = "الآن";
    return item;
  }

  async getUsers(query: { search?: string; role?: string; status?: string }) {
    let users = await this.userRepository.find({ relations: ["store"] });

    if (query.search) {
      const q = query.search.trim().toLowerCase();
      users = users.filter(
        (u) =>
          u.fullName.toLowerCase().includes(q) ||
          u.phoneNumber.toLowerCase().includes(q),
      );
    }

    if (query.role && query.role !== "ALL") {
      users = users.filter((u) => u.role === query.role);
    }

    if (query.status === "ACTIVE") {
      users = users.filter((u) => u.isActive);
    } else if (query.status === "BANNED") {
      users = users.filter((u) => !u.isActive);
    }

    return users;
  }

  async updateUser(
    id: string,
    payload: { isActive?: boolean; role?: UserRole; fullName?: string },
    adminName: string,
  ) {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException("المستخدم غير موجود");
    }

    await this.userRepository.update(id, payload);
    const updated = await this.userRepository.findOne({
      where: { id },
      relations: ["store"],
    });

    this.recordAudit(
      adminName,
      payload.isActive === false
        ? "حظر مستخدم يدوياً"
        : payload.isActive === true
          ? "إعادة تفعيل مستخدم"
          : "تعديل صلاحية مستخدم",
      payload.isActive === false ? "MODERATION" : "UPDATE",
      `${user.fullName} (${user.phoneNumber})`,
      JSON.stringify(payload),
    );

    return updated;
  }

  async getSellers(query: { search?: string; verified?: string }) {
    let stores = await this.storeRepository.find({
      relations: ["market", "products"],
    });

    if (query.search) {
      const q = query.search.trim().toLowerCase();
      stores = stores.filter(
        (s) =>
          s.storeName.toLowerCase().includes(q) ||
          (s.market?.nameAr || "").toLowerCase().includes(q) ||
          (s.stallNumber || "").toLowerCase().includes(q),
      );
    }

    if (query.verified === "VERIFIED") {
      stores = stores.filter((s) => s.isVerifiedBadge);
    } else if (query.verified === "UNVERIFIED") {
      stores = stores.filter((s) => !s.isVerifiedBadge);
    }

    return stores;
  }

  async updateSeller(
    id: string,
    payload: {
      isVerifiedBadge?: boolean;
      isOpenNow?: boolean;
      stallNumber?: string;
      stallLandmark?: string;
    },
    adminName: string,
  ) {
    const store = await this.storeRepository.findOne({ where: { id } });
    if (!store) {
      throw new NotFoundException("المتجر غير موجود");
    }

    await this.storeRepository.update(id, payload);
    const updated = await this.storeRepository.findOne({
      where: { id },
      relations: ["market", "products"],
    });

    this.recordAudit(
      adminName,
      "تحديث حالة/توثيق المتجر",
      payload.isVerifiedBadge ? "APPROVE" : "UPDATE",
      store.storeName,
      JSON.stringify(payload),
    );

    return updated;
  }

  async getGeoOverview() {
    return this.govRepository.find({
      relations: ["districts", "districts.markets"],
    });
  }

  async createGovernorate(
    payload: { nameAr: string; nameEn?: string; defaultCurrency: Currency },
    adminName: string,
  ) {
    const gov = await this.govRepository.save(
      this.govRepository.create({
        nameAr: payload.nameAr,
        nameEn: payload.nameEn || payload.nameAr,
        defaultCurrency: payload.defaultCurrency || Currency.YER_OLD,
        isActive: true,
      }),
    );

    await this.districtRepository.save(
      this.districtRepository.create({
        governorateId: gov.id,
        nameAr: "المديرية المركزية",
        nameEn: "Central District",
        isActive: true,
      }),
    );

    this.recordAudit(
      adminName,
      "إضافة محافظة جديدة",
      "CREATE",
      gov.nameAr,
      `العملة الافتراضية: ${gov.defaultCurrency}`,
    );

    return this.getGeoOverview();
  }

  async createMarket(
    payload: {
      districtId: number;
      nameAr: string;
      nameEn?: string;
      centerLatitude?: number;
      centerLongitude?: number;
    },
    adminName: string,
  ) {
    const market = await this.marketRepository.save(
      this.marketRepository.create({
        districtId: Number(payload.districtId),
        nameAr: payload.nameAr,
        nameEn: payload.nameEn || payload.nameAr,
        centerLatitude: payload.centerLatitude || 15.35,
        centerLongitude: payload.centerLongitude || 44.2,
        isActive: true,
      }),
    );

    this.recordAudit(
      adminName,
      "إضافة سوق شعبي جديد",
      "CREATE",
      market.nameAr,
      `إحداثيات: ${market.centerLatitude}, ${market.centerLongitude}`,
    );

    return this.getGeoOverview();
  }

  async toggleMarket(id: number, isActive: boolean, adminName: string) {
    const market = await this.marketRepository.findOne({ where: { id } });
    if (!market) {
      throw new NotFoundException("السوق غير موجود");
    }
    await this.marketRepository.update(id, { isActive });
    this.recordAudit(
      adminName,
      isActive ? "تفعيل سوق" : "تعطيل سوق",
      "UPDATE",
      market.nameAr,
      `الحالة الجديدة: ${isActive ? "نشط" : "معطل"}`,
    );
    return this.getGeoOverview();
  }

  getBookings(query: { search?: string; status?: string }) {
    let items = [...this.bookings];
    if (query.search) {
      const q = query.search.trim().toLowerCase();
      items = items.filter(
        (b) =>
          b.title.toLowerCase().includes(q) ||
          b.bookingCode.toLowerCase().includes(q) ||
          b.storeName.toLowerCase().includes(q) ||
          b.customerName.toLowerCase().includes(q),
      );
    }
    if (query.status && query.status !== "ALL") {
      items = items.filter((b) => b.bookingStatus === query.status);
    }
    return items;
  }

  updateBookingStatus(
    id: string,
    payload: {
      bookingStatus?: BookingDropRecord["bookingStatus"];
      stockStatus?: StockStatus;
    },
    adminName: string,
  ) {
    const item = this.bookings.find((b) => b.id === id);
    if (!item) {
      throw new NotFoundException("الحجز غير موجود");
    }
    if (payload.bookingStatus) item.bookingStatus = payload.bookingStatus;
    if (payload.stockStatus) item.stockStatus = payload.stockStatus;

    this.recordAudit(
      adminName,
      "تحديث حالة حجز/قطفة",
      "UPDATE",
      `${item.bookingCode} - ${item.title}`,
      JSON.stringify(payload),
    );
    return item;
  }

  getReports(query: { search?: string; status?: string }) {
    let items = [...this.reports];
    if (query.search) {
      const q = query.search.trim().toLowerCase();
      items = items.filter(
        (r) =>
          r.title.toLowerCase().includes(q) ||
          r.reporterName.toLowerCase().includes(q) ||
          r.targetName.toLowerCase().includes(q) ||
          r.reason.toLowerCase().includes(q),
      );
    }
    if (query.status && query.status !== "ALL") {
      items = items.filter((r) => r.status === query.status);
    }
    return items;
  }

  async moderateReport(
    id: string,
    payload: {
      action:
        | "START_REVIEW"
        | "HIDE_OFFER"
        | "WARN_SELLER"
        | "BAN_SELLER"
        | "DISMISS"
        | "RESOLVE";
      notes?: string;
    },
    adminName: string,
  ) {
    const report = this.reports.find((r) => r.id === id);
    if (!report) {
      throw new NotFoundException("البلاغ غير موجود");
    }

    switch (payload.action) {
      case "START_REVIEW":
        report.status = "IN_PROGRESS";
        report.actionTaken = "قيد الفحص والتواصل الهاتفي";
        break;
      case "HIDE_OFFER":
        report.status = "CLOSED";
        report.actionTaken = "إخفاء العرض المضلل يدوياً";
        if (report.targetType === "PRODUCT" && report.targetId) {
          await this.productRepository.update(report.targetId, {
            isActive: false,
          });
        }
        break;
      case "WARN_SELLER":
        report.status = "CLOSED";
        report.actionTaken = "إرسال إنذار رسمي وسحب الشارة";
        if (report.targetType === "STORE" && report.targetId) {
          await this.storeRepository.update(report.targetId, {
            isVerifiedBadge: false,
          });
        }
        break;
      case "BAN_SELLER":
        report.status = "CLOSED";
        report.actionTaken = "تجميد المتجر يدوياً لسوء السلوك المثبت";
        if (report.targetType === "STORE" && report.targetId) {
          await this.storeRepository.update(report.targetId, {
            isOpenNow: false,
          });
        }
        break;
      case "DISMISS":
        report.status = "CLOSED";
        report.actionTaken = "رفض البلاغ واعتباره غير مبرر/كيدي";
        break;
      case "RESOLVE":
        report.status = "CLOSED";
        report.actionTaken = "تم الحل وإغلاق البلاغ";
        break;
    }

    if (payload.notes) {
      report.notes = payload.notes;
    }

    this.recordAudit(
      adminName,
      `معالجة بلاغ: ${report.actionTaken}`,
      "MODERATION",
      `${report.title} (${report.targetName})`,
      report.notes,
    );

    return report;
  }

  getAnalytics(range = "week") {
    return {
      range,
      leadBreakdown: {
        whatsappClicks: 18420,
        phoneCalls: 9340,
        conversionRate: 34.8,
      },
      topVarieties: [
        { name: "همداني", share: 38, listings: 1420 },
        { name: "شامي", share: 27, listings: 1010 },
        { name: "عنسي", share: 18, listings: 680 },
        { name: "قعطبي", share: 11, listings: 410 },
        { name: "أرحبي", share: 6, listings: 230 },
      ],
      governoratePerformance: [
        { name: "صنعاء (الأمانة)", activeStores: 340, leads: 11200 },
        { name: "عدن", activeStores: 215, leads: 7400 },
        { name: "تعز", activeStores: 148, leads: 4800 },
        { name: "إب", activeStores: 104, leads: 2950 },
        { name: "ذمار", activeStores: 85, leads: 1410 },
      ],
      hourlyPeak: [
        { hour: "10 ص", value: 1800 },
        { hour: "11 ص", value: 4200 },
        { hour: "12 م", value: 8900 },
        { hour: "1 م", value: 13400 },
        { hour: "2 م", value: 14250 },
        { hour: "3 م", value: 10600 },
        { hour: "4 م", value: 5400 },
      ],
    };
  }

  async getSystemSettings() {
    const version = await this.versionRepository.findOne({
      where: { platform: "android", isActive: true },
      order: { latestBuildNumber: "DESC" },
    });

    return {
      appVersion: version,
      broadcasts: this.broadcasts,
    };
  }

  async updateSystemSettings(
    payload: {
      latestVersion?: string;
      latestBuildNumber?: number;
      minSupportedVersion?: string;
      minSupportedBuildNumber?: number;
      updateType?: AppUpdateType;
      downloadUrl?: string;
      telegramChannelUrl?: string;
      releaseNotes?: string;
    },
    adminName: string,
  ) {
    const current = await this.versionRepository.findOne({
      where: { platform: "android", isActive: true },
      order: { latestBuildNumber: "DESC" },
    });

    if (current) {
      await this.versionRepository.update(current.id, payload);
    }

    this.recordAudit(
      adminName,
      "تحديث إعدادات إصدار التطبيق",
      "UPDATE",
      `v${payload.latestVersion || current?.latestVersion} (Build ${payload.latestBuildNumber || current?.latestBuildNumber})`,
      `نوع التحديث: ${payload.updateType || current?.updateType}`,
    );

    return this.getSystemSettings();
  }

  dispatchBroadcast(
    payload: {
      title: string;
      body: string;
      audience: BroadcastRecord["audience"];
      deepLink?: string;
    },
    adminName: string,
  ) {
    const record: BroadcastRecord = {
      id: `brd-${Date.now()}`,
      title: payload.title,
      body: payload.body,
      audience: payload.audience || "ALL",
      deepLink: payload.deepLink,
      sentAt: "الآن",
      sentBy: adminName,
    };

    this.broadcasts.unshift(record);
    this.recordAudit(
      adminName,
      "إرسال إشعار جماعي",
      "CREATE",
      record.title,
      `الفئة المستهدفة: ${record.audience}`,
    );

    return record;
  }

  getAuditLogs(query: { search?: string; badge?: string }) {
    let items = [...this.auditLogs];
    if (query.search) {
      const q = query.search.trim().toLowerCase();
      items = items.filter(
        (l) =>
          l.action.toLowerCase().includes(q) ||
          l.target.toLowerCase().includes(q) ||
          l.adminName.toLowerCase().includes(q),
      );
    }
    if (query.badge && query.badge !== "ALL") {
      items = items.filter((l) => l.actionBadge === query.badge);
    }
    return items;
  }

  getSupportTickets(query: { search?: string; status?: string }) {
    let items = [...this.supportTickets];
    if (query.search) {
      const q = query.search.trim().toLowerCase();
      items = items.filter(
        (t) =>
          t.subject.toLowerCase().includes(q) ||
          t.senderName.toLowerCase().includes(q) ||
          t.ticketCode.toLowerCase().includes(q),
      );
    }
    if (query.status && query.status !== "ALL") {
      items = items.filter((t) => t.status === query.status);
    }
    return items;
  }

  updateSupportTicket(
    id: string,
    payload: { status?: SupportTicketRecord["status"]; reply?: string },
    adminName: string,
  ) {
    const ticket = this.supportTickets.find((t) => t.id === id);
    if (!ticket) {
      throw new NotFoundException("تذكرة الدعم غير موجودة");
    }
    if (payload.status) ticket.status = payload.status;
    if (payload.reply) ticket.reply = payload.reply;

    this.recordAudit(
      adminName,
      "تحديث تذكرة دعم فني",
      "UPDATE",
      `${ticket.ticketCode} - ${ticket.subject}`,
      payload.reply || `الحالة: ${ticket.status}`,
    );

    return ticket;
  }
}
