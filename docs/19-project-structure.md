# هيكلية الكود والمعمارية البرمجية (Project Structure & Clean Architecture) | منصة قطفة

---

## 1. استراتيجية المستودعات (Repository Strategy)

اعتماد أسلوب **المستودع الموحد المنظم (Monorepo)** باستخدام أدوات خفيفة لتسهيل مشاركة النماذج ومزامنة التطوير بين فرق الموبايل والباك إند ولوحة التحكم.

```
qtfh/
├── apps/
│   ├── mobile/          # تطبيق الهواتف الذكية (Flutter)
│   ├── api/             # خادم الواجهات الخلفية (NestJS)
│   └── admin/           # لوحة التحكم الإدارية (React + Vite)
├── packages/
│   └── shared-types/    # العقود المشتركة والأنواع (TypeScript DTOs & Constants)
├── docker/              # ملفات التشغيل والإنتاج (Docker Compose & Nginx)
├── docs/                # كافة وثائق المشروع الفنية والتجارية
└── .github/workflows/   # مسارات النشر الآلي المستمر (CI/CD)
```

---

## 2. معمارية تطبيق الموبايل (Flutter Feature-First Architecture)

يتبع تطبيق الموبايل معمارية **Feature-First** المدمجة مع مبادئ **Clean Architecture** وإدارة الحالة عبر **Bloc / Cubit** لضمان استقرار التطبيق وقابلية اختباره.

```
apps/mobile/lib/
├── app.dart                   # التهيئة العامة والتوجيه والثيم
├── main.dart                  # نقطة الانطلاق الرئيسية
├── core/                      # النواة المشتركة (Shared Core)
│   ├── constants/             # الثوابت، الألوان، أبعاد الشاشات
│   ├── network/               # عميل Dio، المعالجات، الترويسات والـ Interceptors
│   ├── error/                 # معالجة الأخطاء والفشل (Failures & Exceptions)
│   ├── theme/                 # ثيم قطفة (خط Cairo، الوضع الفاتح، التباين العالي)
│   ├── utils/                 # ضغط الصور، صيغ التوقيت باللغة العربية
│   └── storage/               # التخزين المؤقت المحلي (Hive / Secure Storage)
└── features/                  # ميزات التطبيق المقسمة حسب الوظيفة
    ├── auth/                  # المصادقة ورمز الـ OTP
    │   ├── data/              # مصادر البيانات والمستودعات (DataSources & Repos)
    │   ├── domain/            # الكيانات وحالات الاستخدام (Entities & UseCases)
    │   └── presentation/      # الشاشات والـ Cubit والـ Widgets
    ├── drops_feed/            # موجز القطفات اليومية والفلترة
    ├── store_profile/         # صفحة متجر المقاوتي والمراجعات
    ├── quick_publish/         # نافذة النشر السريع للتاجر والكاميرا
    ├── geo_explorer/          # شجرة اختيار المحافظات والمديريات والأسواق
    └── reviews_ratings/       # التقييمات والمراجعات المجتمعية
```

---

## 3. معمارية الخادم الخلفي (NestJS Modular Clean Architecture)

يعتمد خادم NestJS على هيكل وحدات مستقلة (Modular Architecture) تتبع مبادئ فصل المسؤوليات وحقن التبعيات (Dependency Injection):

```
apps/api/src/
├── main.ts                    # نقطة بدء خادم Fastify والتوثيق
├── app.module.ts              # الوحدة الجذرية المجمعة لكافة الوحدات
├── common/                    # الأدوات والحراس المشتركة
│   ├── decorators/            # المعرّفات المخصصة (@CurrentUser, @Roles)
│   ├── filters/               # مصيدة الأخطاء العامة (AllExceptionsFilter)
│   ├── guards/                # حراس الأمان (JwtAuthGuard, RolesGuard, OwnershipGuard)
│   ├── interceptors/          # معالج الاستجابات الموحدة وتسجيل الوقت
│   └── pipes/                 # أنابيب التحقق والتعقيم (ValidationPipe)
├── config/                    # إعدادات البيئة (Database, Redis, S3/R2, JWT)
├── database/                  # ملفات الترحيل والتغذية الأولية (Migrations & Seeds)
└── modules/                   # الوحدات الوظيفية المستقلة
    ├── auth/                  # مصادقة المستخدمين وخدمة الـ OTP
    ├── users/                 # إدارة الحسابات والصلاحيات
    ├── stores/                # المتاجر، التوثيق، وساعات العمل
    ├── products/              # عروض القطفة اليومية وحالة التوفر
    ├── reviews/               # التقييمات ونظام مكافحة التلاعب
    ├── interactions/          # تتبع نقرات الاتصال والواتساب
    ├── geo/                   # إدارة المحافظات والمديريات والأسواق
    ├── media/                 # رفع وضغط الوسائط والتكامل مع R2
    ├── notifications/         # معالجة إرسال إشعارات Firebase في الخلفية
    └── admin/                 # الـ APIs المخصصة للوحة التحكم والمشرفين
```

---

## 4. معمارية لوحة التحكم الإدارية (React 18 + Vite)

تم بناء لوحة التحكم بأسلوب منظم وسهل الصيانة:

```
apps/admin/src/
├── main.tsx
├── App.tsx
├── routes/                    # التوجيه المحمي وحراس الصلاحيات (Protected Routes)
├── components/                # المكونات المشتركة
│   ├── ui/                    # مكونات التصميم الأساسية (shadcn/ui Buttons, Dialogs...)
│   ├── layout/                # الشريط الجانبي والترويسة وهيكل الصفحة
│   └── feedback/              # جداول البيانات ومؤشرات التحميل
├── features/                  # الصفحات الوظيفية
│   ├── dashboard/             # شاشات الإحصائيات والمخططات الحية
│   ├── stores/                # مراجعة وتوثيق وإيقاف المتاجر
│   ├── moderation/            # طابور البلاغات والإجراءات الفورية
│   ├── geo-manager/           # إدارة شجرة المدن والأسواق
│   └── users/                 # إدارة المستخدمين والصلاحيات
├── services/                  # عملاء استدعاء الـ APIs عبر Axios و React Query
└── hooks/                     # الـ Custom Hooks لإدارة الحالة والتنبيهات
```
