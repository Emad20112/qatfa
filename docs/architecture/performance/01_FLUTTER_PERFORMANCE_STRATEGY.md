# استراتيجية أداء تطبيق Flutter وهندسة الواجهات وإدارة الحالة (BLoC)
## 01. Flutter Performance & UI Architecture Strategy | منصة قطفة (Qatfa)

---

## 1. المقدمة وسياق بيئة التشغيل في اليمن

تستهدف منصة **قطفة (Qatfa)** شريحة واسعة من المستهلكين والتجار (المقاوتية) في بيئة ميدانية شديدة الخصوصية تفرض قيوداً عتادية وشبكية صارمة:
- **الأجهزة الاقتصادية محدودة الموارد:** أكثر من **65%** من هواتف المستخدمين في أسواق القات اليمنية تنتمي للفئة الاقتصادية (Infinix Hot/Smart, Tecno Spark/Pop, Itel, Samsung Galaxy A0x) بذاكرة عشوائية تتراوح بين **2GB إلى 3GB RAM** ومعالجات متواضعة (MediaTek Helio A22 / Unisoc)، حيث يؤدي أي تسريب طفيف في الذاكرة (Memory Leak يتجاوز 40MB) إلى انهيار فوري للتطبيق عبر نظام القتل التلقائي لنظام أندرويد (Low Memory Killer / OOM Crash).
- **شبكات الاتصال المتقلبة والمكلفة:** اتصالات تعتمد على باقات بيانات 3G/4G محلية (يمن موبايل، يو، سبأفون) بزمن استجابة مرتفع (150ms - 380ms) ومعدل فقدان حزم ملحوظ يصل إلى 8%؛ مما يفرض ألا تتجاوز حمولة أي شاشة بضعة كيلوبايتات، وإلغاء أي طلب متكرر أو غير مرئي فورياً.
- **الاستخدام الميداني تحت وهج الشمس:** تتصفح الشاشات غالباً بيد واحدة وتحت أشعة الشمس الساطعة في ساعات الذروة (11:30 ص - 4:30 م)، مما يتطلب ثباتاً مطلقاً لمعدل الإطارات عند **60 FPS** (زمن معالجة الإطار أقل من **16.6ms**) لمنع التقطيع البصري أثناء التمرير السريع.

> **القرار المعماري الإلزامي:** اعتماد **BLoC (`flutter_bloc`)** كإطار عمل حصري لإدارة الحالة (State Management) بنمط Clean Architecture، مع استبعاد تام لـ Riverpod أو Provider أو GetX.

---

## 2. المعمارية الهندسية الشاملة للـ BLoC (Clean Architecture Integration)

تتوزع طبقة العرض (Presentation Layer) في تطبيق قطفة وفق نموذج يضمن الفصل التام بين منطق الأعمال (Business Logic) وتصميم الواجهات (Widgets):

```mermaid
flowchart TD
    subgraph Presentation_Layer["طبقة العرض والواجهات (Presentation Layer)"]
        UI_Screens["الشاشات والمكونات (Screens & Widgets)<br/>(DropsFeedView, BudgetSearchModal, StoreDetailView)"]
        BLoCs["مكونات منطق الأعمال (BLoC Layer)<br/>(DropsFeedBloc, SearchFilterBloc, BudgetSearchBloc)"]
    end

    subgraph Domain_Layer["طبقة منطق الأعمال المجرد (Domain Layer)"]
        UseCases["حالات الاستخدام (Use Cases)<br/>(GetDailyDrops, SearchBudgetDrops, ToggleStoreStatus)"]
        RepoContracts["واجهات المستودعات (Repository Interfaces)<br/>(IDropsRepository, IStoresRepository)"]
    end

    subgraph Data_Layer["طبقة البيانات والتخزين (Data Layer)"]
        RepoImpl["تنفيذ المستودعات (Repository Implementations)<br/>(DropsRepositoryImpl, StoresRepositoryImpl)"]
        RemoteSource["المصدر البعيد (Dio HTTP Client + CancelTokens)"]
        LocalSource["المصدر المحلي والكاش (Hive Database + SecureStorage)"]
    end

    UI_Screens ==>|ترسل الأحداث (Dispatch Events)| BLoCs
    BLoCs ==>|تبث الحالات (Emit States)| UI_Screens
    BLoCs -->|تستدعي| UseCases
    UseCases -->|تعتمد على| RepoContracts
    RepoImpl -.->|تطبق| RepoContracts
    RepoImpl --> RemoteSource
    RepoImpl --> LocalSource
    RemoteSource <==>|HTTPS / Brotli| CloudflareEdge["Cloudflare Edge & NestJS Fastify API"]
```

### 2.1 شجرة الـ BLoCs الأساسية وتحديد نطاقاتها (Scoping)
تم تجنب نمط الـ Monolithic State وتفكيك الحالة إلى وحدات BLoC مستقلة وظيفياً:

| اسم الـ BLoC | نطاق التواجد في الشجرة (Scope) | المسؤولية الوظيفية | آلية إدارة دورة الحياة |
| :--- | :--- | :--- | :--- |
| **`DropsFeedBloc`** | Global (أعلى الـ Navigator) | إدارة موجز عروض اليوم، التمرير اللانهائي بالمؤشر، التحديث بالسحب. | دائم طوال الجلسة لضمان حفظ موضع التمرير والبيانات عند الانتقال. |
| **`SearchFilterBloc`** | Feature Route Scoped | إدارة حقل البحث الفوري، الفلاتر الهرمية (محافظة > سوق)، وتصنيفات الجودة. | يُنشأ عند فتح شاشة البحث ويُغلق (`close`) عند مغادرتها لتفريغ الذاكرة. |
| **`BudgetSearchBloc`** | Transient Modal Scoped | محرك البحث بميزانية المشتري مع احتساب نطاق التفاوت اللحظي ($\pm 10\%$). | مرتبط بنافذة البحث بالميزانية المنبثقة، يُلغى فور إغلاق النافذة. |
| **`StoreProfileBloc`** | Route Scoped (لكل متجر) | جلب بيانات مفرش المقاوتي، ساعات العمل، موقعه بالسوق، والتقييمات. | يُنشأ بالمعرف الفريد للمتجر، ويتم تفريغه بمجرد العودة لشاشة الاستكشاف. |
| **`MarketMapBloc`** | Feature Scoped | إدارة دبابيس مفارش السوق في الخريطة التفاعلية، وحالة توفر كل مفرش. | يُنشأ عند فتح خريطة السوق، ويقوم بتفريغ بلاطات الخريطة من الذاكرة عند الخروج. |
| **`MediaViewerBloc`** | Transient Overlay Scoped | إدارة عرض وتكبير الصور عالية الدقة وتشغيل الفيديو الإعلاني القصير. | يُنشأ مع مشغل الوسائط المنبثق ويفرغ الذاكرة فور الإغلاق. |
| **`PublishDropBloc`** | Flow Scoped (للمقاوتي) | واجهة النشر السريع (التقاط الصورة، اختيار الصنف المجهز، الرفع). | يغلق فور إتمام النشر لتنظيف مسار الصورة المضغوطة المؤقتة. |

---

## 3. معالجة الأحداث المتزامنة: الإلغاء ومنع التكرار (Event Transformers)

تعتمد منصة قطفة على حزمة **`bloc_concurrency`** للتحكم الصارم في معالجة الأحداث المتزامنة وتفادي تسريب باقات الإنترنت:

```
                  ┌─────────────────────────────────────────────────────────┐
                  │          محولات الأحداث في قطفة (Event Transformers)    │
                  └────────────────────────────┬────────────────────────────┘
                                               │
               ┌───────────────────────────────┴───────────────────────────────┐
               ▼                                                               ▼
   ┌───────────────────────┐                                       ┌───────────────────────┐
   │     restartable()     │                                       │      droppable()      │
   ├───────────────────────┤                                       ├───────────────────────┤
   │ - البحث الفوري        │                                       │ - التمرير اللانهائي   │
   │ - تغيير السوق أو الفلتر│                                       │   (FetchNextPage)     │
   │ - إلغاء الطلب السابق  │                                       │ - نقرات أزرار الإجراء │
   │   فورياً عبر          │                                       │ - تجاهل النقرات حتى   │
   │   CancelToken         │                                       │   اكتمال العملية      │
   └───────────────────────┘                                       └───────────────────────┘
```

### 3.1 معالجة البحث وإلغاء الطلبات المتداخلة عبر `restartable`
عندما يكتب المستخدم في حقل البحث أو يغير السوق الجغرافي بسرعة، يؤدي كل حدث جديد إلى إلغاء معالجة الحدث السابق فورياً:
```dart
EventTransformer<E> restartableDebounce<E>(Duration duration) {
  return (events, mapper) {
    return events
        .debounceTime(duration)
        .switchMap(mapper); // إلغاء أي Stream قيد التنفيذ فور وصول حدث جديد
  };
}
```
يتكامل هذا المحول مع **`CancelToken`** الخاص بمكتبة `Dio` في طبقة البيانات؛ بحيث يتم قطع اتصال الـ TCP مع السيرفر فور كتابة حرف جديد، مما يوفر باقة الإنترنت ويمنع وصول استجابات قديمة تلغي الاستجابة الأحدث (Race Conditions).

### 3.2 منع التكرار في التمرير والإجراءات عبر `droppable`
في أحداث التمرير اللانهائي (`LoadMoreDrops`) ونقر أزرار الاتصال أو النشر:
```dart
on<LoadMoreDrops>(
  _onLoadMoreDrops,
  transformer: droppable(), // تجاهل أي حدث تمرير جديد طالما الطلب الحالي لم يكتمل بعد
);
```
يمنع هذا المحول إرسال طلبات مكررة إلى الـ API عند اهتزاز إصبع المستخدم أثناء التمرير السريع.

---

## 4. محرك البحث الفوري والفلترة الذكية بالميزانية

### 4.1 نافذة التهدئة وتطبيع النصوص (Debouncing & Arabic Normalization)
- **نافذة Debouncing:** تم ضبطها على **350ms**؛ وهي المدة المثلى التي توازن بين سرعة استجابة التطبيق وشعور المستخدم بالفورية، وبين منع إرسال طلبات غير مكتملة مع كل نقرة حرف.
- **تطبيع النصوص العربية على جهاز المستخدم قبل الإرسال:**
  لتفادي إرسال استعلامات عقيمة للسيرفر، يتم تطبيع النص محلياً عبر دالة مدمجة:
  ```dart
  String normalizeArabicSearch(String text) {
    return text
        .trim()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '') // إزالة التشكيل
        .replaceAll(RegExp(r'[إأآا]'), 'ا') // توحيد الألفات
        .replaceAll('ة', 'ه') // توحيد التاء المربوطة
        .replaceAll('ى', 'ي') // توحيد الياء
        .replaceAll('ـ', ''); // إزالة الكشيدة التطويلية
  }
  ```

### 4.2 تصميم حالات وأحداث البحث بالميزانية (`BudgetSearchBloc`)
```dart
// الأحداث (Events)
sealed class BudgetSearchEvent extends Equatable {
  const BudgetSearchEvent();
}

final class TargetBudgetChanged extends BudgetSearchEvent {
  final double budget;
  final double tolerancePercentage; // افتراضياً 0.10 (±10%)
  final int? marketId;
  final String? preferredUnit; // الافتراضي: حبة

  const TargetBudgetChanged({
    required this.budget,
    this.tolerancePercentage = 0.10,
    this.marketId,
    this.preferredUnit = 'حبة',
  });

  @override
  List<Object?> get props => [budget, tolerancePercentage, marketId, preferredUnit];
}

// الحالات (States)
sealed class BudgetSearchState extends Equatable {
  const BudgetSearchState();
}

final class BudgetSearchInitial extends BudgetSearchState {
  @override
  List<Object?> get props => [];
}

final class BudgetSearchLoading extends BudgetSearchState {
  @override
  List<Object?> get props => [];
}

final class BudgetSearchSuccess extends BudgetSearchState {
  final List<DropItemEntity> items;
  final double targetBudget;
  final double minBudget;
  final double maxBudget;
  final String? nextCursor;
  final bool hasMore;

  const BudgetSearchSuccess({
    required this.items,
    required this.targetBudget,
    required this.minBudget,
    required this.maxBudget,
    this.nextCursor,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [items, targetBudget, minBudget, maxBudget, nextCursor, hasMore];
}
```

---

## 5. التمرير اللانهائي الموثوق والتكامل مع Keyset Cursor Pagination

### 5.1 آلية مراقبة موضع التمرير (Threshold Trigger)
يتم رصد موضع التمرير في `CustomScrollView` عبر `ScrollController`، وإطلاق حدث جلب الصفحة التالية عند بلوغ عتبة **85%** من طول القائمة لتأمين تحميل سلس لا يشعر به المستخدم:

```dart
void _setupScrollListener() {
  _scrollController.addListener(() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    // تشغيل الجلب المسبق قبل الوصول لنهاية القائمة بـ 15%
    if (currentScroll >= (maxScroll * 0.85)) {
      context.read<DropsFeedBloc>().add(const LoadMoreDrops());
    }
  });
}
```

### 5.2 معالجة المؤشرات (Cursor Mechanics) في BLoC
- لا يتم استخدام `page` أو `offset` نهائياً لتفادي مشكلة انزياح البيانات وتكرارها (Page Drift) عند نشر قطفات جديدة أثناء تصفح العميل.
- يحتفظ الـ BLoC بحقل `nextCursor` المشفر (Base64url). عند إطلاق `LoadMoreDrops`، يتم تمرير المؤشر إلى الـ Repository لجلب الدفعة التالية وإلحاقها بالقائمة الحالية:
```dart
Future<void> _onLoadMoreDrops(
  LoadMoreDrops event,
  Emitter<DropsFeedState> emit,
) async {
  final currentState = state;
  if (currentState is! DropsFeedSuccess || !currentState.hasMore || currentState.isLoadingMore) {
    return;
  }

  emit(currentState.copyWith(isLoadingMore: true));

  final result = await _getDailyDropsUseCase(
    cursor: currentState.nextCursor,
    limit: 20,
    marketId: currentState.selectedMarketId,
  );

  result.fold(
    (failure) => emit(currentState.copyWith(isLoadingMore: false, errorMessage: failure.message)),
    (paginatedData) {
      emit(currentState.copyWith(
        items: List.of(currentState.items)..addAll(paginatedData.items),
        nextCursor: paginatedData.nextCursor,
        hasMore: paginatedData.hasMore,
        isLoadingMore: false,
      ));
    },
  );
}
```

---

## 6. استراتيجية الصور وحماية الذاكرة من الانهيار (OOM Safeguards)

فك تشفير صور الهواتف الذكية الحديثة بدقتها الأصلية داخل ذاكرة أندرويد هو السبب الأول لانهيار تطبيقات الموبايل على الأجهزة الاقتصادية:
$$\text{Memory Footprint} = \text{Width} \times \text{Height} \times 4\text{ Bytes (RGBA\_8888)}$$
صورة كاميرا عادية بدقة $4000 \times 3000$ تستهلك فورياً **48 ميجابايت من الذاكرة العشوائية**! عرض 5 صور فقط دون تحجيم كفيل بامتلاء ذاكرة التطبيق والتسبب في OOM Crash فوري على هاتف Infinix 2GB RAM.

### 6.1 الإلزام المعماري الصارم: تحجيم فك التشفير في الذاكرة
يحظر حظراً تاماً استخدام `Image.network` المجرد. يتم إلزام استخدام مكون موحد يعتمد على **`cached_network_image`** مع تمرير معاملي التحجيم في الذاكرة (`memCacheWidth` و `memCacheHeight`):

```dart
class QatfaOptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final String? blurHash;

  const QatfaOptimizedImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.blurHash,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      // تقييد أبعاد فك التشفير في الذاكرة العشوائية للبطاقة
      memCacheWidth: 720,
      memCacheHeight: 405,
      // تقييد أبعاد التخزين المؤقت على القرص المحلي
      maxWidthDiskCache: 1080,
      maxHeightDiskCache: 608,
      placeholder: (context, url) => blurHash != null
          ? BlurHash(hash: blurHash!)
          : Container(
              color: const Color(0xFFF0EBE1), // لون تراثي عقيقي هادئ
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
      errorWidget: (context, url, error) => Container(
        color: const Color(0xFFECECEC),
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}
```
**النتيجة الهندسية:** ينخفض استهلاك الصورة الواحدة في الذاكرة من **48MB** إلى **1.1MB** فقط (تخفيض بنسبة **97.7%**)، مما يتيح التمرير في آلاف العروض دون أي ارتفاع في استهلاك RAM.

### 6.2 ضبط سقف كاش الذاكرة والتنظيف عند الضغط (Memory Pressure)
في ملف `main.dart`، يتم وضع سقف صارم لذاكرة الصور والتفاعل مع إشارات نظام التشغيل:
```dart
void configureMemoryLimits() {
  PaintingBinding.instance.imageCache.maximumSize = 100; // حد أقصى 100 صورة
  PaintingBinding.instance.imageCache.maximumSizeBytes = 60 * 1024 * 1024; // سقف 60 ميجابايت فقط
}

// الاستماع لضغط الذاكرة من نظام أندرويد
class AppLifecycleObserver with WidgetsBindingObserver {
  @override
  void didHaveMemoryPressure() {
    // تفريغ كاش الصور فوراً عند استشعار ضغط في الذاكرة من النظام
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}
```

---

## 7. استراتيجية الفيديو الخفيفة والتنقل بسلاسة

### 7.1 معمارية المشغل الفردي وتتبع الرؤية (Visibility-Driven Single Player)
لتفادي استنزاف الذاكرة وانهيار فك التشفير العتادي للفيديو (MediaCodec Exhaustion):
1. **مشغل واحد نشط فقط (Single Active Video Player):** حظر إنشاء عدة كائنات `VideoPlayerController` داخل القائمة؛ يتم تشغيل مشغل واحد فقط عبر مدير وسائط مركزي.
2. **التشغيل عند الرؤية فقط عبر `VisibilityDetector`:** لا يتم تهيئة المشغل إلا عندما تصبح بطاقة العرض مرئية في الشاشة بنسبة **$\ge 70\%$**.
3. **التشغيل الافتراضي الصامت:** يبدأ التشغيل صامتاً تماماً (Muted) لتوفير موارد فك تشفير الصوت وتقليل إزعاج المستخدم في الأماكن العامة، مع زر عائم لتفعيل الصوت يدوياً.
4. **التفريغ الفوري (Instant Disposal):** فور انخفاض نسبة ظهور البطاقة عن **50%** أثناء التمرير، يتم إيقاف التشغيل فورياً وتحرير موارد المشغل (`controller.dispose()`).

---

## 8. تحسين إعادة بناء الواجهات (Widget Rebuilds Optimization)

لتحقيق ثبات معدل الإطارات عند **60 FPS** تحت أشعة شمس أسواق القات:
1. **استخدام `BlocSelector` بدلاً من `BlocBuilder` العام:**
   يحظر إعادة بناء الشاشة بأكملها عند تغير حالة ثانوية (مثل تغير مؤشر التمرير أو حالة زر فرعي). يتم استخلاص الحقل المطلوب حصراً:
   ```dart
   BlocSelector<DropsFeedBloc, DropsFeedState, bool>(
     selector: (state) => state is DropsFeedSuccess && state.isLoadingMore,
     builder: (context, isLoadingMore) {
       if (!isLoadingMore) return const SizedBox.shrink();
       return const Padding(
         padding: EdgeInsets.all(16.0),
         child: CircularProgressIndicator(),
       );
     },
   )
   ```
2. **استخدام `RepaintBoundary` لعزل البطاقات الحركية:**
   إحاطة بطاقة العرض (`DropCardWidget`) بـ `RepaintBoundary` لعزل عمليات إعادة الرسم (Repaint Layer) الخاصة بعداد الوقت ("منذ 10 دقائق") أو أزرار التفاعل عن خلفية القائمة، مانعاً إعادة رسم القائمة بأكملها.
3. **اعتماد المشيدات الثابتة (`const Constructors`):**
   تطبيق قواعد فحص صارمة في `analysis_options.yaml` تلزم استخدام `const` في كافة المكونات الثابتة لتفادي إعادة تخصيص الذاكرة مع كل إطار.
4. **عزل القوائم في `CustomScrollView` و `SliverList`:**
   استخدام `SliverList` مع خاصية `addAutomaticKeepAlives: false` و `addRepaintBoundaries: true`، مما يسمح لنظام Flutter بتفريغ الـ Widgets التي تخرج من مجال الرؤية فورياً وإعادة استخدام عناصر الواجهة بكفاءة (Virtualization).

---

## 9. استبقاء موضع التمرير وحالة التصفح (State & Scroll Retention)

### 9.1 معمارية التنقل دون فقدان البيانات
عندما يتصفح المشتري عروض القات وينتقل إلى شاشة تفاصيل القطفة أو الملف الشخصي للمقاوتي ثم يضغط زر الرجوع، يجب ألا يُعاد تحميل القائمة أو يفقد موضع تمريره:
1. **عزل حالة الـ BLoC في الذاكرة:** يبقى `DropsFeedBloc` نشطاً في الذاكرة لأنه يقع أعلى مسار التنقل (`Navigator`).
2. **حفظ موضع التمرير عبر `PageStorageKey`:**
   تزويد الـ `CustomScrollView` بمفتاح تخزين فريد يضمن استعادة موضع البكسلات بدقة تامة:
   ```dart
   CustomScrollView(
     key: const PageStorageKey<String>('drops_feed_scroll_key'),
     controller: _scrollController,
     slivers: [...],
   )
   ```
3. **تطبيق `AutomaticKeepAliveClientMixin` في تبويبات الشاشة الرئيسية:**
   منع إعادة بناء محتوى التبويبات ("الرئيسية"، "أسواق القات"، "متابعاتي") عند التنقل الأفقي بينها.

---

## 10. عزل العمليات الثقيلة وتوفير البطارية (Background Isolates)

### 10.1 ضغط ومعالجة الصور في خلفية النظام
عندما يلتقط المقاوتي صورة للقات لنشرها، تكون الصورة الناتجة من الكاميرا بحجم يتراوح بين 3MB إلى 8MB. معالجة وتصغير هذه الصورة وضغطها بصيغة WebP داخل الخيط الرئيسي (Main UI Thread) يؤدي إلى تجميد الواجهة (App Freeze) لسقوط مئات الإطارات.
- **الحل المعتمد:** عزل الضغط بالكامل على خيط خلفي مستقل (Background Isolate / C++ Thread) باستخدام مكتبة `flutter_image_compress`:
```dart
Future<File?> compressImageInIsolate(File rawFile) async {
  final targetPath = '${rawFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.webp';
  
  final compressedXFile = await FlutterImageCompress.compressAndGetFile(
    rawFile.absolute.path,
    targetPath,
    quality: 75,
    minWidth: 1080,
    minHeight: 1080,
    format: CompressFormat.webp,
    keepExif: false, // حذف بيانات EXIF لتعزيز الخصوصية وتقليص الحجم
  );
  
  return compressedXFile != null ? File(compressedXFile.path) : null;
}
```
ينتج عن ذلك ملف WebP فائق الجودة بحجم **أقل من 95KB** يتم رفعه في أقل من ثانيتين على شبكات 3G دون حدوث أي وميض أو تجميد في واجهة المستخدم.

### 10.2 ترشيد استهلاك البطارية ونظام تحديد المواقع (GPS Strategy)
- يحظر حظراً تاماً تشغيل تتبع الموقع الجغرافي المستمر في الخلفية (Background GPS tracking).
- يتم طلب إحداثيات الموقع لمرة واحدة فقط وبأقل دقة مقبولة (`LocationAccuracy.medium`) عند فتح شاشة الخريطة، مع الاعتماد الأساسي على الاختيار اليدوي السريع عبر الدليل الهرمي (المحافظة > السوق)، مما يحافظ على بطارية هواتف المقاوتية أثناء عملهم الطويل في السوق المفتوح.

---

## 11. الصمود أمام انقطاع الشبكات وضعف الاتصال (Offline-First Resilience)

### 11.1 سياسة التعامل مع البيانات الحية مقابل الكاش
توافقاً مع ميثاق المنتج وطبيعة سوق القات اليومي:
- **عروض القطفة (Daily Drops):** هي عروض حية حصراً (Live-First). يحظر عرض عروض الأمس المخزنة محلياً على أنها عروض متاحة اليوم لمنع الاتصال بمقاوتية نفدت بضاعتهم.
- **التعامل مع الانقطاع الفجائي للإنترنت أثناء التصفح:**
  إذا انقطع الاتصال أثناء تصفح المستخدم، يعرض التطبيق آخر بيانات تم جلبها في نفس الجلسة مع إظهار **شريط تنبيهي أصفر عائم (Offline Warning Banner)** في أعلى الشاشة:
  > *"تنبيه: أنت تتصفح نسخة محفوظة بدون اتصال؛ قد تكون بعض العروض قد نفدت أو تغيرت أسعارها."*
- **البيانات المرجعية الثابتة (Reference Data):**
  يتم تخزين بيانات المحافظات، المديريات، والأسواق ومواقع المفارش محلياً في قاعدة بيانات **Hive** خفيفة وسريعة، وتحدث مرة واحدة أسبوعياً أو عند إشعار السيرفر بوجود تحديث.

### 11.2 بروتوكول إعادة المحاولة الذكي (Retry with Exponential Backoff & Jitter)
في طبقة الـ `Dio Interceptor`:
```dart
class RetryInterceptor extends Interceptor {
  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retryCount'] < 3) {
      final retryCount = (err.requestOptions.extra['retryCount'] ?? 0) + 1;
      err.requestOptions.extra['retryCount'] = retryCount;

      // احتساب التأخير بأسلوب التراجع الأسي مع عشوائية لتفادي هجوم Thundering Herd
      final delayMs = (pow(2, retryCount) * 500) + Random().nextInt(300);
      await Future.delayed(Duration(milliseconds: delayMs));

      try {
        final response = await Dio().fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return super.onError(err, handler);
      }
    }
    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError;
  }
}
```

---

## 12. اختبارات الأداء ومعايير القبول الهندسية (Testing & SLAs)

| المعيار الهندسي (Metric) | الأداة المستهدفة (Profiling Tool) | القيمة المستهدفة للأجهزة الاقتصادية | معيار القبول الصارم |
| :--- | :--- | :--- | :--- |
| **زمن التشغيل البارد (Cold Start)** | Flutter DevTools CPU Profiler | $\le 1.2\text{ s}$ | $\le 1.8\text{ s}$ على أجهزة أندرويد 8.0 |
| **معدل الإطارات أثناء التمرير** | DevTools Performance Overlay | **60 FPS** مستمر | نسبة الإطارات الساقطة (Jank) $\le 1\%$ |
| **زمن رسم الإطار (Frame Time)** | Performance Trace Timeline | $\le 12\text{ ms}$ | ألا يتجاوز إطلاق الرسوم حاجز $16.6\text{ ms}$ |
| **استهلاك الذاكرة العشوائية (RAM)** | Memory Profiler (Snapshot) | $\le 95\text{ MB}$ للتشغيل العام | سقف أقصى $\le 125\text{ MB}$ في أوج تصفح الصور |
| **حجم حزمة التطبيق (Release APK)** | `flutter build apk --split-per-abi` | $\le 16.5\text{ MB}$ (ARM64) | سقف أقصى $\le 18\text{ MB}$ |
| **استهلاك المعالج أثناء الخمول** | Android Profiler CPU | **0.0%** | $\le 0.5\%$ |

---
> **الخلاصة:** يوفر هذا التصميم المعماري لتطبيق Flutter أقصى استقرار وأداء ممكنين على الهواتف الاقتصادية الأكثر انتشاراً في اليمن، ويحمي التطبيق من انهيارات الذاكرة، ويضمن تصفحاً فائق السرعة يوفر باقات بيانات المستخدمين ويقاوم تقلبات الاتصال الميداني.
