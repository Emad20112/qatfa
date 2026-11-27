import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../core/responsive/text_scaler_boundary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/qatfa_phone_button.dart';
import '../../../../core/widgets/buttons/qatfa_primary_button.dart';
import '../../../../core/widgets/buttons/qatfa_whatsapp_button.dart';
import '../../../../core/widgets/cards/booking_card.dart';
import '../../../../core/widgets/chips/qatfa_status_badge.dart';
import '../../../../core/widgets/navigation/qatfa_app_bar_header.dart';
import '../../../../core/widgets/navigation/qatfa_bottom_nav_bar.dart';
import '../../../../domain/models/booking_models.dart';
import '../view_models/bookings_view_model.dart';

/// شاشة الحجوزات والمتابعات (Bookings & Inquiries Screen)
/// مطابقة لتصميم الصورة المرجعية الثالثة مع احترام قواعد MVP (استلام من المفرش ودفع نقدي مباشر)
class BookingsScreen extends StatefulWidget {
  final BookingsViewModel? viewModel;
  final bool showBottomNav;
  final ValueChanged<int>? onNavTap;
  final VoidCallback? onPostDropTap;
  final String locationText;

  const BookingsScreen({
    super.key,
    this.viewModel,
    this.showBottomNav = false,
    this.onNavTap,
    this.onPostDropTap,
    this.locationText = 'صنعاء',
  });

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  late final BookingsViewModel _viewModel;
  late final bool _ownsViewModel;
  final NumberFormat _priceFormat = NumberFormat('#,###', 'en_US');

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? BookingsViewModel();
    _viewModel.loadBookings();
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  Future<void> _confirmCancelBooking(BookingItem booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.radius20,
            ),
            title: const Text(
              'إلغاء متابعة الحجز',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: Text(
              'هل تريد إلغاء متابعة حجز "${booking.title}" مع ${booking.sellerName}؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('تراجع'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.statusDanger,
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('نعم، إلغاء الحجز'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      await _viewModel.cancelBooking(booking.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إلغاء حجز "${booking.title}"'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showDetailsSheet(BookingItem booking) async {
    final colors = context.colors;
    final formattedPrice = _priceFormat.format(booking.priceYer);

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.r24)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: AppSpacing.p20,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          booking.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      QatfaStatusBadge(
                        label: booking.statusLabel,
                        statusType: booking.statusType,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _detailRow(colors, Icons.storefront_rounded, 'المقاوتي',
                      booking.sellerName),
                  _detailRow(colors, Icons.location_on_outlined, 'السوق والمفرش',
                      '${booking.marketName} • ${booking.stallNumber}'),
                  _detailRow(colors, Icons.payments_outlined, 'السعر المتفق عليه',
                      '$formattedPrice ر.ي (${booking.quantity})'),
                  _detailRow(colors, Icons.schedule_rounded, 'موعد الاستلام',
                      booking.expectedTimeText),
                  const SizedBox(height: AppSpacing.s16),
                  Row(
                    children: [
                      Expanded(
                        child: QatfaWhatsAppButton(
                          phoneNumber: booking.phoneNumber,
                          dropTitle: booking.title,
                          price: '$formattedPrice ر.ي',
                          label: 'مراسلة واتساب',
                          height: 44,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: QatfaPhoneButton(
                          phoneNumber: booking.phoneNumber,
                          label: 'اتصال مباشر',
                          isCircle: false,
                          size: 44,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    QatfaColors colors,
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        children: [
          Icon(icon, size: 17, color: colors.primary),
          const SizedBox(width: AppSpacing.s8),
          Text(
            '$title: ',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRatingSheet(BookingItem booking) async {
    int selectedStars = booking.userRating ?? 5;
    final noteController = TextEditingController(text: booking.userReviewNote ?? '');

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.r24)),
      ),
      builder: (sheetContext) {
        final colors = context.colors;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.s20,
                  right: AppSpacing.s20,
                  top: AppSpacing.s20,
                  bottom: MediaQuery.viewInsetsOf(sheetContext).bottom +
                      AppSpacing.s20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'تقييم تجربتك مع ${booking.sellerName}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    Text(
                      booking.title,
                      style: TextStyle(fontSize: 13, color: colors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starNumber = index + 1;
                        final active = starNumber <= selectedStars;
                        return IconButton(
                          onPressed: () =>
                              setSheetState(() => selectedStars = starNumber),
                          icon: Icon(
                            active ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: active ? colors.primary : colors.textMuted,
                            size: 36,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'اكتب ملاحظتك عن جودة القطفة وحسن التعامل...',
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.radius12,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    SizedBox(
                      width: double.infinity,
                      child: QatfaPrimaryButton(
                        label: 'إرسال التقييم',
                        onPressed: () => Navigator.of(sheetContext).pop(true),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (submitted == true) {
      await _viewModel.submitRating(
        bookingId: booking.id,
        stars: selectedStars,
        note: noteController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('شكراً لتقييمك ($selectedStars نجوم) لتجربة ${booking.sellerName}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextScalerBoundary(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          bottomNavigationBar: widget.showBottomNav
              ? QatfaBottomNavBar(
                  currentIndex: 2,
                  onTap: widget.onNavTap ?? (_) {},
                  onPostDropTap: widget.onPostDropTap ?? () {},
                )
              : null,
          body: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              final filtered = _viewModel.filteredBookings;

              return Column(
                children: [
                  QatfaAppBarHeader(
                    locationText: widget.locationText,
                    notificationCount: 3,
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          children: [
                            // ترويسة الشاشة البيضاء المنحنية
                            _buildTitleHeader(colors),

                            // شريط تبويبات الفئات بعدادات رقمية واضحة
                            _buildFilterTabsBar(colors),
                            const SizedBox(height: AppSpacing.s12),

                            // قائمة بطاقات الحجوزات
                            Expanded(
                              child: _viewModel.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : filtered.isEmpty
                                      ? _buildEmptyState(colors)
                                      : ListView.separated(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.s16,
                                            vertical: AppSpacing.s4,
                                          ),
                                          itemCount: filtered.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(
                                            height: AppSpacing.s12,
                                          ),
                                          itemBuilder: (context, index) {
                                            final item = filtered[index];
                                            return BookingCard(
                                              title: item.title,
                                              sellerName: item.sellerName,
                                              price: _priceFormat
                                                  .format(item.priceYer),
                                              quantity: item.quantity,
                                              dateText: item.dateText,
                                              expectedTimeText:
                                                  item.expectedTimeText,
                                              statusType: item.statusType,
                                              statusLabel: item.statusLabel,
                                              phoneNumber: item.phoneNumber,
                                              onCancelTap: item.statusType ==
                                                      QatfaStatusType.pending
                                                  ? () =>
                                                      _confirmCancelBooking(item)
                                                  : null,
                                              onDetailsTap: () =>
                                                  _showDetailsSheet(item),
                                              onRateTap: item.statusType ==
                                                      QatfaStatusType.completed
                                                  ? () => _showRatingSheet(item)
                                                  : null,
                                            );
                                          },
                                        ),
                            ),

                            // بطاقة الملخص المالي والكمي الخضراء في الأسفل
                            _buildFinancialSummaryCard(colors),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTitleHeader(QatfaColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.s8,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (Navigator.of(context).canPop())
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppSpacing.s8),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: colors.textPrimary,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: AppSpacing.radius8,
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Flexible(
                child: Text(
                  'حجوزاتي',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            'كل حجوزاتك في مكان واحد',
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabsBar(QatfaColors colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.ph16,
      child: Row(
        children: [
          _FilterPillTab(
            label: 'الكل (${_viewModel.totalCount})',
            icon: Icons.assignment_outlined,
            isSelected: _viewModel.selectedFilter == BookingFilterStatus.all,
            onTap: () => _viewModel.setFilter(BookingFilterStatus.all),
          ),
          const SizedBox(width: AppSpacing.s8),
          _FilterPillTab(
            label: 'قيد التأكيد (${_viewModel.pendingCount})',
            icon: Icons.access_time_rounded,
            iconColor: colors.statusPending,
            isSelected:
                _viewModel.selectedFilter == BookingFilterStatus.pending,
            onTap: () => _viewModel.setFilter(BookingFilterStatus.pending),
          ),
          const SizedBox(width: AppSpacing.s8),
          _FilterPillTab(
            label: 'مؤكد (${_viewModel.confirmedCount})',
            icon: Icons.check_circle_rounded,
            iconColor: colors.statusConfirmed,
            isSelected:
                _viewModel.selectedFilter == BookingFilterStatus.confirmed,
            onTap: () => _viewModel.setFilter(BookingFilterStatus.confirmed),
          ),
          const SizedBox(width: AppSpacing.s8),
          _FilterPillTab(
            label: 'مكتمل (${_viewModel.completedCount})',
            icon: Icons.verified_rounded,
            iconColor: colors.statusFresh,
            isSelected:
                _viewModel.selectedFilter == BookingFilterStatus.completed,
            onTap: () => _viewModel.setFilter(BookingFilterStatus.completed),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(QatfaColors colors) {
    return Center(
      child: Padding(
        padding: AppSpacing.p24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_late_outlined,
              size: 48,
              color: colors.textMuted,
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              'لا توجد حجوزات في هذا التصنيف حالياً',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              'يمكنك استعراض عروض اليوم والتواصل مع المقاوتية عبر الواتساب أو الاتصال المباشر.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryCard(QatfaColors colors) {
    final totalCount = _viewModel.totalCount;
    final formattedTotal = _priceFormat.format(_viewModel.totalValueYer);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s8,
        AppSpacing.s16,
        AppSpacing.s12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: AppSpacing.radius16,
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Icon(Icons.bar_chart_rounded, color: colors.primary, size: 22),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'إجمالي حجوزاتك: $totalCount حجوزات',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    'بقيمة إجمالية: $formattedTotal ر.ي',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 28,
              color: colors.primary.withValues(alpha: 0.2),
            ),
            const SizedBox(width: AppSpacing.s10),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.eco_rounded, color: colors.primary, size: 16),
                  const SizedBox(width: AppSpacing.s4),
                  Flexible(
                    child: Text(
                      'مع قطفة .. دائماً الأفضل',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPillTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPillTab({
    required this.label,
    required this.icon,
    this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: isSelected ? AppColors.primaryGreenDark : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.radiusFull,
        side: BorderSide(
          color: isSelected ? AppColors.primaryGreenDark : colors.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.radiusFull,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : (iconColor ?? colors.primary),
              ),
              const SizedBox(width: AppSpacing.s6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
