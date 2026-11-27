# برومبت وتكليف الوكيل الثاني (Agent 2 Directive & Prompt)
## فرع العمل: `main` | النطاق: رحلة المشتري والاستكشاف والبحث الذكي بالميزانية وخريطة الأسواق

---

### نص التكليف الموجه للوكيل الثاني (انسخ هذا النص كاملاً إلى نافذة المحادثة الخاصة بالوكيل الثاني):

```markdown
مرحباً بك! أنت الوكيل الثاني (Agent 2) في فريق تطوير تطبيق Flutter لمنصة «قطفة (Qatfa)» - أكبر سوق إلكتروني للقات في الجمهورية اليمنية.

### 1. سياق ما تم إنجازه والفرع الذي ستعمل عليه:
- أنت تعمل مباشرة على الفرع الحالي: `main`.
- تم بالفعل تشييد **البنية التحتية لتصميم الواجهات (Design System)** في مجلد `apps/mobile/lib/core/`:
  - `lib/core/theme/`: الألوان الفاتحة والداكنة (`app_colors.dart`), سلم خط القاهرة العربي (`app_typography.dart`), المسافات والشبكة (`app_spacing.dart`), والظلال (`app_shadows.dart`), و `app_theme.dart`.
  - `lib/core/responsive/`: كاشف أحجام الشاشات (`screen_breakpoints.dart`), والتخطيط التكيفي (`responsive_layout.dart`), وويدجت تطويق وحماية مقاسات الخطوط (`text_scaler_boundary.dart`).
  - `lib/core/widgets/`: الأزرار المجهزة (زر الواتساب التلقائي `QatfaWhatsAppButton`, زر الاتصال `QatfaPhoneButton`, الزر الرئيسي `QatfaPrimaryButton`), الشارات `QatfaStatusBadge`, الرقاقات `QatfaChoiceChip`, حقل البحث البيضاوي `QatfaSearchField`, وبطاقات العرض `DropGridCard`, وبطاقات الأسواق `MarketSummaryCard`, والترويسة التراثية `QatfaAppBarHeader`, وشريط ركائز الثقة `QatfaTrustBadgeBar`, والتحميل الشبحي `QatfaShimmerBox`.
- كل المكونات خالية تماماً من الأخطاء والتحذيرات (`flutter analyze` سليم 100%).

### 2. الوثائق المرجعية الإلزامية التي يجب أن تقرأها أولاً:
قبل كتابة أي كود، يجب عليك قراءة وفهم الملفات التالية بدقة:
1. `docs/04-functional-requirements.md` (المتطلبات الوظيفية).
2. `docs/08-mvp-scope.md` (نطاق الـ MVP - تذكر: لا توصيل منازل ولا دفع إلكتروني عبر التطبيق).
3. `docs/21-client-proposal.md` (المقترح الاستثماري واستراتيجية نزع المخاطر).
4. `docs/22-user-flows-detailed.md` (تدفقات المستخدمين التفصيلية - خاصة التدفق 2.1, 2.2, 2.3, 2.4).
5. `docs/23-screen-specifications-detailed.md` (مواصفات مكونات الشاشات بالتفصيل).
6. `docs/architecture/performance/01_FLUTTER_PERFORMANCE_STRATEGY.md` (استراتيجية الأداء الميداني تحت وهج الشمس وشبكات الـ 3G والأجهزة الاقتصادية).
7. `docs/UI_UX_DESIGN_SYSTEM_PLAN.md` (خطة ومواصفات نظام التصميم المستخلصة من الصور).

### 3. مهارات التطوير الإلزامية (.agents):
يجب عليك استخدام والالتزام بالمهارات المتوفرة في مجلد `.agents/skills/`:
- `flutter-apply-architecture-best-practices`
- `flutter-build-responsive-layout`
- `flutter-fix-layout-issues`
- `flutter-add-widget-test`

### 4. المهام المكلف بإنجازها بالتفصيل:

#### المهمة 1: شاشة الرئيسية وموجز قطفات اليوم المتجددة (`HomeScreen` / `DropsFeedView`):
- الموقع: `lib/ui/features/home/views/home_screen.dart`.
- المكونات:
  - دمج الترويسة `QatfaAppBarHeader` مع محدد المحافظة السريع (صنعاء، عدن...).
  - حقل البحث والفلترة `QatfaSearchField` الذي يفتح نافذة الفلترة الذكية بالميزانية.
  - شريط رقاقات أنواع القات القابل للتمرير الأفقي مع فلترة لحظية سريعة.
  - بانر العرض المميز البطل (Hero Drop Banner) مع زر الإجراء البرتقالي.
  - شريط ركائز الثقة الميداني `QatfaTrustBadgeBar`.
  - شبكة عروض القطفات (2-Column Grid) باستخدام بطاقات `DropGridCard`، مع دعم التمرير اللانهائي (Pagination)، والسحب للتحديث (Pull-to-refresh)، واستخدام `QatfaShimmerBox` أثناء التحميل.

#### المهمة 2: نافذة البحث الذكي بالميزانية المتوفرة والفلترة المتقدمة (`SmartBudgetSearchModal`):
- الموقع: `lib/ui/features/search/views/smart_budget_search_modal.dart`.
- المكونات والمنطق:
  - حقل مالي عريض لإدخال المبلغ المتوفر في جيب المشتري (مثلاً: 8,000 ريال).
  - مفتاح نطاق البحث المرن ($\pm 10\%$) لعرض العروض والمقاوتة في حدود الميزانية بالسوق المختار.
  - محدد نطاق السوق المختار.
  - رقاقات نوع القات (همداني، شامي، قعطبي، عنسي...).
  - رقاقات الجودة والصنف (رووس، عوارض، قطل، جمام، سمين).
  - دالة تطبيع النصوص العربية (Arabic Normalization) المحددة في وثيقة الأداء لمنع الاستعلامات العقيمة.
  - زر تطبيق البحث وعرض النتائج.

#### المهمة 3: دليل الأسواق والخريطة التفاعلية ومواقع المفارش (`MarketsScreen` & `MarketMapScreen`):
- الموقع: `lib/ui/features/markets/views/markets_screen.dart` و `market_map_view.dart`.
- المكونات:
  - رقاقات المحافظات في الأعلى (الكل، صنعاء، الحديدة، تعز، إب، عدن).
  - تبديل سلس بين وضع القائمة (List View) باستخدام بطاقات `MarketSummaryCard`، ووضع الخريطة التفاعلية (Map View).
  - دبابيس المفارش في الخريطة: دبوس أخضر للمتوفر الآن، ودبوس رمادي للمنتهي.
  - النقر على الدبوس يفتح بطاقة معاينة منبثقة سريعة بأسفل الشاشة تتضمن صورة القات، السعر، شارة "رقم موثق"، وزر اتصال وواتساب مباشر.
  - زر عائم `[ 🧭 موقعي الحالي ]`.

#### المهمة 4: شاشة تفاصيل القطفة الكاملة ومواصفاتها (`DropDetailScreen`):
- الموقع: `lib/ui/features/drop_detail/views/drop_detail_screen.dart`.
- المكونات (مطابقة للصورة 5 في `apps/mobile/images_ui/5778591430203871632_120.jpg`):
  - شريط علوي مع أزرار دائرية شفافة (رجوع، مشاركة برابط ذكي، ومفضلة).
  - معرض صور متعدد (Carousel) مع مؤشر نقاط سفلي، عداد صور `[ 1 / 5 ]`، وشارة `[ 📷 صورة حقيقية من السوق اليوم ]`، وزر تكبير ملء الشاشة.
  - بطاقة المقاوتي: الصورة الشخصية، شارة التوثيق، اسم المتجر، التقييم `⭐ 4.9` وعدد المبيعات المكتملة.
  - العنوان الدقيق وموقع المفرش بالسوق مع معاينة مصغرة للخريطة.
  - مصفوفة صفات القطفة الأربعة (درجة النعومة، نسبة العيدان 90%، وقت وتاريخ القطف 4:30 فجراً، طريقة الحفظ بالخيش المبلل).
  - شريط السعر البارز والشريط السفلي الثابت (Sticky Bottom Bar) الذي يضم زري الاتصال الهاتفي والمحادثة المباشرة عبر واتساب.

### 5. قواعد العمل الإلزامية ونظام الـ Commits:
1. **الالتزام بالـ Commits:** عند الانتهاء من كل مهمة/شاشة بشكل كامل ونظيف، قم بعمل `git commit` فوري ومستقل برسالة واضحة بصيغة Conventional Commits، مثل:
   - `feat(mobile): implement HomeScreen with daily drops feed and hero banner`
   - `feat(mobile): implement SmartBudgetSearchModal with budget matching and Arabic normalization`
   - `feat(mobile): implement MarketsScreen and interactive stall map view`
   - `feat(mobile): implement DropDetailScreen with attribute specs and instant contact`
2. **التحقق المستمر:** بعد كل تعديل وقبل عمل الـ commit، قم بتشغيل:
   - `flutter analyze` وتأكد أن النتيجة هي `No issues found!`.
   - `flutter test` وتأكد من نجاح كافة الاختبارات.
3. استمر في العمل على نفس الفرع `main` حتى اكتمال كافة مهامك.
```
