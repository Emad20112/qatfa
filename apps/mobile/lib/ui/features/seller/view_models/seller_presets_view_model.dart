import 'package:flutter/foundation.dart';
import '../../../../data/repositories/seller_repository.dart';
import '../../../../domain/models/seller_models.dart';

/// ViewModel شاشة تجهيز القوائم السريعة المسبقة للمقاوتي
class SellerPresetsViewModel extends ChangeNotifier {
  final SellerRepository _repository;

  SellerPresetsViewModel({SellerRepository? repository})
      : _repository = repository ?? SellerRepository();

  SellerPresets? _presets;
  SellerPresets? get presets => _presets;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  Future<void> loadPresets() async {
    _isLoading = true;
    notifyListeners();
    try {
      _presets = await _repository.getPresets();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleQatType(String type) {
    final current = _presets;
    if (current == null) return;
    final updated = List<String>.from(current.selectedTypes);
    if (updated.contains(type)) {
      if (updated.length > 1) updated.remove(type);
    } else {
      updated.add(type);
    }
    _presets = current.copyWith(selectedTypes: updated);
    _statusMessage = null;
    notifyListeners();
  }

  void toggleQualityGrade(String grade) {
    final current = _presets;
    if (current == null) return;
    final updated = List<String>.from(current.selectedGrades);
    if (updated.contains(grade)) {
      if (updated.length > 1) updated.remove(grade);
    } else {
      updated.add(grade);
    }
    _presets = current.copyWith(selectedGrades: updated);
    _statusMessage = null;
    notifyListeners();
  }

  void toggleSaleUnit(String unit) {
    final current = _presets;
    if (current == null) return;
    final updated = List<String>.from(current.selectedUnits);
    if (updated.contains(unit)) {
      if (updated.length > 1) updated.remove(unit);
    } else {
      updated.add(unit);
    }
    _presets = current.copyWith(selectedUnits: updated);
    _statusMessage = null;
    notifyListeners();
  }

  Future<void> addCustomItem({
    required PresetCategory category,
    required String label,
  }) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;

    if (_presets != null) {
      await _repository.savePresets(_presets!);
    }
    _presets = await _repository.addCustomPresetItem(
      category: category,
      label: trimmed,
    );
    _statusMessage = 'تمت إضافة "$trimmed" وتحديدها في قوائمك السريعة';
    notifyListeners();
  }

  Future<bool> savePresets() async {
    final current = _presets;
    if (current == null) return false;
    _isSaving = true;
    notifyListeners();
    try {
      _presets = await _repository.savePresets(current);
      _statusMessage = 'تم حفظ الخيارات وتجهيز النشر السريع بنجاح';
      return true;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
