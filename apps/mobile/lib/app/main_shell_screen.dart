import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/navigation/qatfa_bottom_nav_bar.dart';
import '../core/widgets/navigation/qatfa_app_bar_header.dart';
import '../core/widgets/chips/qatfa_choice_chip.dart';
import '../core/widgets/inputs/qatfa_search_field.dart';
import '../core/widgets/cards/drop_grid_card.dart';
import '../core/widgets/cards/market_summary_card.dart';
import '../core/widgets/cards/booking_card.dart';
import '../core/widgets/cards/stat_counter_card.dart';
import '../core/widgets/chips/qatfa_status_badge.dart';
import '../core/widgets/feedback/qatfa_trust_badge_bar.dart';
import '../data/services/mock_qatfa_data.dart';
import '../logic/blocs/drops_feed_bloc.dart';
import '../logic/blocs/markets_bloc.dart';
import '../logic/blocs/city_selector_bloc.dart';

/// الشاشة الهيكلية الرئيسية للتطبيق (Main Shell Screen)
/// تربط شريط التنقل السفلي المطور مع التبويبات الأربعة وزر النشر العائم
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeFeedTab(context),
          _buildMarketsTab(context),
          _buildBookingsTab(context),
          _buildProfileTab(context),
        ],
      ),
      bottomNavigationBar: QatfaBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onPostDropTap: () => _showQuickPublishModal(context),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // تبويب 1: الرئيسية وعروض القطفات (Home Feed)
  // ---------------------------------------------------------------------------
  Widget _buildHomeFeedTab(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<CitySelectorBloc, CitySelectorState>(
      builder: (context, cityState) {
        return BlocBuilder<DropsFeedBloc, DropsFeedState>(
          builder: (context, feedState) {
            final drops = feedState is DropsFeedLoaded ? feedState.drops : MockQatfaData.initialDrops;
            final selectedType = feedState is DropsFeedLoaded ? feedState.selectedType : 'الكل';

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: QatfaAppBarHeader(
                    locationText: '📍 ${cityState.currentCity}',
                    notificationCount: 3,
                    onLocationTap: () => _showCityPicker(context),
                    bottom: QatfaSearchField(
                      onFilterTap: () => _showBudgetSearchModal(context),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: MockQatfaData.qatTypes.map((type) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: QatfaChoiceChip(
                              label: type,
                              isSelected: selectedType == type,
                              onSelected: (_) {
                                context.read<DropsFeedBloc>().add(FilterByQatType(type));
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: _buildHeroFeaturedDrop(colors),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: QatfaTrustBadgeBar(),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final drop = drops[index % drops.length];
                        return DropGridCard(
                          title: drop.title,
                          sellerName: drop.sellerName,
                          price: drop.price.toString(),
                          oldPrice: drop.oldPrice?.toString(),
                          imageUrl: drop.imageUrl,
                          phoneNumber: drop.sellerPhone,
                          onTap: () {},
                        );
                      },
                      childCount: drops.length,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // تبويب 2: الأسواق الشعبية والمفارش (Markets)
  // ---------------------------------------------------------------------------
  Widget _buildMarketsTab(BuildContext context) {
    return BlocBuilder<MarketsBloc, MarketsState>(
      builder: (context, state) {
        final markets = state is MarketsLoaded ? state.markets : MockQatfaData.initialMarkets;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: QatfaAppBarHeader(
                locationText: '📍 دليل الأسواق',
                notificationCount: 3,
                bottom: QatfaSearchField(hintText: 'ابحث عن سوق أو منطقة شعبية...'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final market = markets[index % markets.length];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MarketSummaryCard(
                        marketName: market.name,
                        location: market.address,
                        rating: market.rating.toString(),
                        activeSellersCount: market.activeSellersCount.toString(),
                        workingHours: market.workingHours,
                        imageUrl: market.imageUrl,
                        onTap: () {},
                      ),
                    );
                  },
                  childCount: markets.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // تبويب 3: الحجوزات والمتابعات (Bookings)
  // ---------------------------------------------------------------------------
  Widget _buildBookingsTab(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: QatfaAppBarHeader(
            locationText: '📍 سجل الحجوزات',
            notificationCount: 0,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              BookingCard(
                title: 'أرحبي قاعي سوبر',
                sellerName: 'الحاج يحيى الصياح',
                price: '15,000',
                dateText: '24 / 11 / 2026',
                expectedTimeText: 'من 9 صباحاً',
                statusType: QatfaStatusType.pending,
                statusLabel: 'قيد التأكيد',
                phoneNumber: '777123456',
                onDetailsTap: () {},
                onCancelTap: () {},
              ),
              const SizedBox(height: 12),
              BookingCard(
                title: 'همداني فاخر',
                sellerName: 'أبو محمد السالمي',
                price: '14,000',
                dateText: '23 / 11 / 2026',
                expectedTimeText: 'اليوم بعد الظهر',
                statusType: QatfaStatusType.confirmed,
                statusLabel: 'مؤكد',
                phoneNumber: '771234567',
                onDetailsTap: () {},
              ),
            ]),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // تبويب 4: الحساب والملف الشخصي (Profile)
  // ---------------------------------------------------------------------------
  Widget _buildProfileTab(BuildContext context) {
    final colors = context.colors;

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: QatfaAppBarHeader(
            locationText: '📍 حسابي الشخصي',
            notificationCount: 3,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                StatCounterCard(
                  items: const [
                    StatItem(label: 'تواصل مباشر', value: '8', icon: Icons.chat_rounded),
                    StatItem(label: 'حجز نشط', value: '3', icon: Icons.calendar_today_rounded),
                    StatItem(label: 'مفارش مفضلة', value: '12', icon: Icons.storefront_rounded),
                  ],
                ),
                const SizedBox(height: 16),
                _buildActionTile(colors, 'البيانات الشخصية', Icons.person_outline_rounded),
                _buildActionTile(colors, 'المفارش المفضلة', Icons.location_on_outlined),
                _buildActionTile(colors, 'إعدادات الإشعارات', Icons.notifications_none_rounded),
                _buildActionTile(colors, 'الدعم الفني والمساعدة', Icons.headset_mic_outlined),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.statusSoldOut.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: colors.statusSoldOut, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'تسجيل الخروج بأمان',
                        style: TextStyle(
                          color: colors.statusSoldOut,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(QatfaColors colors, String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(icon, color: colors.primary, size: 20),
          title: Text(title, style: TextStyle(fontSize: 14, color: colors.textPrimary)),
          trailing: Icon(Icons.chevron_left_rounded, color: colors.textSecondary),
          onTap: () {},
        ),
      ),
    );
  }

  Widget _buildHeroFeaturedDrop(QatfaColors colors) {
    return Container(
      height: 155,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [colors.primary, colors.primary.withValues(alpha: 0.85)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              QatfaStatusBadge(
                label: 'وصل قبل 25 دقيقة - الكمية محدودة',
                statusType: QatfaStatusType.pending,
                showDot: false,
              ),
              Icon(Icons.eco_rounded, color: Colors.white, size: 22),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'قطفة مميزة من أجود الأنواع',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'همداني فاخر قاعي طازج من مزارع اليوم',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.agate,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'احجز حزمتك الآن',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('اختر المحافظة أو المدينة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ...MockQatfaData.cities.map((city) {
                return ListTile(
                  title: Text(city),
                  trailing: const Icon(Icons.location_on_outlined),
                  onTap: () {
                    context.read<CitySelectorBloc>().add(CitySelectorEvent(city));
                    context.read<DropsFeedBloc>().add(LoadDropsFeed(city: city));
                    context.read<MarketsBloc>().add(LoadMarkets(city: city));
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showBudgetSearchModal(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('البحث الذكي بالميزانية متاح في نافذة الفلترة')),
    );
  }

  void _showQuickPublishModal(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('واجهة النشر السريع للمقاوتي بالكاميرا الحية')),
    );
  }
}
