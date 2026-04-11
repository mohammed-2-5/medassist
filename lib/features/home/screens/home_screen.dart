import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/constants/app_constants.dart';
import 'package:med_assist/core/widgets/skeleton_loader.dart';
import 'package:med_assist/features/home/providers/home_providers.dart';
import 'package:med_assist/features/home/widgets/enhanced_empty_state.dart';
import 'package:med_assist/features/home/widgets/gradient_stats_card.dart';
import 'package:med_assist/features/home/widgets/home_app_bar.dart';
import 'package:med_assist/features/home/widgets/home_fab.dart';
import 'package:med_assist/features/home/widgets/insights_card.dart';
import 'package:med_assist/features/home/widgets/interaction_warnings_section.dart';
import 'package:med_assist/features/home/widgets/permission_banner.dart';
import 'package:med_assist/features/home/widgets/quick_actions_section.dart';
import 'package:med_assist/features/home/widgets/timeline_section.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/notification/notification_service.dart';

/// Home Screen — main dashboard for medication management.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GlobalKey<State<StatefulWidget>> _timelineSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh doses when returning to foreground to catch missed doses.
      ref.read(todayDosesProvider.notifier).refresh();
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final hasMedicationsAsync = ref.watch(hasMedicationsProvider);
    final hasNotificationPermission = ref.watch(notificationPermissionProvider);

    return hasMedicationsAsync.when(
      data: (hasMedications) => Scaffold(
        appBar: HomeAppBar(hasMedications: hasMedications),
        body: _buildBody(context, hasMedications, hasNotificationPermission),
        floatingActionButton: hasMedications
            ? HomeFab(
                animationController: _animationController,
                onPressed: _navigateToAddMedication,
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
      loading: () => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SkeletonLoader.statsCard(context: context),
              const SizedBox(height: 16),
              Expanded(
                child: SkeletonLoader.list(context: context, itemCount: 4),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) {
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          body: Center(child: Text('${l10n.error} $error')),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  Widget _buildBody(
    BuildContext context,
    bool hasMedications,
    bool hasNotificationPermission,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            if (!hasNotificationPermission)
              SliverToBoxAdapter(
                child: PermissionBanner(
                  icon: Icons.notifications_off_outlined,
                  title: l10n.notificationsDisabled,
                  message: l10n.turnOnReminders,
                  actionLabel: l10n.enable,
                  onActionPressed: _requestNotificationPermission,
                ),
              ),
            if (hasMedications)
              ..._buildTimelineView(context)
            else
              SliverFillRemaining(
                hasScrollBody: false,
                child: EnhancedEmptyState(
                  onAddPressed: _navigateToAddMedication,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Timeline view sliver list
  // ---------------------------------------------------------------------------

  List<Widget> _buildTimelineView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final adherenceAsync = ref.watch(adherenceSummaryProvider);
    final groupedDoses = ref.watch(groupedDosesProvider);
    final adherence = adherenceAsync.value;

    return [
      SliverToBoxAdapter(
        child: GradientStatsCard(
          takenToday: adherence?.takenToday ?? 0,
          totalToday: adherence?.totalToday ?? 0,
          currentStreak: adherence?.currentStreak ?? 0,
          onTap: () => context.push('/analytics'),
        ),
      ),
      const SliverToBoxAdapter(child: InteractionWarningsSection()),
      SliverToBoxAdapter(
        child: QuickActionsSection(onTakeDoseTap: _scrollToTimeline),
      ),
      const SliverToBoxAdapter(child: InsightsCard()),
      TimelineSection(
        key: _timelineSectionKey,
        timeOfDay: l10n.morning,
        timeRange: '06:00 - 11:59',
        icon: Icons.wb_sunny,
        doses: groupedDoses['Morning'] ?? [],
      ),
      TimelineSection(
        timeOfDay: l10n.afternoon,
        timeRange: '12:00 - 17:59',
        icon: Icons.wb_twilight,
        doses: groupedDoses['Afternoon'] ?? [],
      ),
      TimelineSection(
        timeOfDay: l10n.evening,
        timeRange: '18:00 - 22:59',
        icon: Icons.nights_stay,
        doses: groupedDoses['Evening'] ?? [],
      ),
      TimelineSection(
        timeOfDay: l10n.night,
        timeRange: '23:00 - 05:59',
        icon: Icons.bedtime,
        doses: groupedDoses['Night'] ?? [],
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 80)),
    ];
  }

  // ---------------------------------------------------------------------------
  // Helpers / callbacks
  // ---------------------------------------------------------------------------

  void _scrollToTimeline() {
    final ctx = _timelineSectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _refreshData() async {
    await ref.read(todayDosesProvider.notifier).refresh();
  }

  void _navigateToAddMedication() {
    context.push(AppConstants.routeAddReminder);
  }

  Future<void> _requestNotificationPermission() async {
    final granted = await NotificationService().requestPermissions();
    ref.read(notificationPermissionProvider.notifier).updatePermission(granted);

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.notificationPermissionRequested),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

}
