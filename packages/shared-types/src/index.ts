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

// معايير الترقيم بالمؤشر (Cursor Pagination Meta)
export interface CursorPaginationMeta {
  nextCursor: string | null;
  hasMore: boolean;
  limit: number;
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
  pagination?: CursorPaginationMeta;
  error?: string | null;
}

// تصنيف مطابقة الميزانية في البحث العكسي
export enum BudgetMatchType {
  EXACT_MATCH = "EXACT_MATCH",
  NEAR_MATCH_CHEAPER = "NEAR_MATCH_CHEAPER",
  NEAR_MATCH_STRETCHED = "NEAR_MATCH_STRETCHED",
}

// بطاقة عرض القطفة اليومية الرشيقة لموجز فلاتر (Slim Product Card)
export interface ProductCardSlim {
  id: string;
  storeId: string;
  title: string;
  qatType: string;
  qualityGrade: QualityGrade;
  price: number;
  currency: Currency;
  priceUnit: PriceUnit;
  stockStatus: StockStatus;
  stockQuantity: number;
  harvestRegion?: string;
  harvestTime?: string;
  primaryImage?: string;
  images: string[];
  blurHash?: string;
  dropDate: string;
  createdAt: string;
  publishedTimeAgo?: string;
  store: {
    id: string;
    storeName: string;
    slug?: string;
    stallNumber?: string;
    stallLandmark?: string;
    isVerifiedPhone: boolean;
    isVerifiedBadge: boolean;
    isOpenNow: boolean;
    phoneCall?: string;
    phoneWhatsapp?: string;
    averageRating: number;
    marketName?: string;
    distanceMeters?: number;
  };
  budgetMatch?: {
    targetBudget: number;
    priceDelta: number;
    signedDelta: number;
    deltaText: string;
    matchType: BudgetMatchType;
    badgeColor: string;
  };
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
