# مواصفات وتصميم واجهات البرمجة (RESTful API Design) | منصة قطفة

---

## 1. المعايير العامة للـ API (API Standards & Conventions)

- **البروتوكول:** HTTPS إلزامي حصراً مع دعم HTTP/2.
- **المسار الأساسي (Base URL):** `https://api.qatfa.ye/api/v1`
- **تنسيق تبادل البيانات:** `application/json` (UTF-8).
- **المصادقة:** رموز `Bearer JWT` تُمرر في ترويسة الطلب `Authorization: Bearer <token>`.
- **هيكل الاستجابة الموحد (Unified Response Envelope):**

```json
{
  "success": true,
  "statusCode": 200,
  "message": "تمت العملية بنجاح",
  "data": {},
  "meta": {
    "page": 1,
    "limit": 20,
    "totalItems": 150,
    "totalPages": 8
  },
  "error": null
}
```

---

## 2. توثيق نقاط الاتصال الأساسية (Endpoints Specification)

### 2.1 وحدة المصادقة (Authentication Endpoints)

#### 1. طلب رمز التحقق (Request OTP)
- **المسار:** `POST /auth/request-otp`
- **الوصول:** عام (Public) - خاضع لمحدد السرعة (3 طلبات / 10 دقائق).
- **قيد فرادة رقم الهاتف (Phone Uniqueness):** في حال طلب التسجيل كحساب جديد وكان رقم الهاتف مسجلاً مسبقاً، ترفض العملية بـ `409 Conflict` لمنع تكرار الحسابات.
- **جسم الطلب (Request Body):**
```json
{
  "phoneNumber": "+967771234567"
}
```
- **الاستجابة الناجحة (200 OK):**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "تم إرسال رمز التحقق بنجاح",
  "data": {
    "retryAfterSeconds": 60
  }
}
```
- **استجابة الخطأ عند تكرار الرقم في التسجيل الجديد (409 Conflict):**
```json
{
  "success": false,
  "statusCode": 409,
  "message": "رقم الهاتف مرتبط بحساب مسجل مسبقاً، يرجى تسجيل الدخول مباشرة",
  "error": "PHONE_ALREADY_EXISTS"
}
```

#### 2. التحقق من الرمز وتسجيل الدخول (Verify OTP)
- **المسار:** `POST /auth/verify-otp`
- **جسم الطلب (Request Body):**
```json
{
  "phoneNumber": "+967771234567",
  "otpCode": "481920",
  "fcmToken": "cW_e3r10...device_token"
}
```
- **الاستجابة الناجحة (200 OK):**
```json
{
  "success": true,
  "statusCode": 200,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "d8f3e2a1...",
    "user": {
      "id": "018d9f10-9b4e-7000-8b10-a1b2c3d4e5f6",
      "phoneNumber": "+967771234567",
      "fullName": "صالح علي الهمداني",
      "role": "SELLER",
      "hasStore": true,
      "storeId": "018d9f12-4c2a-7111-9a10-f1e2d3c4b5a6"
    }
  }
}
```

---

### 2.2 وحدة المتاجر (Stores Endpoints)

#### 1. استعراض قائمة المتاجر والبحث الجغرافي
- **المسار:** `GET /stores`
- **المعلمات (Query Params):**
  - `governorateId=1` (صنعاء)
  - `districtId=4` (السبعين)
  - `marketId=12` (سوق شميلة)
  - `search=الهمداني`
  - `verifiedOnly=true`
  - `page=1&limit=20`
- **الاستجابة الناجحة (200 OK):**
```json
{
  "success": true,
  "statusCode": 200,
  "data": [
    {
      "id": "018d9f12-4c2a-7111-9a10-f1e2d3c4b5a6",
      "storeName": "مفرش العم صالح للقات الهمداني",
      "slug": "al-am-saleh-hamadani",
      "logoUrl": "https://cdn.qatfa.ye/logos/saleh.webp",
      "isVerified": true,
      "isOpenToday": true,
      "ratingAvg": 4.85,
      "reviewsCount": 42,
      "followersCount": 315,
      "location": {
        "governorateName": "أمانة العاصمة صنعاء",
        "districtName": "السبعين",
        "marketName": "سوق شميلة الشعبي",
        "addressDetail": "بجوار بوابة السوق الجنوبية - مفرش 11"
      },
      "phones": {
        "call": "+967771234567",
        "whatsapp": "+967771234567"
      }
    }
  ],
  "meta": { "page": 1, "limit": 20, "totalItems": 1 }
}
```

#### 2. تحديث إعدادات وحالة عمل المتجر (Store Settings & Master Toggle)
- **المسار:** `PATCH /stores/my-store/settings`
- **الصلاحية:** مقاوتي صاحب متجر (`SELLER`).
- **جسم الطلب (Request Body):**
```json
{
  "isOpenToday": true,
  "muteReviewNotifications": true
}
```
- **الوصف:** 
  - `isOpenToday`: المفتاح الرئيسي لحالة المتجر بالكامل (Master Store Toggle).
  - `muteReviewNotifications`: تمكين المقاوتي من إيقاف إشعارات التقييمات حتى لا تزعجه أثناء ساعات الذروة في السوق.

#### 3. جلب القوائم السريعة المجهزة للمفرش (Get Seller Presets)
- **المسار:** `GET /stores/my-store/presets`
- **الصلاحية:** `SELLER`
- **الاستجابة (200 OK):**
```json
{
  "success": true,
  "data": {
    "types": ["عنسي", "حوشب", "أرحبي", "همداني", "شامي"],
    "grades": ["رووس", "عوارض", "قطل", "جمام", "سمين"],
    "units": ["حبه", "كيلو", "قبضه"]
  }
}
```

#### 4. حفظ وتحديث القوائم السريعة المسبقة (Save Seller Presets)
- **المسار:** `POST /stores/my-store/presets`
- **الصلاحية:** `SELLER`
- **جسم الطلب:**
```json
{
  "types": ["عنسي", "حوشب", "أرحبي"],
  "grades": ["رووس", "عوارض", "قطل"],
  "units": ["حبه", "كيلو", "قبضه"]
}
```

#### 5. إضافة عنصر مخصص جديد للقوائم السريعة (Add Custom Preset Item)
- **المسار:** `POST /stores/my-store/presets/custom`
- **الصلاحية:** `SELLER` (متاح عبر الزر العلوي في شاشة الإعداد وشاشة النشر السريع)
- **جسم الطلب:**
```json
{
  "category": "QAT_TYPE",
  "value": "غيلي فاخر"
}
```

---

### 2.3 وحدة المنتجات والقطفة اليومية (Products / Drops Endpoints)

#### 1. استعراض موجز قطفات اليوم والبحث الذكي بالميزانية (Get Drops & Budget Search)
- **المسار:** `GET /products/drops`
- **المعلمات:**
  - `governorateId=1`
  - `marketId=14` (حصر البحث بنطاق سوق معين)
  - `qatType=همداني`
  - `budget=8000` (المبلغ المتوفر لدى المشتري نقداً)
  - `budgetTolerance=0.10` (نسبة التفاوت المسموحة ±10% أي بين 7,200 و 8,800 ريال)
  - `stockStatus=AVAILABLE`
  - `page=1&limit=20`
- **الاستجابة الناجحة (200 OK):**
```json
{
  "success": true,
  "statusCode": 200,
  "data": [
    {
      "id": "018d9f20-aa33-7222-8811-001122334455",
      "title": "همداني أبيض فاخر (قطفة الصباح)",
      "qatType": "همداني",
      "qualityGrade": "رووس",
      "price": 8500,
      "currency": "YER_OLD",
      "priceUnit": "حبه",
      "stockStatus": "AVAILABLE",
      "isAvailable": true,
      "harvestTime": "اليوم 06:30 صباحاً",
      "harvestRegion": "مزارع حاز - همدان",
      "images": [
        "https://cdn.qatfa.ye/products/prod_101_1.webp"
      ],
      "publishedAt": "2026-11-22T12:15:00+03:00",
      "publishedTimeAgo": "منذ 15 دقيقة",
      "store": {
        "id": "018d9f12-4c2a-7111-9a10-f1e2d3c4b5a6",
        "storeName": "مفرش العم صالح",
        "isVerified": true,
        "phoneCall": "+967771234567",
        "phoneWhatsapp": "+967771234567"
      }
    }
  ]
}
```

#### 2. نشر قطفة جديدة سريعة (Publish Daily Drop)
- **المسار:** `POST /products`
- **الصلاحية:** `SELLER`
- **جسم الطلب (Request Body):**
```json
{
  "title": "عنسي رووس فاخر قطفة الصباح",
  "qatType": "عنسي",
  "qualityGrade": "رووس",
  "price": 12000,
  "currency": "YER_OLD",
  "priceUnit": "حبه",
  "stockQuantity": 15,
  "harvestRegion": "عنس - ذمار",
  "harvestTime": "صباح اليوم",
  "images": [
    "https://cdn.qatfa.ye/products/upload_9876.webp"
  ]
}
```

#### 3. التبديل المستقل لتوفر المنتج (Per-Product Availability Toggle)
- **المسار:** `PATCH /products/:id/availability`
- **الصلاحية:** `SELLER`
- **جسم الطلب:**
```json
{
  "isAvailable": false
}
```
- **الوصف:** يتيح للمقاوتي تفعيل متوفر / غير متوفر لكل منتج على حدة بجانب المفتاح الرئيسي للمتجر.

#### 4. تحديث حالة المخزون والإخفاء التلقائي عند النفاذ (Toggle Stock & Auto-Hide)
- **المسار:** `PATCH /products/:id/stock`
- **الصلاحية:** `SELLER`
- **جسم الطلب:**
```json
{
  "stockStatus": "SOLD_OUT"
}
```
- **السلوك الآلي:** عند وصول الحالة لـ `SOLD_OUT` أو نفاذ الكمية:
  1. يُخفى المنتج فوراً من التطبيق (`isActive = false`).
  2. يُرسل إشعار Push للمقاوتي بنفاذ الكمية وإخفاء المنتج.

#### 5. إجراء المقاوتي على إشعار نفاذ الكمية (Stock-Out Action)
- **المسار:** `POST /products/:id/stock-out-action`
- **الصلاحية:** `SELLER`
- **جسم الطلب:**
```json
{
  "action": "EDIT_QUANTITY",
  "newQuantity": 10,
  "newPrice": 12000
}
```
*(أو إرسال `action: "CONFIRM_HIDE"` لتأكيد بقاء المنتج مخفياً)*

#### 6. نشر إعلان سريع يومي بدون إعداد كامل (Daily Express Ad)
- **المسار:** `POST /products/express-ad`
- **الصلاحية:** `SELLER`
- **قيد الاستخدام:** إعلان واحد في اليوم لكل مقاوتي (1 Ad / Day).
- **جسم الطلب:**
```json
{
  "description": "قات حوشب طازج قطفة الفجر نظيف وممتاز جداً متواجدين بسوق شميلة",
  "price": 10000,
  "currency": "YER_OLD",
  "imageUrl": "https://cdn.qatfa.ye/express/exp_101.webp"
}
```
- **الاستجابة عند تجاوز الحد اليومي (429 Too Many Requests):**
```json
{
  "success": false,
  "statusCode": 429,
  "message": "لقد استهلكت إعلانك السريع لليوم (الحد: إعلان واحد في اليوم)، أكمل إعداد متجرك للنشر غير المحدود"
}
```

---

### 2.4 وحدة التفاعل والمجتمع (Social & Interactions)

#### 1. تسجيل نقرة تواصل (Log Lead Click)
- **المسار:** `POST /interactions/lead-click`
- **جسم الطلب:**
```json
{
  "storeId": "018d9f12-4c2a-7111-9a10-f1e2d3c4b5a6",
  "productId": "018d9f20-aa33-7222-8811-001122334455",
  "clickType": "WHATSAPP"
}
```

#### 2. متابعة / إلغاء متابعة متجر (Toggle Follow)
- **المسار:** `POST /stores/:id/follow`
- **الوصول:** مستخدم مسجل (`CUSTOMER`, `SELLER`).
- **الاستجابة (200 OK):**
```json
{
  "success": true,
  "data": {
    "isFollowing": true,
    "followersCount": 316
  }
}
```

#### 3. تقديم تقييم للمتجر (Submit Review)
- **المسار:** `POST /stores/:id/reviews`
- **جسم الطلب:**
```json
{
  "rating": 5,
  "comment": "القات طازج جداً وسعره منصف والتعامل صادق، أنصح بالتعامل معه."
}
```

#### 4. الإبلاغ عن عرض مضلل ومنع التكرار (Report Misleading Drop & Anti-Abuse)
- **المسار:** `POST /products/:id/report`
- **الوصول:** عام / مستخدم مسجل (خاضع لقيد منع التكرار الصارم).
- **قواعد مكافحة الإساءة والنزاهة:**
  1. **منع التكرار (Deduplication):** لا يمكن لنفس المستخدم أو نفس المعرف تقديم أكثر من بلاغ واحد على نفس القطفة أو نفس التاجر.
  2. **الرقابة اليدوية حصراً (No Auto-Ban):** البلاغات لا تتسبب في أي إيقاف آلي لحساب التاجر أو العرض، بل تُحال إلى لوحة تحكم المشرفين وفريق الدعم للتحقق البشري والمكالمة الميدانية.
- **جسم الطلب:**
```json
{
  "reason": "MISLEADING_IMAGE",
  "comment": "الصورة قديمة والقات في السوق مختلف تماماً عن المعروض",
  "contactPhone": "+967771234567"
}
```
- **الاستجابة الناجحة لأول بلاغ (200 OK):**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "تم استلام البلاغ بنجاح وجارٍ فحصه من فريق الدعم لحماية ثقة السوق"
}
```
- **استجابة محاولة تكرار البلاغ من نفس المستخدم (409 Conflict):**
```json
{
  "success": false,
  "statusCode": 409,
  "message": "لقد قمت بتقديم بلاغ مسبقاً عن هذا العرض/المستخدم، وهو قيد المراجعة لدى فريق الإدارة",
  "error": "DUPLICATE_REPORT_NOT_ALLOWED"
}
```

#### 5. بيانات المشاركة الذكية والرابط المباشر (Deep Link Share Data)
- **المسار:** `GET /share/drop/:id`
- **الوصول:** عام (مفتوح لمنصات التواصل)
- **الاستجابة:** يُعيد بيانات OpenGraph متضمنة عنوان القطفة، السعر، الصورة المصغرة، ورابط فتح التطبيق المباشر `qatfa://drop/:id` أو رابط الويب `https://qatfa.ye/drop/:id`.

---

### 2.5 وحدة الدليل الجغرافي وخرائط الأسواق (Geo & Market Maps)

#### 1. جلب الشجرة الجغرافية الكاملة (Get Geo Hierarchy Tree)
- **المسار:** `GET /geo/tree`
- **الوصول:** عام ومخزن مؤقتاً عبر CDN لمدة 24 ساعة (ETag / Cache-Control: max-age=86400).
- **الاستجابة:** قائمة المحافظات، وتحت كل محافظة مديرياتها، وتحت كل مديرية أشهر أسواق القات فيها.

#### 2. جلب خريطة السوق ومواقع المفارش (Get Market Map & Stalls)
- **المسار:** `GET /markets/:id/map`
- **الوصول:** عام
- **الاستجابة (200 OK):**
```json
{
  "success": true,
  "data": {
    "marketId": 14,
    "marketName": "سوق علي محسن - صنعاء",
    "centerLatitude": 15.3694,
    "centerLongitude": 44.1782,
    "boundaryPolygon": "...",
    "stalls": [
      {
        "storeId": "018d9f12-4c2a-7111-9a10-f1e2d3c4b5a6",
        "storeName": "مفرش العم صالح",
        "stallNumber": "14",
        "latitude": 15.3695,
        "longitude": 44.1785,
        "isVerifiedPhone": true,
        "hasLiveDropToday": true,
        "stockStatus": "AVAILABLE",
        "latestDropTitle": "شامي أبيض فاخر",
        "latestDropPrice": 12000
      }
    ]
  }
}
```
