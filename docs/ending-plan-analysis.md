# الدليل الشامل لتحليل النظام وخطة الانتقال التقنية | منصة قطفة (Qatfa Platform)

---

## 1. تحليل النظام الحالي وما تم إنجازه بدقة (Current System Analysis)

### 1.1 معمارية المشروع الحالية (Architecture)

المشروع مبني بأسلوب **Monorepo** احترافي حديث باستخدام `pnpm workspaces`:

- **`apps/api` (الواجهة الخلفية):** مبني باستخدام **NestJS 11** مع محول فائق الأداء **Fastify 5**، ومدمج بتقنيات ضغط **Brotli/Gzip**، وتدابير حماية الرؤوس **Helmet**، وتوثيق تفاعلي **Swagger/OpenAPI** متاح عبر `/docs`.
- **`apps/admin` (لوحة التحكم):** تطبيق أحادي الصفحة (SPA) مبني باستخدام **React 19** + **Vite 6** + **Tailwind CSS v4** + **TanStack Query v5**، ويتم بناؤه وتقديمه مباشرة بواسطة خادم NestJS/Fastify عبر `SpaController` أو تشغيله منفصلاً عبر Vite.
- **`packages/shared-types` (مكتبة الأنواع المشتركة):** تشمل كافّة الـ Enums والـ Types المشتركة بين الباك إند ولوحة التحكم وتطبيق الموبايل (UserRole, QualityGrade, StockStatus, Currency, AppUpdateType, إلخ).
- **`apps/mobile` (تطبيق الموبايل):** مشروع **Flutter** أولي (قالب أساسي لم تبدأ فيه واجهات الأعمال الفعلية بعد).

### 1.2 ما تم إنجازه برمجياً حتى اللحظة (Completed Features)

1. **الباك إند (API Modules):**
   - **`AuthModule`:** تسجيل المستخدمين بالهاتف، التوثيق عبر JWT، وحراس الصلاحيات (`RolesGuard`, `CurrentUser`).
   - **`AdminModule`:** إدارة كاملة تشمل: تسجيل دخول المشرفين، مراجعة طلبات التوثيق (`Verifications`)، إدارة التجار والمستخدمين، حظر الحسابات، إدارة المحافظات والأسواق الشعبية، سجل التدقيق (`Audit Logs`)، بلاغات المحتوى، وتذاكر الدعم.
   - **`StoresModule`:** إنشاء المتاجر، تصفح المتاجر، التصفح المعتمد على المؤشرات (`Cursor-based pagination`)، وتفاصيل المتجر مع منتجاته.
   - **`ProductsModule`:** نشر قطفة جديدة، تغذية العروض اليومية (`Feed Drops`) مع التصفية والفرز، ونظام البحث المتقدم مع معالجة وتطبيع الحروف العربية (`Arabic Normalizer`).
   - **`GeoModule`:** استعراض المحافظات والمديريات والأسواق مع العملات الافتراضية (ريال قديم/جديد).
   - **`SystemModule`:** فحص الصحة (`/system/health`)، وفحص إصدارات التطبيق للتحديث الهجين (`App Version Control Engine`).
   - **`RedisModule`:** طبقة تكييش ذكية عبر `ioredis` مع آلية التراجع التلقائي (`Graceful Fallback`) في حال عدم تشغيل Redis محلياً.
   - **طبقة البيانات التجريبية الحالية (`InMemoryDatabaseModule`):** محاكاة كاملة لـ TypeORM في الذاكرة مع بذور بيانات جاهزة ومفصلة لأسواق صنعاء وعدن لتشغيل الباك إند ولوحة التحكم فوراً بدون الحاجة لقاعدة بيانات محلية قيد التشغيل.

2. **لوحة التحكم الإدارية (`apps/admin`):**
   - **شاشة الدخول:** دعم الدخول بكلمة سر المشرف المحددة في البيئة (`ADMIN_PASSCODE`).
   - **لوحة المؤشرات العامة (Dashboard):** رسوم بيانية ومؤشرات حية (Sparklines) وتوزيعات التوثيق والنشاط.
   - **إدارة طلبات التوثيق (Verifications Page):** قبول ورفض طلبات توثيق المتاجر والأسواق.
   - **إدارة الأسواق والمحافظات (Markets Page):** تفعيل وتعطيل الأسواق وإضافة أسواق جديدة مع خريطة تفاعلية للمحافظات والأسواق اليمنية.
   - **المستخدمين والتجار (Users & Sellers):** استعراض الحسابات وتغيير الصلاحيات وحظر الحسابات.
   - **الحجوزات والبلاغات والدعم:** شاشات كاملة لإدارة تدفق العمليات اليومية.

---

## 2. ما هو المتبقي والخطوة التالية (Remaining & Next Steps)

1. **الربط الفعلي بقاعدة البيانات الحية (Supabase PostgreSQL):** الانتقال من `InMemoryDatabaseModule` المؤقت إلى `TypeOrmModule` الحقيقي المرتبط بسلسلة اتصال Supabase المباشرة، وتشغيل الهجرات (Migrations).
2. **استبدال التخزين المحلي لصور الوسائط بخدمة Cloudflare R2:** تفعيل الرفع السحابي وتوليد الروابط الموقعة (`Presigned URLs`) أو الرفع المباشر الموفر للبيانات.
3. **تجهيز النشر على Vercel:** إنشاء إعدادات Serverless (`vercel.json`) لخدمة واجهات NestJS API.
4. **بناء واجهات تطبيق الموبايل (Flutter):** البدء في شاشات تطبيق فلاتر (التصفح السريع، خريطة الأسواق، تفاصيل القطفة، الاتصال بالبائع عبر الهاتف والواتساب).

---

## 3. دليل الأوامر والإعدادات (Commands & Operations Guide)

### 3.1 تثبيت التبعيات (Installation)

يتم تثبيت التبعيات من المجلد الرئيسي للمشروع:

```powershell
pnpm install
```

### 3.2 أوامر الباك إند ولوحة التحكم (Development & Build)

| الأمر                                    | المسار | الوصف                                                         |
| :--------------------------------------- | :----- | :------------------------------------------------------------ |
| `pnpm dev`                               | Root   | يقوم ببناء الحزم المشتركة ولوحة التحكم وتشغيل الباك إند       |
| `pnpm --filter @qatfa/api run start:dev` | Root   | تشغيل الباك إند بنمط المراقبة (`Watch Mode`)                  |
| `pnpm --filter @qatfa/admin run dev`     | Root   | تشغيل لوحة التحكم منفصلة على Vite على المنفذ `3000` أو `5173` |
| `pnpm build`                             | Root   | بناء كافة حزم ومشاريع المونوريبو للإنتاج                      |
| `pnpm test`                              | Root   | تشغيل الاختبارات الآلية للباك إند                             |

### 3.3 تشغيل والوصول لـ Swagger ولوحة التحكم

عند تشغيل الباك إند:

- **رابط لوحة التحكم:** `http://localhost:3000/` (يتم تقديم بناء لوحة التحكم تلقائياً).
- **توثيق Swagger API التفاعلي:** `http://localhost:3000/docs`
- **رمز دخول لوحة التحكم الافتراضي:** `123456` (معرّف بمتغير `ADMIN_PASSCODE`).

### 3.4 تشغيل Redis و PostgreSQL محلياً أو عبر Docker

#### الخيار 1: تشغيل خدمات البنية التحتية فقط عبر Docker (الأسهل والأسرع):

```powershell
docker compose up -d postgres redis
```

- للتأكد من سلامة الخدمات:

```powershell
docker compose ps
```

- لإيقاف الخدمات:

```powershell
docker compose down
```

#### الخيار 2: تشغيل المنظومة الكاملة بما فيها الباك إند داخل حاوية Docker:

```powershell
docker compose up -d --build
```

سيعمل الخادم داخل الحاوية على المنفذ `3000` متصلاً تلقائياً بحاويات `postgres` و `redis`.

---

## 4. خطة الانتقال للبنية السحابية الجديدة (Cloud Architecture Update)

```mermaid
graph TD
    subgraph Clients["تطبيقات العملاء"]
        MobileApp["تطبيق فلاتر (Android / iOS)"]
        AdminDashboard["لوحة التحكم الإدارية"]
    end

    subgraph HostingEdge["Vercel Edge Platform"]
        VercelAPI["NestJS API (Serverless Function)"]
    end

    subgraph DatabaseLayer["Supabase (Managed PostgreSQL)"]
        SupaDB[(PostgreSQL 16 Engine)]
        SupaAuth["Supabase Auth / JWT Validation"]
    end

    subgraph MediaStorage["Cloudflare (R2 + CDN)"]
        R2Bucket["Cloudflare R2 Bucket (Zero Egress)"]
        CFCDN["Cloudflare Global CDN (Fast Media Delivery)"]
    end

    MobileApp --> VercelAPI
    AdminDashboard --> VercelAPI
    VercelAPI --> SupaDB
    VercelAPI --> R2Bucket
    MobileApp --> CFCDN
```

### 4.1 تفاصيل قاعدة البيانات (Supabase PostgreSQL)

- **حالة متغيرات البيئة الحالية في `.env.example`:**
  - يوجد حالياً مشروع مسجل بالقيم التالية:
    ```env
    SUPABASE_URL=https://seclhdqigljzmjjxvbyi.supabase.co
    SUPABASE_PUBLISHABLE_KEY=sb_publishable_DWLbBrxiEb9GKQhAiZsg3w_EeSfVvMR
    SUPABASE_SECRET_KEY=your_supabase_secret_key_here
    SUPABASE_JWKS_URL=https://seclhdqigljzmjjxvbyi.supabase.co/auth/v1/.well-known/jwks.json
    ```
- **ما هو الناقص في إعدادات Supabase؟**
  - **سلسلة اتصال قاعدة البيانات المباشرة (Direct Connection String أو Pooler URI):**
    لكي يتصل الباك إند (NestJS / TypeORM) مباشرة بقاعدة البيانات، نحتاج إما:
    1. وضع سلسلة الاتصال `DATABASE_URL` بصيغة:
       ```env
       DATABASE_URL=postgres://postgres.[PROJECT-REF]:[YOUR-PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres?pgbouncer=true
       ```
    2. أو تعبئة المتغيرات التفصيلية من إعدادات Supabase Dashboard -> **Project Settings** -> **Database**:
       - `DB_HOST`: مضيف قاعدة البيانات (مثال: `db.seclhdqigljzmjjxvbyi.supabase.co` أو رابط الـ Pooler).
       - `DB_PORT`: المنفذ (عادة `5432` أو `6543` للـ Pooler).
       - `DB_USER`: اسم المستخدم (غالباً `postgres` أو `postgres.seclhdqigljzmjjxvbyi`).
       - `DB_PASSWORD`: كلمة السر الخاصة بقاعدة بيانات المشروع في Supabase.
       - `DB_NAME`: اسم قاعدة البيانات (افتراضياً `postgres`).

### 4.2 تفاصيل تخزين الوسائط (Cloudflare R2)

Cloudflare R2 متوافق بنسبة 100% مع واجهة **AWS S3 API**، وميزته العظمى لمشروع «قطفة» أنه **بدون أي تكاليف لنقل البيانات (Zero Egress Fees)**، وهو مثالي لصور وفيديوهات القات اليومية في اليمن.

#### خطوات إنشاء حساب وإعداد R2 في Cloudflare:

1. التسجيل أو الدخول في [Cloudflare Dashboard](https://dash.cloudflare.com/).
2. من القائمة الجانبية، اختر **R2**.
3. قم بإنشاء Bucket جديد باسم: `qatfa-media`.
4. انتقل إلى **Manage R2 API Tokens** ثم اضغط **Create API Token**:
   - الصلاحيات: `Object Read & Write`.
   - اختر الـ Bucket المحدد: `qatfa-media`.
5. ستحصل على:
   - **Account ID** (معرف الحساب الخاص بك في Cloudflare).
   - **Access Key ID**.
   - **Secret Access Key**.
6. في إعدادات الـ Bucket، قم بتفعيل **Public Access** أو ربط Custom Domain (مثال: `cdn.qatfa.ye` أو استخدام النطاق المجاني `*.r2.dev`).

#### ما الذي نضيفه في تطبيقنا وأين بالضبط؟
{}
1. **في ملف `apps/api/.env`:**
   ```env
   R2_ACCOUNT_ID=معرف_حساب_كلاودفلاير
   R2_ACCESS_KEY_ID=مفتاح_الدخول
   R2_SECRET_ACCESS_KEY=المفتاح_السري
   R2_BUCKET_NAME=qatfa-media
   R2_PUBLIC_URL=https://pub-xxxx.r2.dev # أو رابط CDN المخصص
   ```
2. **في الكود (`apps/api/src/modules/storage/`):**
   - تثبيت حزمة `@aws-sdk/client-s3` و `@aws-sdk/s3-request-presigner`.
   - إنشاء `StorageService` يقوم بإنشاء رابط رفع مباشر (`Presigned Put Object URL`) ليرفعه تطبيق الموبايل أو لوحة التحكم مباشرة إلى Cloudflare R2 بضغط WebP دون تحميل خادم الباك إند استهلاك البيانات.

### 4.3 تفاصيل استضافة الباك إند على Vercel

Vercel يقدم بيئة Serverless ممتازة وسريعة حول العالم ومجانية/منخفضة التكلفة للبداية.

#### خطوات الإعداد والنشر على Vercel:

1. **إنشاء نقطة دخول Serverless لـ NestJS:**
   - ملف `apps/api/api/index.ts` يقوم بتهيئة NestJS مع Fastify أو Express لاستقبال طلبات Serverless.
2. **إضافة ملف `vercel.json` في جذر المشروع أو جذر `apps/api`:**
   ```json
   {
     "version": 2,
     "builds": [
       {
         "src": "apps/api/src/main.ts",
         "use": "@vercel/node"
       }
     ],
     "routes": [
       {
         "src": "/(.*)",
         "dest": "apps/api/src/main.ts"
       }
     ]
   }
   ```
3. **ضبط متغيرات البيئة في Vercel Dashboard:**
   - نسخ كافة المتغيرات (`DATABASE_URL`, `JWT_SECRET`, `ADMIN_PASSCODE`, `R2_*`) داخل إعدادات المشروع في Vercel (**Settings -> Environment Variables**).
4. **الربط مع مستودع GitHub:** بمجرد الدفع للفرع الرئيسي `main`، سيقوم Vercel بالبناء التلقائي وتقديم رابط عالمي آمن بنطاق SSL مجاني.

---

## 5. مصفوفة الجاهزية والخطوات الفورية المطلوبة

| العنصر                         | الحالة الحالية                       | ما ينقصه للعمل الحي                                         |
| :----------------------------- | :----------------------------------- | :---------------------------------------------------------- |
| **محرك الباك إند والواجهات**   | جاهز بنسبة 100% ويعمل                | لا شيء برمجياً (يعمل حالياً في الذاكرة)                     |
| **لوحة التحكم (Admin Panel)**  | جاهزة ومربوطة بالكامل                | تفعيل البناء التلقائي عند النشر                             |
| **سويجر (Swagger Docs)**       | جاهز ويعمل على `/docs`               | جاهز للتشغيل فوراً                                          |
| **بيانات Supabase**            | المفاتيح متوفرة جزئياً               | نحتاج كلمة مرور قاعدة البيانات أو `DATABASE_URL` للربط الحي |
| **تخزين الوسائط (Cloudflare)** | متوقع ومجهز بالمتغيرات               | إدخال مفاتيح الـ API الفعلية وإنشاء الـ Bucket              |
| **النشر على Vercel**           | جاهز للتكوين                         | إضافة ملف الإعداد `vercel.json` ومهايئ Serverless           |
| **حاويات Docker**              | ملفات `Dockerfile` و `compose` جاهزة | جاهزة للتشغيل المحلي بضغطة زر                               |
