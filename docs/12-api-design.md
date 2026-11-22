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

#### 2. تحديث حالة عمل المتجر اليوم (Open/Closed Toggle)
- **المسار:** `PATCH /stores/my-store/status`
- **الصلاحية:** مقاوتي صاحب متجر (`SELLER`).
- **جسم الطلب:**
```json
{
  "isOpenToday": true
}
```

---

### 2.3 وحدة المنتجات والقطفة اليومية (Products / Drops Endpoints)

#### 1. استعراض موجز قطفات اليوم للجمهور (Get Today's Drops Feed)
- **المسار:** `GET /products/drops`
- **المعلمات:** `governorateId=1&qatType=همداني&stockStatus=AVAILABLE&page=1`
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
      "qualityGrade": "SUPER",
      "price": 12000,
      "currency": "YER_OLD",
      "priceUnit": "حبة",
      "stockStatus": "AVAILABLE",
      "harvestTime": "اليوم 06:30 صباحاً",
      "harvestRegion": "مزارع حاز - همدان",
      "images": [
        "https://cdn.qatfa.ye/products/prod_101_1.webp",
        "https://cdn.qatfa.ye/products/prod_101_2.webp"
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

#### 2. نشر قطفة جديدة (Publish Daily Drop)
- **المسار:** `POST /products`
- **الصلاحية:** `SELLER`
- **جسم الطلب (Request Body):**
```json
{
  "title": "همداني أبيض فاخر قطفة الصباح",
  "qatType": "همداني",
  "qualityGrade": "SUPER",
  "price": 12000,
  "currency": "YER_OLD",
  "priceUnit": "حبة",
  "harvestRegion": "همدان - حاز",
  "harvestTime": "صباح اليوم",
  "images": [
    "https://cdn.qatfa.ye/products/upload_9876.webp"
  ]
}
```
- **الاستجابة الناجحة (201 Created):** يعيد بيانات المنتج المنشور مضافاً إليه الطابع الزمني وحالة التوفر.

#### 3. تغيير حالة التوفر الفوري (Toggle Stock)
- **المسار:** `PATCH /products/:id/stock`
- **جسم الطلب:**
```json
{
  "stockStatus": "SOLD_OUT"
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

---

### 2.5 وحدة الدليل الجغرافي المرجعي (Geographic Master Data)

#### 1. جلب الشجرة الجغرافية الكاملة (Get Geo Hierarchy Tree)
- **المسار:** `GET /geo/tree`
- **الوصول:** عام ومخزن مؤقتاً عبر CDN لمدة 24 ساعة (ETag / Cache-Control: max-age=86400).
- **الاستجابة:** قائمة المحافظات، وتحت كل محافظة مديرياتها، وتحت كل مديرية أشهر أسواق القات فيها.
