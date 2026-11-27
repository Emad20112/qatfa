import '../../domain/models/booking_models.dart';
import '../services/bookings_service.dart';

/// مستودع الحجوزات والمتابعات
class BookingsRepository {
  final BookingsService _service;

  BookingsRepository({BookingsService? service})
      : _service = service ?? BookingsService();

  Future<List<BookingItem>> getBookings() => _service.fetchBookings();

  Future<void> cancelBooking(String bookingId) =>
      _service.cancelBooking(bookingId);

  Future<BookingItem?> submitRating({
    required String bookingId,
    required int stars,
    String? note,
  }) =>
      _service.rateBooking(id: bookingId, stars: stars, note: note);
}
