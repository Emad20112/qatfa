import '../../core/widgets/chips/qatfa_status_badge.dart';

/// تبويبات تصفية الحجوزات والمتابعات
enum BookingFilterStatus {
  all,
  pending,
  confirmed,
  completed,
}

/// نموذج عنصر الحجز أو المتابعة المتفق عليها مع المقاوتي
class BookingItem {
  final String id;
  final String title;
  final String sellerName;
  final String marketName;
  final String stallNumber;
  final int priceYer;
  final String quantity;
  final String dateText;
  final String expectedTimeText;
  final QatfaStatusType statusType;
  final String statusLabel;
  final String phoneNumber;
  final int? userRating;
  final String? userReviewNote;

  const BookingItem({
    required this.id,
    required this.title,
    required this.sellerName,
    required this.marketName,
    required this.stallNumber,
    required this.priceYer,
    required this.quantity,
    required this.dateText,
    required this.expectedTimeText,
    required this.statusType,
    required this.statusLabel,
    required this.phoneNumber,
    this.userRating,
    this.userReviewNote,
  });

  BookingItem copyWith({
    String? id,
    String? title,
    String? sellerName,
    String? marketName,
    String? stallNumber,
    int? priceYer,
    String? quantity,
    String? dateText,
    String? expectedTimeText,
    QatfaStatusType? statusType,
    String? statusLabel,
    String? phoneNumber,
    int? userRating,
    String? userReviewNote,
  }) {
    return BookingItem(
      id: id ?? this.id,
      title: title ?? this.title,
      sellerName: sellerName ?? this.sellerName,
      marketName: marketName ?? this.marketName,
      stallNumber: stallNumber ?? this.stallNumber,
      priceYer: priceYer ?? this.priceYer,
      quantity: quantity ?? this.quantity,
      dateText: dateText ?? this.dateText,
      expectedTimeText: expectedTimeText ?? this.expectedTimeText,
      statusType: statusType ?? this.statusType,
      statusLabel: statusLabel ?? this.statusLabel,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userRating: userRating ?? this.userRating,
      userReviewNote: userReviewNote ?? this.userReviewNote,
    );
  }
}
