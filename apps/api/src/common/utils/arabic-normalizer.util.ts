/**
 * تطبيع النصوص العربية لتوحيد الأحرف المتشابهة وإزالة التشكيل
 */
export function normalizeArabic(text?: string | null): string {
  if (!text || typeof text !== "string") {
    return "";
  }

  return text
    .trim()
    .replace(/[\u064B-\u065F\u0670]/g, "") // إزالة حركات التشكيل والتنوين
    .replace(/[أإآٱ]/g, "ا") // توحيد الهمزات والألفات
    .replace(/ة/g, "ه") // توحيد التاء المربوطة
    .replace(/ى/g, "ي") // توحيد الألف المقصورة والياء
    .replace(/ـ/g, "") // إزالة الكشيدة التطويلية
    .replace(/\s+/g, " "); // توحيد الفراغات المتعددة
}

/**
 * تنسيق الوقت المنقضي باللغة العربية بطريقة مريحة للعين في بطاقات العروض
 */
export function formatArabicTimeAgo(dateInput: Date | string): string {
  const date = typeof dateInput === "string" ? new Date(dateInput) : dateInput;
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffSec = Math.floor(diffMs / 1000);
  const diffMin = Math.floor(diffSec / 60);
  const diffHours = Math.floor(diffMin / 60);

  if (diffSec < 60) {
    return "الآن - طازج";
  }
  if (diffMin < 60) {
    return `منذ ${diffMin} دقيقة`;
  }
  if (diffHours < 24) {
    return `منذ ${diffHours} ساعة`;
  }
  return "قطفة الأمس";
}
