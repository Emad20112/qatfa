import 'package:flutter/foundation.dart';
import '../../../../core/widgets/chips/qatfa_status_badge.dart';
import '../../../../data/repositories/bookings_repository.dart';
import '../../../../domain/models/booking_models.dart';

/// ViewModel شاشة الحجوزات والمتابعات
class BookingsViewModel extends ChangeNotifier {
  final BookingsRepository _repository;

  BookingsViewModel({BookingsRepository? repository})
      : _repository = repository ?? BookingsRepository();

  List<BookingItem> _allBookings = const [];
  List<BookingItem> get allBookings => _allBookings;

  BookingFilterStatus _selectedFilter = BookingFilterStatus.all;
  BookingFilterStatus get selectedFilter => _selectedFilter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int get totalCount => _allBookings.length;

  int get pendingCount => _allBookings
      .where((b) => b.statusType == QatfaStatusType.pending)
      .length;

  int get confirmedCount => _allBookings
      .where((b) => b.statusType == QatfaStatusType.confirmed)
      .length;

  int get completedCount => _allBookings
      .where((b) => b.statusType == QatfaStatusType.completed)
      .length;

  int get totalValueYer =>
      _allBookings.fold<int>(0, (sum, item) => sum + item.priceYer);

  List<BookingItem> get filteredBookings {
    switch (_selectedFilter) {
      case BookingFilterStatus.all:
        return _allBookings;
      case BookingFilterStatus.pending:
        return _allBookings
            .where((b) => b.statusType == QatfaStatusType.pending)
            .toList();
      case BookingFilterStatus.confirmed:
        return _allBookings
            .where((b) => b.statusType == QatfaStatusType.confirmed)
            .toList();
      case BookingFilterStatus.completed:
        return _allBookings
            .where((b) => b.statusType == QatfaStatusType.completed)
            .toList();
    }
  }

  Future<void> loadBookings() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allBookings = await _repository.getBookings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(BookingFilterStatus filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> cancelBooking(String bookingId) async {
    await _repository.cancelBooking(bookingId);
    _allBookings = await _repository.getBookings();
    notifyListeners();
  }

  Future<void> submitRating({
    required String bookingId,
    required int stars,
    String? note,
  }) async {
    await _repository.submitRating(
      bookingId: bookingId,
      stars: stars,
      note: note,
    );
    _allBookings = await _repository.getBookings();
    notifyListeners();
  }
}
