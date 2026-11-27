import '../../domain/models/seller_models.dart';
import '../services/seller_local_service.dart';

/// مستودع بيانات المقاوتي والنشر السريع (Single Source of Truth)
class SellerRepository {
  final SellerLocalService _service;

  SellerRepository({SellerLocalService? service})
      : _service = service ?? SellerLocalService();

  Future<SellerPresets> getPresets() => _service.fetchPresets();

  Future<SellerPresets> savePresets(SellerPresets presets) =>
      _service.savePresets(presets);

  Future<SellerPresets> addCustomPresetItem({
    required PresetCategory category,
    required String label,
  }) async {
    final trimmed = label.trim();
    final current = await _service.fetchPresets();
    if (trimmed.isEmpty) return current;

    switch (category) {
      case PresetCategory.qatType:
        final available = List<String>.from(current.availableTypes);
        final selected = List<String>.from(current.selectedTypes);
        if (!available.contains(trimmed)) available.insert(0, trimmed);
        if (!selected.contains(trimmed)) selected.insert(0, trimmed);
        return _service.savePresets(
          current.copyWith(availableTypes: available, selectedTypes: selected),
        );
      case PresetCategory.qualityGrade:
        final available = List<String>.from(current.availableGrades);
        final selected = List<String>.from(current.selectedGrades);
        if (!available.contains(trimmed)) available.insert(0, trimmed);
        if (!selected.contains(trimmed)) selected.insert(0, trimmed);
        return _service.savePresets(
          current.copyWith(availableGrades: available, selectedGrades: selected),
        );
      case PresetCategory.saleUnit:
        final available = List<String>.from(current.availableUnits);
        final selected = List<String>.from(current.selectedUnits);
        if (!available.contains(trimmed)) available.insert(0, trimmed);
        if (!selected.contains(trimmed)) selected.insert(0, trimmed);
        return _service.savePresets(
          current.copyWith(availableUnits: available, selectedUnits: selected),
        );
    }
  }

  /// إضافة عدة أنواع/أصناف/وحدات دفعة واحدة من نافذة الإضافة السريعة
  Future<SellerPresets> addCustomPresetItems({
    Iterable<String> qatTypes = const [],
    Iterable<String> qualityGrades = const [],
    Iterable<String> saleUnits = const [],
  }) async {
    final current = await _service.fetchPresets();

    List<String> merged(List<String> source, Iterable<String> incoming) {
      final result = List<String>.from(source);
      for (final raw in incoming) {
        final value = raw.trim();
        if (value.isEmpty) continue;
        if (!result.contains(value)) result.insert(0, value);
      }
      return result;
    }

    final availableTypes = merged(current.availableTypes, qatTypes);
    final availableGrades = merged(current.availableGrades, qualityGrades);
    final availableUnits = merged(current.availableUnits, saleUnits);

    if (availableTypes.isEmpty || availableGrades.isEmpty) {
      return current;
    }

    return _service.savePresets(
      current.copyWith(
        availableTypes: availableTypes,
        selectedTypes: merged(current.selectedTypes, qatTypes),
        availableGrades: availableGrades,
        selectedGrades: merged(current.selectedGrades, qualityGrades),
        availableUnits: availableUnits,
        selectedUnits: availableUnits.isEmpty
            ? current.selectedUnits
            : merged(current.selectedUnits, saleUnits),
      ),
    );
  }

  Future<bool> getMasterStoreOpen() => _service.fetchMasterStoreOpen();

  Future<bool> setMasterStoreOpen(bool isOpen) =>
      _service.setMasterStoreOpen(isOpen);

  Future<bool> hasUsedDailyExpressAd() => _service.hasUsedDailyExpressAd();

  Future<List<SellerDropItem>> getSellerDrops() => _service.fetchSellerDrops();

  Future<CapturedMediaInfo> captureLiveWebpPhoto({String? hintLabel}) =>
      _service.captureAndCompressWebP(hintLabel: hintLabel);

  Future<SellerDropItem> publishQuickDrop({
    required String qatType,
    required String qualityGrade,
    required String unit,
    required int priceYer,
    required bool isAvailable,
    required CapturedMediaInfo media,
    bool isExpressAd = false,
    String? customDescription,
  }) {
    final now = DateTime.now();
    final drop = SellerDropItem(
      id: 'drop-${now.millisecondsSinceEpoch}',
      qatType: qatType,
      qualityGrade: qualityGrade,
      unit: unit,
      priceYer: priceYer,
      isAvailable: isAvailable,
      isExpressAd: isExpressAd,
      customDescription: customDescription,
      media: media,
      publishedAt: now,
    );
    return _service.publishDrop(drop);
  }

  Future<SellerDropItem?> toggleProductAvailability(String dropId) =>
      _service.toggleProductAvailability(dropId);
}
