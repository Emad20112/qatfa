import 'package:flutter/foundation.dart';
import '../../../../data/repositories/seller_repository.dart';
import '../../../../domain/models/seller_models.dart';

/// ViewModel تدفق النشر السريع للمقاوتي والتحكم المزدوج بالتوفر
class QuickPublishViewModel extends ChangeNotifier {
  final SellerRepository _repository;

  QuickPublishViewModel({SellerRepository? repository})
      : _repository = repository ?? SellerRepository();

  SellerPresets? _presets;
  SellerPresets? get presets => _presets;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPublishing = false;
  bool get isPublishing => _isPublishing;

  bool _isCapturingCamera = false;
  bool get isCapturingCamera => _isCapturingCamera;

  bool _isStoreOpen = true;
  bool get isStoreOpen => _isStoreOpen;

  bool _isExpressMode = false;
  bool get isExpressMode => _isExpressMode;

  bool _hasUsedDailyExpressAd = false;
  bool get hasUsedDailyExpressAd => _hasUsedDailyExpressAd;

  String _selectedType = '';
  String get selectedType => _selectedType;

  String _selectedGrade = '';
  String get selectedGrade => _selectedGrade;

  String _selectedUnit = '';
  String get selectedUnit => _selectedUnit;

  bool _isDropAvailable = true;
  bool get isDropAvailable => _isDropAvailable;

  String _priceInput = '';
  String get priceInput => _priceInput;

  String _expressDescription = '';
  String get expressDescription => _expressDescription;

  CapturedMediaInfo? _capturedMedia;
  CapturedMediaInfo? get capturedMedia => _capturedMedia;

  List<SellerDropItem> _drops = const [];
  List<SellerDropItem> get drops => _drops;

  SellerDropItem? _lastPublishedDrop;
  SellerDropItem? get lastPublishedDrop => _lastPublishedDrop;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      _presets = await _repository.getPresets();
      _isStoreOpen = await _repository.getMasterStoreOpen();
      _hasUsedDailyExpressAd = await _repository.hasUsedDailyExpressAd();
      _drops = await _repository.getSellerDrops();

      if (_presets != null) {
        if (_selectedType.isEmpty && _presets!.selectedTypes.isNotEmpty) {
          _selectedType = _presets!.selectedTypes.first;
        }
        if (_selectedGrade.isEmpty && _presets!.selectedGrades.isNotEmpty) {
          _selectedGrade = _presets!.selectedGrades.first;
        }
        if (_selectedUnit.isEmpty && _presets!.selectedUnits.isNotEmpty) {
          _selectedUnit = _presets!.selectedUnits.first;
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadPresets() async {
    _presets = await _repository.getPresets();
    if (_presets != null) {
      if (!_presets!.selectedTypes.contains(_selectedType) &&
          _presets!.selectedTypes.isNotEmpty) {
        _selectedType = _presets!.selectedTypes.first;
      }
      if (!_presets!.selectedGrades.contains(_selectedGrade) &&
          _presets!.selectedGrades.isNotEmpty) {
        _selectedGrade = _presets!.selectedGrades.first;
      }
      if (!_presets!.selectedUnits.contains(_selectedUnit) &&
          _presets!.selectedUnits.isNotEmpty) {
        _selectedUnit = _presets!.selectedUnits.first;
      }
    }
    notifyListeners();
  }

  void selectType(String type) {
    _selectedType = type;
    _errorMessage = null;
    notifyListeners();
  }

  void selectGrade(String grade) {
    _selectedGrade = grade;
    _errorMessage = null;
    notifyListeners();
  }

  void selectUnit(String unit) {
    _selectedUnit = unit;
    _errorMessage = null;
    notifyListeners();
  }

  void setDropAvailable(bool available) {
    _isDropAvailable = available;
    notifyListeners();
  }

  void setExpressMode(bool express) {
    _isExpressMode = express;
    _errorMessage = null;
    notifyListeners();
  }

  void updateExpressDescription(String value) {
    _expressDescription = value;
    _errorMessage = null;
    notifyListeners();
  }

  void setPrice(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length <= 7) {
      _priceInput = digitsOnly;
      _errorMessage = null;
      notifyListeners();
    }
  }

  void appendDigit(String digit) {
    if (_priceInput.length >= 7) return;
    if (_priceInput == '0') {
      _priceInput = digit;
    } else {
      _priceInput = '$_priceInput$digit';
    }
    _errorMessage = null;
    notifyListeners();
  }

  void backspacePrice() {
    if (_priceInput.isEmpty) return;
    _priceInput = _priceInput.substring(0, _priceInput.length - 1);
    notifyListeners();
  }

  void clearPrice() {
    _priceInput = '';
    notifyListeners();
  }

  Future<void> captureLivePhoto() async {
    _isCapturingCamera = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _capturedMedia = await _repository.captureLiveWebpPhoto(
        hintLabel: _selectedType.isNotEmpty ? _selectedType : 'qat',
      );
    } finally {
      _isCapturingCamera = false;
      notifyListeners();
    }
  }

  void clearCapturedPhoto() {
    _capturedMedia = null;
    notifyListeners();
  }

  Future<void> addCustomPresetFromQuickSheet({
    required PresetCategory category,
    required String label,
  }) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    _presets = await _repository.addCustomPresetItem(
      category: category,
      label: trimmed,
    );
    switch (category) {
      case PresetCategory.qatType:
        _selectedType = trimmed;
        break;
      case PresetCategory.qualityGrade:
        _selectedGrade = trimmed;
        break;
      case PresetCategory.saleUnit:
        _selectedUnit = trimmed;
        break;
    }
    notifyListeners();
  }

  Future<void> toggleMasterStoreOpen() async {
    _isStoreOpen = await _repository.setMasterStoreOpen(!_isStoreOpen);
    notifyListeners();
  }

  Future<SellerDropItem?> toggleProductAvailability(String dropId) async {
    final updated = await _repository.toggleProductAvailability(dropId);
    _drops = await _repository.getSellerDrops();
    notifyListeners();
    return updated;
  }

  Future<bool> publishDrop() async {
    _errorMessage = null;

    if (_isExpressMode && _hasUsedDailyExpressAd) {
      _errorMessage =
          'لقد استهلكت إعلانك السريع لليوم. أكمل إعداد متجرك للنشر غير المحدود';
      notifyListeners();
      return false;
    }

    if (_capturedMedia == null) {
      _errorMessage = 'يرجى التقاط صورة حية للقطفة بالكاميرا أولاً';
      notifyListeners();
      return false;
    }

    final parsedPrice = int.tryParse(_priceInput) ?? 0;
    if (parsedPrice <= 0) {
      _errorMessage = 'يرجى إدخال السعر بالريال اليمني';
      notifyListeners();
      return false;
    }

    if (_isExpressMode && _expressDescription.trim().isEmpty) {
      _errorMessage = 'يرجى كتابة تفاصيل العرض السريع';
      notifyListeners();
      return false;
    }

    _isPublishing = true;
    notifyListeners();
    try {
      final drop = await _repository.publishQuickDrop(
        qatType: _isExpressMode ? 'إعلان سريع' : _selectedType,
        qualityGrade: _isExpressMode ? 'مباشر' : _selectedGrade,
        unit: _isExpressMode ? 'حبة' : _selectedUnit,
        priceYer: parsedPrice,
        isAvailable: _isDropAvailable,
        media: _capturedMedia!,
        isExpressAd: _isExpressMode,
        customDescription: _isExpressMode ? _expressDescription.trim() : null,
      );
      _lastPublishedDrop = drop;
      _hasUsedDailyExpressAd = await _repository.hasUsedDailyExpressAd();
      _drops = await _repository.getSellerDrops();
      _priceInput = '';
      _expressDescription = '';
      _capturedMedia = null;
      return true;
    } finally {
      _isPublishing = false;
      notifyListeners();
    }
  }
}
