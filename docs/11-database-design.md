# تصميم وهيكلية قاعدة البيانات (Database Design & ERD) | منصة قطفة

---

## 1. محرك قاعدة البيانات والمعايير العامة

- **المحرك:** PostgreSQL 16 Enterprise.
- **الترميز:** `UTF8` لدعم كامل للغة العربية.
- **التوقيت:** التخزين الموحد بتوقيت `UTC` مع العرض للمستخدم بتوقيت اليمن `Asia/Aden` (UTC+3).
- **المعرفات الأساسية (Primary Keys):** استخدام `UUID v7` أو `BIGSERIAL` المتسلسل المفهرس لسرعة الفهرسة العالية.
- **الحذف المرن (Soft Deletes):** استخدام حقل `deleted_at` لكافة الجداول الحيوية لحفظ السجلات وتفادي الفقدان غير المقصود.

---

## 2. مخطط علاقات الكيانات (Entity Relationship Diagram - ERD)

```mermaid
erDiagram
    USERS ||--o| STORES : "يمتلك (1 to 1)"
    USERS ||--o{ REVIEWS : "يكتب"
    USERS ||--o{ STORE_FOLLOWERS : "يتابع"
    USERS ||--o{ FAVORITES : "يحفظ"
    USERS ||--o{ REPORTS : "يبلغ (قيد فريد يمنع التكرار)"
    
    STORES ||--o{ PRODUCTS : "ينشر"
    STORES ||--o{ SELLER_PRESETS : "يعد خياراته المسبقة"
    STORES ||--o{ EXPRESS_ADS : "ينشر إعلانات سريعة (1 يومياً)"
    STORES ||--o{ REVIEWS : "يتلقى"
    STORES ||--o{ STORE_FOLLOWERS : "يمتلك متابعين"
    STORES ||--o{ LEAD_CLICKS : "يتلقى طلبات اتصال"

    GOVERNORATES ||--o{ DISTRICTS : "تتضمن"
    DISTRICTS ||--o{ MARKETS : "تتضمن"
    
    GOVERNORATES ||--o{ STORES : "يتبع"
    DISTRICTS ||--o{ STORES : "يتبع"
    MARKETS ||--o{ STORES : "يقع في"

    PRODUCTS ||--o{ LEAD_CLICKS : "يستفسر عن"
```

---

## 3. جداول قاعدة البيانات التفصيلية (DDL Specifications)

### 3.1 جدول المستخدمين (`users`)
| الحقل | النوع | القيود | الوصف |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | PRIMARY KEY | المعرف الفريد للمستخدم |
| `phone_number` | `VARCHAR(20)` | UNIQUE, NOT NULL | رقم الهاتف بصيغة دولية (+967) - قيد فريد صارم يمنع التكرار نهائياً |
| `full_name` | `VARCHAR(100)` | NOT NULL | الاسم الظاهر |
| `role` | `VARCHAR(20)` | NOT NULL, DEFAULT 'CUSTOMER' | الصلاحية: `GUEST`, `CUSTOMER`, `SELLER`, `MODERATOR`, `ADMIN` |
| `avatar_url` | `VARCHAR(500)` | NULLABLE | رابط الصورة الشخصية |
| `governorate_id` | `INT` | NULLABLE | المحافظة المفضلة للتصفح السريع |
| `is_active` | `BOOLEAN` | DEFAULT TRUE | هل الحساب نشط أم محظور (الحظر حصراً عبر لوحة الإدارة) |
| `fcm_token` | `VARCHAR(300)` | NULLABLE | رمز جهاز Firebase للإشعارات |
| `created_at` | `TIMESTAMPTZ` | DEFAULT NOW() | تاريخ الإنشاء |
| `updated_at` | `TIMESTAMPTZ` | DEFAULT NOW() | تاريخ التعديل |

---

### 3.2 جدول المتاجر والمقاوتية (`stores`)
| الحقل | النوع | القيود | الوصف |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | PRIMARY KEY | معرف المتجر |
| `user_id` | `UUID` | UNIQUE, REFERENCES users(id) | مالك المتجر (المقاوتي) |
| `store_name` | `VARCHAR(150)` | NOT NULL | اسم الشهرة أو المحل |
| `slug` | `VARCHAR(160)` | UNIQUE, NOT NULL | رابط فريد للمشاركة |
| `bio` | `TEXT` | NULLABLE | نبذة عن المقاوتي وخبرته |
| `logo_url` | `VARCHAR(500)` | NULLABLE | شعار المتجر |
| `cover_url` | `VARCHAR(500)` | NULLABLE | صورة واجهة المتجر / المفرش |
| `phone_call` | `VARCHAR(20)` | NOT NULL | رقم الاتصال المباشر |
| `phone_whatsapp`| `VARCHAR(20)` | NOT NULL | رقم الواتساب المعتمد |
| `governorate_id`| `INT` | REFERENCES governorates(id) | المحافظة |
| `district_id` | `INT` | REFERENCES districts(id) | المديرية |
| `market_id` | `INT` | REFERENCES markets(id) | السوق الشعبي |
| `address_detail`| `VARCHAR(255)`| NOT NULL | معلم بارز (مثال: جوار بوابة 2) |
| `latitude` | `DECIMAL(10,8)`| NULLABLE | خط العرض (اختياري) |
| `longitude` | `DECIMAL(11,8)`| NULLABLE | خط الطول (اختياري) |
| `is_verified` | `BOOLEAN` | DEFAULT FALSE | شارة التوثيق الرسمية |
| `is_open_today` | `BOOLEAN` | DEFAULT TRUE | المفتاح الرئيسي لحالة المتجر (Master Store Toggle) |
| `mute_review_notifications` | `BOOLEAN` | DEFAULT FALSE | مفتاح إيقاف إشعارات التقييمات للمقاوتي لتفادي الإزعاج |
| `rating_avg` | `DECIMAL(3,2)` | DEFAULT 5.00 | متوسط التقييم التراكمي |
| `reviews_count` | `INT` | DEFAULT 0 | إجمالي عدد المراجعات |
| `followers_count`| `INT` | DEFAULT 0 | عدد المتابعين |
| `created_at` | `TIMESTAMPTZ` | DEFAULT NOW() | تاريخ التسجيل |
| `updated_at` | `TIMESTAMPTZ` | DEFAULT NOW() | تاريخ التحديث |

---

### 3.3 جدول المنتجات وعروض القطفة اليومية (`products`)
| الحقل | النوع | القيود | الوصف |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | PRIMARY KEY | معرف القطفة / المنتج |
| `store_id` | `UUID` | REFERENCES stores(id) | المتجر التابع له |
| `title` | `VARCHAR(150)` | NOT NULL | عنوان العرض (مثال: شامي فاخر رأس) |
| `qat_type` | `VARCHAR(50)` | NOT NULL | النوع (همداني، شامي، عنسي، حوشب، أرحبي، إلخ) |
| `quality_grade`| `VARCHAR(30)` | NOT NULL | الصنف والجودة (رووس، عوارض، قطل، جمام، سمين) |
| `harvest_region`| `VARCHAR(100)`| NULLABLE | منطقة القطف والمزرعة |
| `harvest_time` | `VARCHAR(50)` | NOT NULL | وقت القطف (قطفة الصباح، قطفة الأمس) |
| `price` | `DECIMAL(12,2)`| NOT NULL | السعر بالريال |
| `currency` | `VARCHAR(10)` | DEFAULT 'YER_OLD' | العملة (`YER_OLD` قديم / `YER_NEW` جديد) |
| `price_unit` | `VARCHAR(30)` | NOT NULL | الوحدة (حبه، كيلو، قبضه، كيس، شظية) |
| `stock_quantity`| `INT` | DEFAULT 1 | الكمية المتوفرة حالياً |
| `stock_status` | `VARCHAR(20)` | DEFAULT 'AVAILABLE' | الحالة: `AVAILABLE`, `SOLD_OUT` |
| `is_available` | `BOOLEAN` | DEFAULT TRUE | مفتاح التوفر المستقل لكل منتج (Per-Product Availability Toggle) |
| `images` | `JSONB` | NOT NULL | مصفوفة روابط الصور المضغوطة |
| `video_url` | `VARCHAR(500)` | NULLABLE | رابط فيديو قصير إن وجد |
| `is_active` | `BOOLEAN` | DEFAULT TRUE | متاح للعرض بالعامة أم مخفي تلقائياً |
| `drop_date` | `DATE` | DEFAULT CURRENT_DATE | تاريخ يوم القطفة (عروض اليوم فقط دون تخزين مسبق) |
| `created_at` | `TIMESTAMPTZ` | DEFAULT NOW() | توقيت النشر الفعلي |
| `updated_at` | `TIMESTAMPTZ` | DEFAULT NOW() | توقيت التعديل |

> **قاعدة عمل آلية (Auto-Hide Trigger):** عند تحول `stock_status` إلى `'SOLD_OUT'` أو وصول `stock_quantity` إلى `0` أو تحويل `is_available` إلى `FALSE`:
> 1. يتم ضبط `is_active = FALSE` فوراً لإخفاء المنتج من موجز التطبيق ونتائج البحث.
> 2. يُطلق النظام حدثاً لإرسال إشعار فوري (Push Notification) لهاتف المقاوتي، يفتح نافذة تفاعلية تتيح له إما تعديل الكمية وإعادة الإظهار أو تأكيد الإخفاء.

---

### 3.4 جدول التقييمات والمراجعات (`reviews`)
| الحقل | النوع | القيود | الوصف |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | PRIMARY KEY | معرف المراجعة |
| `user_id` | `UUID` | REFERENCES users(id) | العميل المقيم |
| `store_id` | `UUID` | REFERENCES stores(id) | المتجر المقيم |
| `rating` | `INT` | CHECK (rating >= 1 AND rating <= 5) | عدد النجوم |
| `comment` | `TEXT` | NOT NULL | نص الرأي والتقييم |
| `merchant_reply`| `TEXT` | NULLABLE | رد التاجر الرسمي |
| `is_approved` | `BOOLEAN` | DEFAULT TRUE | هل التقييم معتمد أم محجوب |
| `created_at` | `TIMESTAMPTZ` | DEFAULT NOW() | تاريخ التقييم |

---

### 3.5 جدول متابعات المتاجر (`store_followers`)
| الحقل | النوع | القيود | الوصف |
| :--- | :--- | :--- | :--- |
| `id` | `BIGSERIAL` | PRIMARY KEY | معرف السجل |
| `user_id` | `UUID` | REFERENCES users(id) | المستخدم المتابع |
| `store_id` | `UUID` | REFERENCES stores(id) | المتجر المتابع |
| `created_at` | `TIMESTAMPTZ` | DEFAULT NOW() | تاريخ المتابعة |
*(قيد فريد: `UNIQUE(user_id, store_id)` لمنع التكرار)*

---

### 3.6 جدول تتبع التحويلات والاتصالات (`lead_clicks`)
| الحقل | النوع | القيود | الوصف |
| :--- | :--- | :--- | :--- |
| `id` | `BIGSERIAL` | PRIMARY KEY | معرف السجل |
| `user_id` | `UUID` | NULLABLE | المستخدم إن كان مسجلاً (أو NULL للزائر) |
| `store_id` | `UUID` | REFERENCES stores(id) | المتجر المستهدف |
| `product_id` | `UUID` | NULLABLE, REFERENCES products(id) | المنتج المستفسر عنه |
| `click_type` | `VARCHAR(20)` | NOT NULL | نوع الإجراء: `PHONE_CALL` أو `WHATSAPP` |
| `ip_address` | `INET` | NULLABLE | عنوان الآي بي لتحليل السلوك ومنع الاحتيال |
| `created_at` | `TIMESTAMPTZ` | DEFAULT NOW() | وقت النقر |

---

### 3.7 جداول الدليل الجغرافي المرجعي (`governorates`, `districts`, `markets`)
- `governorates`: `(id, name_ar, name_en, currency_code, is_active)`
- `districts`: `(id, governorate_id, name_ar, is_active)`
- `markets`: `(id, district_id, name_ar, landmark, is_active)`

---

### 3.8 جدول القوائم السريعة المسبقة للمقاوتي (`seller_presets`)
| الحقل | النوع | القيود | الوصف |
| :--- | :--- | :--- | :--- |
| `id` | `BIGSERIAL` | PRIMARY KEY | معرف السجل |
| `store_id` | `UUID` | REFERENCES stores(id) ON DELETE CASCADE | المتجر صاحب القائمة |
| `preset_category`| `VARCHAR(30)` | NOT NULL | التصنيف: `QAT_TYPE`, `QUALITY_GRADE`, `PRICE_UNIT` |
| `preset_value` | `VARCHAR(100)` | NOT NULL | القيمة (عنسي، حوشب، رووس، عوارض، قطل، جمام، سمين، حبه...) |
| `is_custom` | `BOOLEAN` | DEFAULT FALSE | هل أضافها المقاوتي كصنف مخصص جديد بزر الإضافة العلوي |
| `sort_order` | `INT` | DEFAULT 0 | ترتيب العرض في نافذة النشر السريع |
| `created_at` | `TIMESTAMPTZ` | DEFAULT NOW() | تاريخ الإنشاء |
*(قيد فريد مركب: `UNIQUE(store_id, preset_category, preset_value)` لمنع التكرار)*

---

### 3.9 جدول الإعلانات السريعة اليومية (`express_ads`)
| الحقل | النوع | القيود | الوصف |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | PRIMARY KEY DEFAULT gen_random_uuid() | معرف الإعلان السريع |
| `store_id` | `UUID` | REFERENCES stores(id) ON DELETE CASCADE | المقاوتي الناشر |
| `description` | `TEXT` | NOT NULL | تفاصيل العرض المدخلة كتابةً وبحرية |
| `price` | `DECIMAL(12,2)`| NOT NULL | السعر المطلوب |
| `currency` | `VARCHAR(10)` | DEFAULT 'YER_OLD' | العملة (طبعة قديمة / جديدة) |
| `image_url` | `VARCHAR(500)` | NULLABLE | صورة القات المرفقة |
| `ad_date` | `DATE` | NOT NULL DEFAULT CURRENT_DATE | تاريخ نشر الإعلان (لحصر النشر بإعلان واحد يومياً) |
| `is_active` | `BOOLEAN` | DEFAULT TRUE | هل الإعلان معروض اليوم |
| `created_at` | `TIMESTAMPTZ` | DEFAULT NOW() | وقت النشر |
*(قيد فريد صارم: `UNIQUE(store_id, ad_date)` يمنع المقاوتي من نشر أكثر من إعلان سريع واحد في اليوم)*

---

### 3.10 جدول البلاغات ومكافحة الإساءة (`reports`)
| الحقل | النوع | القيود | الوصف |
| :--- | :--- | :--- | :--- |
| `id` | `BIGSERIAL` | PRIMARY KEY | معرف البلاغ |
| `reporter_id` | `UUID` | NOT NULL, REFERENCES users(id) | المستخدم المبلّغ |
| `target_type` | `VARCHAR(20)` | NOT NULL | نوع الهدف: `PRODUCT` أو `STORE` أو `USER` |
| `target_id` | `UUID` | NOT NULL | معرف المنتج أو المتجر المستهدف |
| `reason` | `VARCHAR(50)` | NOT NULL | سبب البلاغ (سعر وهمي، صورة غير حقيقية، نفاذ بضاعة...) |
| `notes` | `TEXT` | NULLABLE | ملاحظات إضافية وتفاصيل ما حدث |
| `status` | `VARCHAR(20)` | DEFAULT 'PENDING' | الحالة: `PENDING`, `INVESTIGATING`, `DISMISSED`, `ACTIONED` |
| `admin_notes` | `TEXT` | NULLABLE | ملاحظات فريق الدعم والمشرفين |
| `action_taken` | `VARCHAR(50)` | NULLABLE | الإجراء اليدوي المتخذ (حذف، إنذار، حظر يدوي) |
| `reviewed_by` | `UUID` | NULLABLE, REFERENCES users(id) | المشرف الذي فحص البلاغ |
| `reviewed_at` | `TIMESTAMPTZ` | NULLABLE | توقيت اتخاذ القرار |
| `created_at` | `TIMESTAMPTZ` | DEFAULT NOW() | توقيت إرسال البلاغ |
*(قيد فريد صارم: `UNIQUE (reporter_id, target_type, target_id)` يمنع المستخدم من تكرار البلاغ على نفس الهدف)*

---

## 4. استراتيجيات الفهرسة وتحسين الأداء (Indexing Strategy)

```sql
-- 1. فهرس مركب سريع جداً لاستعلامات الصفحة الرئيسية والفلترة اليومية
CREATE INDEX idx_products_active_drop ON products (drop_date DESC, stock_status, created_at DESC)
WHERE is_active = TRUE;

-- 2. فهرس للبحث حسب المتجر ومنتجاته النشطة
CREATE INDEX idx_products_store_active ON products (store_id, is_active, created_at DESC);

-- 3. فهرس جغرافي مركب للمتاجر المفتوحة في مديرية وسوق معين
CREATE INDEX idx_stores_geo_active ON stores (governorate_id, district_id, market_id, is_open_today)
WHERE is_open_today = TRUE;

-- 4. فهرس فريد يمنع تكرار المراجعة لنفس المتجر خلال نفس الشهر
CREATE UNIQUE INDEX idx_unique_monthly_user_review ON reviews (user_id, store_id, date_trunc('month', created_at));

-- 5. فهرس نصي متقدم للبحث السريع في أسماء المتاجر والأنواع
CREATE INDEX idx_stores_name_trgm ON stores USING gin (store_name gin_trgm_ops);
CREATE INDEX idx_products_title_trgm ON products USING gin (title gin_trgm_ops);

-- 6. فهرس البحث الذكي بالميزانية المتوفرة والنطاق السعري في السوق
CREATE INDEX idx_products_budget_search ON products (price, drop_date, is_active, stock_status);

-- 7. فهرس فريد لمنع تكرار البلاغات من نفس المستخدم على نفس المنتج أو التاجر
CREATE UNIQUE INDEX idx_reports_dedup ON reports (reporter_id, target_type, target_id);

-- 8. فهرس فريد لضمان حد الإعلان السريع اليومي (إعلان واحد لكل متجر يومياً)
CREATE UNIQUE INDEX idx_express_ads_daily ON express_ads (store_id, ad_date);
```
