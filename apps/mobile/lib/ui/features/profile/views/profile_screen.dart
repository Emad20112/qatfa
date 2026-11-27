import 'package:flutter/material.dart';
import '../../../../core/responsive/text_scaler_boundary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/qatfa_primary_button.dart';
import '../../../../core/widgets/cards/stat_counter_card.dart';
import '../../../../core/widgets/navigation/qatfa_app_bar_header.dart';
import '../../../../core/widgets/navigation/qatfa_bottom_nav_bar.dart';
import '../../../../domain/models/profile_models.dart';
import '../../bookings/views/bookings_screen.dart';
import '../../seller/views/quick_publish_screen.dart';
import '../../seller/views/seller_presets_screen.dart';
import '../view_models/profile_view_model.dart';

/// شاشة الملف الشخصي وإعدادات الحساب (Profile & Account Settings Screen)
/// مطابقة للصورة المرجعية 1 مع تصحيح عناصر الذكاء الاصطناعي وفق نطاق MVP
class ProfileScreen extends StatefulWidget {
  final ProfileViewModel? viewModel;
  final bool showBottomNav;
  final ValueChanged<int>? onNavTap;
  final VoidCallback? onPostDropTap;
  final VoidCallback? onNavigateBookings;

  const ProfileScreen({
    super.key,
    this.viewModel,
    this.showBottomNav = false,
    this.onNavTap,
    this.onPostDropTap,
    this.onNavigateBookings,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel _viewModel;
  late final bool _ownsViewModel;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? ProfileViewModel();
    _viewModel.loadProfile();
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  Future<void> _showEditProfileSheet(UserProfile profile) async {
    final nameController = TextEditingController(text: profile.fullName);
    final storeController = TextEditingController(text: profile.storeName);
    String selectedGovernorate = profile.governorate;
    const governorates = ['صنعاء', 'عدن', 'تعز', 'إب', 'ذمار', 'الحديدة'];

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.r24)),
      ),
      builder: (sheetContext) {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تعديل البيانات الشخصية',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'الاسم الكامل',
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.radius12,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    TextField(
                      controller: storeController,
                      decoration: InputDecoration(
                        labelText: 'اسم المفرش (لحساب المقاوتي)',
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.radius12,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    DropdownButtonFormField<String>(
                      initialValue: governorates.contains(selectedGovernorate)
                          ? selectedGovernorate
                          : governorates.first,
                      decoration: InputDecoration(
                        labelText: 'المحافظة الافتراضية',
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.radius12,
                        ),
                      ),
                      items: governorates
                          .map(
                            (gov) => DropdownMenuItem(
                              value: gov,
                              child: Text(gov),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() => selectedGovernorate = val);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    SizedBox(
                      width: double.infinity,
                      child: QatfaPrimaryButton(
                        label: 'حفظ التعديلات',
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

    if (saved == true) {
      await _viewModel.updatePersonalInfo(
        fullName: nameController.text,
        governorate: selectedGovernorate,
        storeName: storeController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث بيانات الحساب بنجاح'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    nameController.dispose();
    storeController.dispose();
  }

  Future<void> _showFavoriteMarketsSheet(UserProfile profile) async {
    final colors = context.colors;

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
                  const Text(
                    'الأسواق والمفارش المفضلة',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    'الشراء يتم بالاستلام المباشر من مفرش المقاوتي في السوق',
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  ...profile.favoriteMarkets.map(
                    (market) => Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.s8),
                      padding: AppSpacing.p12,
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: AppSpacing.radius12,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_rounded, color: colors.primary),
                          const SizedBox(width: AppSpacing.s10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${market.marketName} (${market.governorate})',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  market.stallLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: market.isOpenNow
                                ? colors.statusFresh
                                : colors.statusSoldOut,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSettingsSheet(UserProfile profile) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.r24)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              final current = _viewModel.profile ?? profile;
              return Padding(
                padding: AppSpacing.p20,
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الإعدادات وتخصيص الاستخدام',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      SwitchListTile.adaptive(
                        title: const Text(
                          'إشعارات القطفات الجديدة للمتابَعين',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'تنبيهات فورية لحظة وصول قطفة جديدة بين 11:30 ص و 3:30 م',
                          style: TextStyle(fontSize: 11.5),
                        ),
                        value: current.pushNewDropsEnabled,
                        onChanged: _viewModel.togglePushNewDrops,
                      ),
                      SwitchListTile.adaptive(
                        title: const Text(
                          'كتم إشعارات التقييمات للمقاوتي 🔕',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'يستمر حفظ التقييمات دون إرسال تنبيهات مزعجة أثناء البيع بالسوق',
                          style: TextStyle(fontSize: 11.5),
                        ),
                        value: current.muteReviewNotifications,
                        onChanged: _viewModel.toggleMuteReviewNotifications,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showNotificationsSheet() async {
    await _viewModel.markNotificationsRead();
    if (!mounted) return;
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
                children: const [
                  Text(
                    'الإشعارات والتنبيهات',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppSpacing.s12),
                  ListTile(
                    leading: Icon(Icons.eco_rounded, color: AppColors.freshGreen),
                    title: Text('وصلت قطفة همداني رووس عند مفرش السالمي'),
                    subtitle: Text('قبل 12 دقيقة • سوق علي محسن'),
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.verified_rounded, color: AppColors.primaryGreen),
                    title: Text('تم توثيق رقم هاتفك بنجاح'),
                    subtitle: Text('حسابك يحمل شارة التوثيق الرسمية'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSupportSheet() async {
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
                children: const [
                  Text(
                    'الدعم الفني والمساعدة',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppSpacing.s8),
                  Text(
                    'فريق دعم قطفة متواجد لمساعدتك يومياً من الساعة 9 صباحاً حتى 10 مساءً لمراجعة البلاغات أو توثيق المفارش.',
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(height: AppSpacing.s12),
                  ListTile(
                    leading: Icon(Icons.phone_in_talk_rounded,
                        color: AppColors.primaryGreen),
                    title: Text('الرقم الموحد للدعم الميداني'),
                    subtitle: Text('+967 777 000 100'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout() async {
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
              'تسجيل الخروج',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟ يمكنك المتابعة في التصفح كضيف.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.statusDanger,
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('تأكيد الخروج'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      _viewModel.logout();
    }
  }

  void _openBookings() {
    if (widget.onNavigateBookings != null) {
      widget.onNavigateBookings!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BookingsScreen()),
    );
  }

  void _openQuickPublish() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QuickPublishScreen()),
    );
  }

  void _openPresets() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SellerPresetsScreen()),
    );
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
                  currentIndex: 3,
                  onTap: widget.onNavTap ?? (_) {},
                  onPostDropTap: widget.onPostDropTap ?? _openQuickPublish,
                )
              : null,
          body: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              final profile = _viewModel.profile;
              if (_viewModel.isLoading || profile == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_viewModel.isLoggedOut) {
                return _buildLoggedOutState(colors);
              }

              return Column(
                children: [
                  QatfaAppBarHeader(
                    locationText: profile.governorate,
                    notificationCount: profile.unreadNotificationsCount,
                    onNotificationTap: _showNotificationsSheet,
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: AppSpacing.s24),
                          children: [
                            // بطاقة الملف الشخصي
                            _buildProfileHeroCard(colors, profile),
                            const SizedBox(height: AppSpacing.s12),

                            // شريط أدوات المقاوتي عند التبديل لدور "مقاوتي"
                            if (profile.activeRole == AccountRole.seller) ...[
                              _buildSellerQuickToolsBanner(colors, profile),
                              const SizedBox(height: AppSpacing.s12),
                            ],

                            // شريط الإحصائيات الثلاثي
                            Padding(
                              padding: AppSpacing.ph16,
                              child: StatCounterCard(
                                items: [
                                  StatItem(
                                    label: 'تواصل ناجح',
                                    value: '${profile.successfulInquiriesCount}',
                                    icon: Icons.phone_forwarded_rounded,
                                    iconColor: colors.primary,
                                  ),
                                  StatItem(
                                    label: 'حجز نشط',
                                    value: '${profile.activeBookingsCount}',
                                    icon: Icons.calendar_today_rounded,
                                    iconColor: colors.primary,
                                  ),
                                  StatItem(
                                    label: 'قطفة مفضلة',
                                    value: '${profile.favoriteDropsCount}',
                                    icon: Icons.favorite_rounded,
                                    iconColor: colors.statusFresh,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s14),

                            // قائمة خيارات الحساب والصفوف التفاعلية (8 صفوف)
                            Padding(
                              padding: AppSpacing.ph16,
                              child: Column(
                                children: [
                                  _ProfileActionTile(
                                    title: 'البيانات الشخصية',
                                    subtitle: 'تعديل معلوماتك الشخصية',
                                    icon: Icons.person_outline_rounded,
                                    iconColor: colors.primary,
                                    iconBg: colors.primaryContainer,
                                    onTap: () => _showEditProfileSheet(profile),
                                  ),
                                  _ProfileActionTile(
                                    title: 'الأسواق والمفارش المفضلة',
                                    subtitle:
                                        'إدارة الأسواق القريبة والمفارش المعتمدة',
                                    icon: Icons.location_on_outlined,
                                    iconColor: colors.primary,
                                    iconBg: colors.primaryContainer,
                                    onTap: () =>
                                        _showFavoriteMarketsSheet(profile),
                                  ),
                                  _ProfileActionTile(
                                    title: 'المفضلة',
                                    subtitle:
                                        'القطفات المفضلة لديك (${profile.favoriteDropsCount})',
                                    icon: Icons.favorite_rounded,
                                    iconColor: colors.agate,
                                    iconBg: colors.agateContainer,
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'لديك ${profile.favoriteDropsCount} قطفات محفوظة في المفضلة',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                  ),
                                  _ProfileActionTile(
                                    title: 'سجل الطلبات والحجوزات',
                                    subtitle:
                                        'متابعة حجوزاتك وتواصلاتك السابقة',
                                    icon: Icons.assignment_outlined,
                                    iconColor: colors.primary,
                                    iconBg: colors.primaryContainer,
                                    onTap: _openBookings,
                                  ),
                                  _ProfileActionTile(
                                    title: 'الإشعارات',
                                    subtitle: 'إدارة إشعارات التطبيق',
                                    icon: Icons.notifications_none_rounded,
                                    iconColor: AppColors.statusInfo,
                                    iconBg: AppColors.statusInfoLight,
                                    showUnreadDot:
                                        profile.unreadNotificationsCount > 0,
                                    onTap: _showNotificationsSheet,
                                  ),
                                  _ProfileActionTile(
                                    title: 'الإعدادات وتخصيص الاستخدام',
                                    subtitle:
                                        'تخصيص تجربة الاستخدام والإشعارات',
                                    icon: Icons.settings_outlined,
                                    iconColor: const Color(0xFF7C3AED),
                                    iconBg: const Color(0xFFF3E8FF),
                                    onTap: () => _showSettingsSheet(profile),
                                  ),
                                  _ProfileActionTile(
                                    title: 'الدعم الفني والمساعدة',
                                    subtitle: 'تواصل معنا للمساعدة',
                                    icon: Icons.headset_mic_outlined,
                                    iconColor: colors.primary,
                                    iconBg: colors.primaryContainer,
                                    onTap: _showSupportSheet,
                                  ),
                                  _ProfileActionTile(
                                    title: 'تسجيل الخروج',
                                    subtitle: 'الخروج من حسابك بأمان',
                                    icon: Icons.logout_rounded,
                                    iconColor: colors.statusSoldOut,
                                    iconBg: colors.statusSoldOut
                                        .withValues(alpha: 0.14),
                                    isDangerTile: true,
                                    onTap: _confirmLogout,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: AppSpacing.s16),
                            // التذييل التراثي بمدرجات جبال اليمن
                            _buildHeritageFooter(colors),
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

  Widget _buildLoggedOutState(QatfaColors colors) {
    return Center(
      child: Padding(
        padding: AppSpacing.p24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout_rounded, size: 52, color: colors.textMuted),
            const SizedBox(height: AppSpacing.s12),
            Text(
              'تم تسجيل الخروج بنجاح',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s6),
            Text(
              'يمكنك العودة وتسجيل الدخول برقم الهاتف في أي وقت.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.s16),
            QatfaPrimaryButton(
              label: 'إعادة الدخول للحساب',
              onPressed: _viewModel.restoreDemoSession,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeroCard(QatfaColors colors, UserProfile profile) {
    final isSeller = profile.activeRole == AccountRole.seller;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        0,
      ),
      padding: AppSpacing.p16,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppSpacing.radius20,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // صورة المستخدم داخل إطار دائري مزدوج مع شارة الكاميرا
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.primary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    profile.fullName.isNotEmpty
                        ? profile.fullName.substring(0, 1)
                        : 'ق',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: InkWell(
                  onTap: () => _showEditProfileSheet(profile),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.s12),

          // الاسم ورقم الهاتف وقائمة تبديل الصفة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.fullName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s4),
                    InkWell(
                      onTap: () => _showEditProfileSheet(profile),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s2),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          profile.phoneNumber,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Icon(Icons.phone_rounded, size: 13, color: colors.primary),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),

                // قائمة تبديل الصفة [ مشتري ▼ / مقاوتي ]
                PopupMenuButton<AccountRole>(
                  key: const Key('role_switcher_button'),
                  onSelected: _viewModel.switchRole,
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: AccountRole.buyer,
                      child: Text('مشتري'),
                    ),
                    PopupMenuItem(
                      value: AccountRole.seller,
                      child: Text('مقاوتي (بائع)'),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s12,
                      vertical: AppSpacing.s6,
                    ),
                    decoration: BoxDecoration(
                      color: isSeller
                          ? colors.agateContainer
                          : colors.primaryContainer,
                      borderRadius: AppSpacing.radiusFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSeller
                              ? Icons.storefront_rounded
                              : Icons.person_rounded,
                          size: 15,
                          color: isSeller ? colors.agate : colors.primary,
                        ),
                        const SizedBox(width: AppSpacing.s4),
                        Text(
                          isSeller ? 'مقاوتي' : 'مشتري',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isSeller ? colors.agate : colors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s2),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: isSeller ? colors.agate : colors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // شارة التوثيق والتقييم
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s10,
              vertical: AppSpacing.s8,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: AppSpacing.radius16,
              border: Border.all(color: colors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: colors.primary,
                  size: 22,
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  profile.isVerified ? 'مستخدم موثق' : 'قيد التوثيق',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (_) => const Icon(
                      Icons.star_rounded,
                      color: AppColors.statusWarning,
                      size: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerQuickToolsBanner(
    QatfaColors colors,
    UserProfile profile,
  ) {
    return Container(
      margin: AppSpacing.ph16,
      padding: AppSpacing.p12,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreenDark, AppColors.primaryGreen],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: AppSpacing.radius16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_rounded, color: Color(0xFF4ADE80)),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  'وضع المقاوتي نشط: ${profile.storeName}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openQuickPublish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.agate,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(42),
                  ),
                  icon: const Icon(Icons.add_a_photo_rounded, size: 17),
                  label: const Text(
                    'نشر قطفة اليوم',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openPresets,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                    minimumSize: const Size.fromHeight(42),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppSpacing.radiusFull,
                    ),
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 17),
                  label: const Text(
                    'قوائمي السريعة',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeritageFooter(QatfaColors colors) {
    return Column(
      children: [
        Padding(
          padding: AppSpacing.ph20,
          child: Row(
            children: [
              Expanded(child: Divider(color: colors.primary.withValues(alpha: 0.35))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10),
                child: Text(
                  'مع قطفة .. نزرع الخير ونحصده معاً',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ),
              Expanded(child: Divider(color: colors.primary.withValues(alpha: 0.35))),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        SizedBox(
          height: 68,
          width: double.infinity,
          child: CustomPaint(
            painter: _YemenTerracesPainter(
              primary: colors.primary,
              fresh: colors.statusFresh,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool showUnreadDot;
  final bool isDangerTile;
  final VoidCallback onTap;

  const _ProfileActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.showUnreadDot = false,
    this.isDangerTile = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
      child: Material(
        color: isDangerTile
            ? colors.statusSoldOut.withValues(alpha: 0.08)
            : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radius16,
          side: BorderSide(
            color: isDangerTile
                ? colors.statusSoldOut.withValues(alpha: 0.25)
                : colors.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s10,
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: AppSpacing.radius12,
                      ),
                      child: Icon(icon, color: iconColor, size: 21),
                    ),
                    if (showUnreadDot)
                      Positioned(
                        top: -2,
                        left: -2,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: AppColors.statusDanger,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDangerTile
                              ? colors.statusSoldOut
                              : colors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDangerTile
                              ? colors.statusSoldOut.withValues(alpha: 0.85)
                              : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDangerTile ? colors.statusSoldOut : colors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// رسام متجهي لمدرجات جبال اليمن الخضراء في التذييل التراثي
class _YemenTerracesPainter extends CustomPainter {
  final Color primary;
  final Color fresh;

  const _YemenTerracesPainter({
    required this.primary,
    required this.fresh,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backHillPaint = Paint()
      ..color = primary.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    final midHillPaint = Paint()
      ..color = fresh.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    final frontTerracePaint = Paint()
      ..color = primary.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;

    final backPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.45)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.10,
        size.width * 0.55,
        size.height * 0.42,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.65,
        size.width,
        size.height * 0.25,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(backPath, backHillPaint);

    final midPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.62)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.35,
        size.width * 0.72,
        size.height * 0.58,
      )
      ..quadraticBezierTo(
        size.width * 0.88,
        size.height * 0.68,
        size.width,
        size.height * 0.48,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(midPath, midHillPaint);

    final frontPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.56,
        size.width,
        size.height * 0.72,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(frontPath, frontTerracePaint);
  }

  @override
  bool shouldRepaint(covariant _YemenTerracesPainter oldDelegate) {
    return oldDelegate.primary != primary || oldDelegate.fresh != fresh;
  }
}
