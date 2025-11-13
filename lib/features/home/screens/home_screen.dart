import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/core/constants/app_constants.dart';
import 'package:med_assist/core/widgets/skeleton_loader.dart';
import 'package:med_assist/features/home/providers/home_providers.dart';
import 'package:med_assist/features/home/widgets/enhanced_empty_state.dart';
import 'package:med_assist/features/home/widgets/gradient_stats_card.dart';
import 'package:med_assist/features/home/widgets/permission_banner.dart';
import 'package:med_assist/features/home/widgets/timeline_section.dart';
import 'package:med_assist/features/medications/providers/drug_interaction_providers.dart';
import 'package:med_assist/features/medications/widgets/interaction_warning_card.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/health/drug_interaction_service.dart';
import 'package:med_assist/services/notification/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

/// Home Screen - Main dashboard for medication management
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasMedicationsAsync = ref.watch(hasMedicationsProvider);
    final hasNotificationPermission = ref.watch(notificationPermissionProvider);

    return hasMedicationsAsync.when(
      data: (hasMedications) => Scaffold(
        body: _buildBody(context, hasMedications, hasNotificationPermission),
        floatingActionButton: hasMedications ? _buildFAB(context) : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: kDebugMode
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton.icon(
                    onPressed: () async {
            final service = NotificationService();
            await service.initialize();
            await service.requestPermissions();

            final now = DateTime.now().add(const Duration(seconds: 10)); // 10 seconds for quick test
            final tzTime = tz.TZDateTime.from(now, tz.local);

            const android = AndroidNotificationDetails(
              'medication_reminders_v2', // FIXED: must match the created channel ID
              'Medication Reminders',
              importance: Importance.max,
              priority: Priority.max,
              enableLights: true,
              fullScreenIntent: true,
              category: AndroidNotificationCategory.alarm,
              visibility: NotificationVisibility.public,
            );

            const ios = DarwinNotificationDetails(
              presentSound: true,
              presentAlert: true,
            );

            const details = NotificationDetails(android: android, iOS: ios);

            // FIXED: Use the service's plugin instance
            await service.plugin.zonedSchedule(
              2222,
              'TEST in 10 seconds',
              'If you see this, notifications work!',
              tzTime,
              details,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            );

            debugPrint('✅ Scheduled test notification for ${now.toLocal()}');

            // Show immediate feedback
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Test notification scheduled for ${now.hour}:${now.minute.toString().padLeft(2, '0')}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );

            // Log pending notifications to confirm it was registered
            final pending = await service.getPendingNotifications();
            debugPrint('✅ Test notification scheduled!');
            debugPrint('Total pending notifications: ${pending.length}');
            for (final p in pending) {
              debugPrint(' → id=${p.id} title=${p.title} body=${p.body}');
            }

            // Show all pending in snackbar too
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Total pending notifications: ${pending.length}'),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 2),
              ),
            );
                    },
                    icon: const Icon(Icons.alarm),
                    label: const Text('Test Notification (10s)'),
                  ),
                ),
              )
            : null,
      ),
      loading: () {
        return Scaffold(
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
        );
      },
      error: (error, stack) {
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          body: Center(child: Text('${l10n.error} $error')),
        );
      },
    );
  }

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
              // Permission banners
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

              // Main content
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

  PreferredSizeWidget _buildAppBar(BuildContext context, bool hasMedications) {
    final theme = Theme.of(context);

    if (hasMedications) {
      final today = DateTime.now();
      final dateFormat = DateFormat('EEEE, MMM d');

      return AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.today,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              dateFormat.format(today),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
            tooltip: AppLocalizations.of(context)!.searchMedications,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppConstants.routeSettings),
            tooltip: AppLocalizations.of(context)!.settings,
          ),
        ],
      );
    }

    return AppBar(
      title: Text(AppLocalizations.of(context)!.today),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push(AppConstants.routeSettings),
          tooltip: AppLocalizations.of(context)!.settings,
        ),
      ],
    );
  }

  List<Widget> _buildTimelineView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final adherence = ref.watch(adherenceSummaryProvider);
    final groupedDoses = ref.watch(groupedDosesProvider);

    return [
      // Adherence summary card
      SliverToBoxAdapter(
        child: GradientStatsCard(
          takenToday: adherence.takenToday,
          totalToday: adherence.totalToday,
          currentStreak: adherence.currentStreak,
          onTap: () {
            // TODO: Navigate to analytics
            context.push('/analytics');
          },
        ),
      ),

      // Drug interaction warnings
      SliverToBoxAdapter(
        child: _buildInteractionWarnings(context),
      ),

      // Quick Actions Cards
      SliverToBoxAdapter(
        child: _buildQuickActions(context),
      ),

      // Health Insights Card
      SliverToBoxAdapter(
        child: _buildInsightsCard(context),
      ),

      // Timeline sections
      TimelineSection(
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

      // Bottom padding
      const SliverToBoxAdapter(
        child: SizedBox(height: 80),
      ),
    ];
  }

  Widget _buildInsightsCard(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => context.push('/insights'),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.healthInsights,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.aiPoweredAnalysis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.medication,
                  label: l10n.takeDose,
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    // Scroll to timeline section (current page)
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.add_circle,
                  label: l10n.addMedicine,
                  color: const Color(0xFF2196F3),
                  onTap: () => context.push(AppConstants.routeAddReminder),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.analytics,
                  label: l10n.viewStats,
                  color: const Color(0xFF9C27B0),
                  onTap: () => context.push('/analytics'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.chat,
                  label: l10n.askAI,
                  color: const Color(0xFFFF9800),
                  onTap: () => context.push('/chatbot'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionWarnings(BuildContext context) {
    final interactionsAsync = ref.watch(allInteractionsProvider);

    return interactionsAsync.when(
      data: (warnings) {
        if (warnings.isEmpty) {
          return const SizedBox.shrink();
        }

        // Show only the most severe warning
        final mostSevere = warnings.first;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Card(
            elevation: 4,
            color: Colors.red.shade50,
            child: InkWell(
              onTap: () {
                // Show dialog with all warnings
                _showAllInteractionsDialog(warnings);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.warning,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            warnings.length == 1
                                ? 'Drug Interaction Detected'
                                : '${warnings.length} Drug Interactions Detected',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${mostSevere.medication1} + ${mostSevere.medication2}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap to view details',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.red.shade700,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showAllInteractionsDialog(List<InteractionWarning> warnings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Drug Interactions'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: warnings.length,
            itemBuilder: (context, index) {
              final warning = warnings[index];
              return InteractionWarningCard(
                warning: warning,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to medications list
              context.push('/medications');
            },
            child: const Text('View Medications'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1, curve: Curves.elasticOut),
      ),
      child: FloatingActionButton.extended(
        onPressed: _navigateToAddMedication,
        icon: const Icon(Icons.add),
        label: Text(l10n.addMedicine),
        elevation: 4,
      ),
    );
  }

  Future<void> _refreshData() async {
    await ref.read(todayDosesProvider.notifier).refresh();
  }

  void _navigateToAddMedication() {
    context.push(AppConstants.routeAddReminder);
  }

  Future<void> _requestNotificationPermission() async {
    // TODO: Request notification permission
    ref.read(notificationPermissionProvider.notifier).updatePermission(true);

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

  Future<void> _showLearnMoreDialog() async {
    await showDialog(
      context: context,
      builder: (context) => _LearnMoreDialog(),
    );
  }
}

/// Learn more dialog
class _LearnMoreDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.howMedAssistWorks),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LearnMoreItem(
            icon: Icons.alarm,
            title: l10n.smartReminders,
            description: l10n.smartRemindersDescription,
          ),
          const SizedBox(height: 16),
          _LearnMoreItem(
            icon: Icons.cloud_off,
            title: l10n.privateData,
            description: l10n.privateDataDescription,
          ),
          const SizedBox(height: 16),
          _LearnMoreItem(
            icon: Icons.schedule,
            title: l10n.flexibleSnoozing,
            description: l10n.flexibleSnoozingDescription,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.gotIt),
        ),
      ],
    );
  }
}

/// Learn more item
class _LearnMoreItem extends StatelessWidget {

  const _LearnMoreItem({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Quick action card widget
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
