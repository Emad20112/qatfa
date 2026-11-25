// أدوار المستخدمين
export enum UserRole {
  GUEST = "GUEST",
  CUSTOMER = "CUSTOMER",
  SELLER = "SELLER",
  MODERATOR = "MODERATOR",
  ADMIN = "ADMIN",
}

// عملات البيع المعتمدة في اليمن
export enum Currency {
  YER_OLD = "YER_OLD", // طبعة صنعاء والمحافظات الشمالية
  YER_NEW = "YER_NEW", // طبعة عدن والمحافظات الجنوبية
}

// وحدات قياس وبيع القات
export enum PriceUnit {
  HABBAH = "حبة",
  QABDAH = "قبضة",
  QILADAH = "قلايد",
  KEES = "كيس",
  KILO = "كيلو",
}

// تصنيفات جودة القات
export enum QualityGrade {
  RUOOS = "رووس",
  WASAT = "وسط",
  QATAF = "قطاف",
  DARIJ = "دارج",
}

// حالة المخزون وتوفر العرض
export enum StockStatus {
  AVAILABLE = "AVAILABLE",
  LOW_STOCK = "LOW_STOCK",
  SOLD_OUT = "SOLD_OUT",
}

// طبيعة التحديث لنظام الموبايل (ميثاق docs/24 و docs/27)
export enum AppUpdateType {
  OPTIONAL = "OPTIONAL", // تحديث مرن
  FORCE = "FORCE", // تحديث إلزامي لا يمكن تخطيه
  PATCH = "PATCH", // رقعة كود برمجية هوائية
}

// مصدر تثبيت التطبيق
export enum InstallerStore {
  GOOGLE_PLAY = "google_play",
  TELEGRAM = "telegram",
  WEBSITE = "website",
  HUAWEI_APPGALLERY = "huawei_appgallery",
  UNKNOWN = "unknown",
}

// هيكل استجابة الواجهة البرمجية الموحد
export interface ApiResponse<T = any> {
  success: boolean;
  statusCode: number;
  message: string;
  data: T;
  meta?: {
    page?: number;
    limit?: number;
    totalItems?: number;
    totalPages?: number;
  };
  error?: string | null;
}

// بيانات فحص إصدار التطبيق والتحديث المستمر
export interface AppVersionCheckResult {
  latestVersion: string;
  latestBuildNumber: number;
  minSupportedVersion: string;
  minSupportedBuildNumber: number;
  updateType: AppUpdateType;
  title: string;
  releaseNotes: string;
  downloadUrl: string;
  apkSizeInBytes: number;
  sha256: string;
  telegramChannelUrl: string;
  telegramPostUrl: string;
  playStoreUrl: string;
  showTelegramOption: boolean;
}
