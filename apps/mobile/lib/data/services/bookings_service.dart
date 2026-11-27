import '../../core/widgets/chips/qatfa_status_badge.dart';
import '../../domain/models/booking_models.dart';

/// خدمة سجل الحجوزات والمتابعات المتفق عليها مع المقاوتية
class BookingsService {
  final List<BookingItem> _items = [
    const BookingItem(
      id: 'bk-101',
      title: 'أرحبي قاعي سوبر',
      sellerName: 'الحاج يحيى الصياح',
      marketName: 'سوق الملح - صنعاء',
      stallNumber: 'مفرش 14',
      priceYer: 15000,
      quantity: '1 حزمة (كيلو)',
      dateText: '24 / 11 / 2026',
      expectedTimeText: 'الوقت المطلوب: من 9 صباحاً',
      statusType: QatfaStatusType.pending,
      statusLabel: 'قيد التأكيد',
      phoneNumber: '+967777111222',
    ),
    const BookingItem(
      id: 'bk-102',
      title: 'همداني فاخر',
      sellerName: 'أبو محمد السالمي',
      marketName: 'سوق علي محسن - صنعاء',
      stallNumber: 'مفرش 8',
      priceYer: 14000,
      quantity: '1 حزمة (كيلو)',
      dateText: '23 / 11 / 2026',
      expectedTimeText: 'الاستلام المتوقع: اليوم بعد الظهر',
      statusType: QatfaStatusType.confirmed,
      statusLabel: 'مؤكد',
      phoneNumber: '+967777333444',
    ),
    const BookingItem(
      id: 'bk-103',
      title: 'شامي غيلاني',
      sellerName: 'مقاوتة السوق',
      marketName: 'سوق شميلة - صنعاء',
      stallNumber: 'مفرش 22',
      priceYer: 13000,
      quantity: '1 حزمة (كيلو)',
      dateText: '22 / 11 / 2026',
      expectedTimeText: 'تم الاستلام في 22 / 11 / 2026',
      statusType: QatfaStatusType.completed,
      statusLabel: 'مكتمل',
      phoneNumber: '+967733555666',
    ),
  ];

  Future<List<BookingItem>> fetchBookings() async {
    return List<BookingItem>.unmodifiable(_items);
  }

  Future<void> cancelBooking(String id) async {
    _items.removeWhere((item) => item.id == id);
  }

  Future<BookingItem?> rateBooking({
    required String id,
    required int stars,
    String? note,
  }) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return null;
    final updated = _items[index].copyWith(
      userRating: stars,
      userReviewNote: note,
    );
    _items[index] = updated;
    return updated;
  }
}
