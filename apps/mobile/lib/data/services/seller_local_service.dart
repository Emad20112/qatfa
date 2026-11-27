import '../../domain/models/seller_models.dart';

/// خدمة الكاميرا، ضغط WebP الفوري، والقوائم المجهزة للمقاوتي
class SellerLocalService {
  SellerPresets _presets = const SellerPresets(
    availableTypes: [
      'عنسي',
      'همداني',
      'شامي',
      'أرحبي',
      'حوشب',
      'قعطبي',
      'رداعي',
      'غيلي',
      'صعدي',
      'يافعي',
    ],
    selectedTypes: ['عنسي', 'همداني', 'شامي', 'أرحبي', 'حوشب'],
    availableGrades: [
      'رووس',
      'عوارض',
      'قطل',
      'جمام',
      'سمين',
      'قلايد',
    ],
    selectedGrades: ['رووس', 'عوارض', 'قطل'],
    availableUnits: [
      'حبة',
      'كيلو',
      'قبضة',
      'قلايد',
      'كيس',
      'شظية',
      'باقة',
    ],
    selectedUnits: ['حبة', 'كيلو', 'قبضة'],
  );

  bool _isStoreOpen = true;
  bool _hasUsedDailyExpressAd = false;

  final List<SellerDropItem> _drops = [
    SellerDropItem(
      id: 'drop-101',
      qatType: 'عنسي',
      qualityGrade: 'رووس',
      unit: 'حبة',
      priceYer: 14000,
      isAvailable: true,
      publishedAt: DateTime(2026, 11, 26, 11, 45),
      media: CapturedMediaInfo(
        id: 'media-101',
        fileName: 'ansi_ruoos_morning.webp',
        originalSizeKb: 3840,
        compressedWebpSizeKb: 78,
        capturedAt: DateTime(2026, 11, 26, 11, 44),
      ),
    ),
    SellerDropItem(
      id: 'drop-102',
      qatType: 'حوشب',
      qualityGrade: 'قطل',
      unit: 'قبضة',
      priceYer: 8000,
      isAvailable: false,
      publishedAt: DateTime(2026, 11, 26, 10, 30),
      media: CapturedMediaInfo(
        id: 'media-102',
        fileName: 'hawshab_qatal.webp',
        originalSizeKb: 4120,
        compressedWebpSizeKb: 84,
        capturedAt: DateTime(2026, 11, 26, 10, 29),
      ),
    ),
  ];

  Future<SellerPresets> fetchPresets() async => _presets;

  Future<SellerPresets> savePresets(SellerPresets updated) async {
    _presets = updated;
    return _presets;
  }

  Future<bool> fetchMasterStoreOpen() async => _isStoreOpen;

  Future<bool> setMasterStoreOpen(bool isOpen) async {
    _isStoreOpen = isOpen;
    return _isStoreOpen;
  }

  Future<bool> hasUsedDailyExpressAd() async => _hasUsedDailyExpressAd;

  Future<List<SellerDropItem>> fetchSellerDrops() async {
    return List<SellerDropItem>.unmodifiable(_drops);
  }

  /// التقاط صورة حية وضغطها تلقائياً إلى صيغة WebP (< 100KB، 1080px)
  Future<CapturedMediaInfo> captureAndCompressWebP({String? hintLabel}) async {
    final now = DateTime.now();
    final safeTag = (hintLabel ?? 'drop')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
    return CapturedMediaInfo(
      id: 'media-${now.millisecondsSinceEpoch}',
      fileName: 'qatfa_${safeTag}_${now.millisecondsSinceEpoch}.webp',
      originalSizeKb: 4250,
      compressedWebpSizeKb: 76,
      widthPx: 1080,
      heightPx: 810,
      capturedAt: now,
    );
  }

  Future<SellerDropItem> publishDrop(SellerDropItem item) async {
    if (item.isExpressAd) {
      _hasUsedDailyExpressAd = true;
    }
    _drops.insert(0, item);
    return item;
  }

  Future<SellerDropItem?> toggleProductAvailability(String dropId) async {
    final index = _drops.indexWhere((element) => element.id == dropId);
    if (index == -1) return null;
    final current = _drops[index];
    final updated = current.copyWith(isAvailable: !current.isAvailable);
    _drops[index] = updated;
    return updated;
  }
}
