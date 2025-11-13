import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/haptic/haptic_service.dart';
import 'package:med_assist/services/notification/notification_service.dart';

/// System Health & Diagnostics Screen
class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  final _notificationService = NotificationService();
  Map<String, dynamic>? _diagnostics;
  Map<String, int>? _dbStats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDiagnostics();
  }

  Future<void> _loadDiagnostics() async {
    setState(() => _loading = true);
    try {
      final diagnostics = await _notificationService.getDiagnostics();
      final database = ref.read(appDatabaseProvider);

      // Get database statistics
      final medications = await database.getAllMedications();
      final allHistory = await database.getAllDoseHistory();

      setState(() {
        _diagnostics = diagnostics;
        _dbStats = {
          'medications': medications.length,
          'doseHistory': allHistory.length,
          'activeMeds': medications.where((m) => m.isActive).length,
        };
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading diagnostics: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.purpleGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.systemHealth,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.appDiagnostics,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ).animate(delay: 200.ms).fadeIn(duration: 600.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: () {
                  HapticService.light();
                  _loadDiagnostics();
                },
              ),
            ],
          ),

          // Content
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // System Status Section
                    _buildSectionHeader(theme, 'System Status', Icons.check_circle_rounded),
                    const SizedBox(height: 12),
                    _buildPermissionCard(
                      theme,
                      colorScheme,
                      'Notification Permission',
                      _diagnostics?['notification_permission'] == true,
                      'Required for medication reminders',
                      Icons.notifications_rounded,
                      0,
                    ),
                    const SizedBox(height: 12),
                    _buildPermissionCard(
                      theme,
                      colorScheme,
                      'Exact Alarms Permission',
                      _diagnostics?['exact_alarms'] == true,
                      'Required for precise reminder timing on Android 12+',
                      Icons.alarm_rounded,
                      1,
                    ),

                    const SizedBox(height: 32),

                    // Database Stats Section
                    _buildSectionHeader(theme, 'Database Statistics', Icons.storage_rounded),
                    const SizedBox(height: 12),
                    _buildStatsGrid(theme, colorScheme),

                    const SizedBox(height: 32),

                    // Device Info Section
                    _buildSectionHeader(theme, 'Device Information', Icons.phone_android_rounded),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      theme,
                      colorScheme,
                      'Timezone',
                      (_diagnostics?['timezone'] as String?) ?? 'Unknown',
                      Icons.public_rounded,
                      2,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      theme,
                      colorScheme,
                      'Plugin Version',
                      (_diagnostics?['plugin_version'] as String?) ?? 'N/A',
                      Icons.extension_rounded,
                      3,
                    ),

                    const SizedBox(height: 32),

                    // Actions Section
                    _buildSectionHeader(theme, 'Testing & Actions', Icons.build_rounded),
                    const SizedBox(height: 12),
                    _buildActionButtons(theme, colorScheme),

                    const SizedBox(height: 32),

                    // Troubleshooting Section
                    _buildTroubleshootingSection(theme, colorScheme),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2);
  }

  Widget _buildPermissionCard(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    bool isGranted,
    String description,
    IconData icon,
    int index,
  ) {
    final statusColor = isGranted ? AppColors.successGreen : AppColors.errorRed;
    final statusGradient = isGranted ? AppColors.successGradient : LinearGradient(
      colors: [AppColors.errorRed, AppColors.errorRed.withOpacity(0.7)],
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: statusGradient.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: statusGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isGranted ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isGranted ? 'OK' : 'NEEDED',
              style: theme.textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: (index * 100).ms)
        .slideX(begin: 0.2, duration: 500.ms)
        .fadeIn();
  }

  Widget _buildStatsGrid(ThemeData theme, ColorScheme colorScheme) {
    if (_dbStats == null) return const SizedBox.shrink();

    final stats = [
      _StatItem(
        label: 'Total Medications',
        value: _dbStats!['medications']!,
        icon: Icons.medication_rounded,
        color: AppColors.primaryBlue,
      ),
      _StatItem(
        label: 'Active Medications',
        value: _dbStats!['activeMeds']!,
        icon: Icons.check_circle_rounded,
        color: AppColors.successGreen,
      ),
      _StatItem(
        label: 'Dose Records',
        value: _dbStats!['doseHistory']!,
        icon: Icons.history_rounded,
        color: AppColors.accentPurple,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                stat.color.withOpacity(0.1),
                stat.color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: stat.color.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(stat.icon, color: stat.color, size: 32),
              const SizedBox(height: 8),
              Text(
                stat.value.toString(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: stat.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
            .animate(delay: (index * 100).ms)
            .scale(duration: 500.ms, curve: Curves.easeOut)
            .fadeIn();
      },
    );
  }

  Widget _buildInfoCard(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String value,
    IconData icon,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: (index * 100).ms)
        .slideX(begin: 0.2, duration: 500.ms)
        .fadeIn();
  }

  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // Test Notification
        _buildActionButton(
          theme,
          'Send Test Notification',
          'Test if notifications are working',
          Icons.notifications_active_rounded,
          AppColors.primaryBlue,
          () async {
            HapticService.medium();
            await _notificationService.showTestNotification();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Test notification sent!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          0,
        ),
        const SizedBox(height: 12),

        // Schedule Test
        _buildActionButton(
          theme,
          'Schedule Test (1 min)',
          'Schedule a test notification for 1 minute from now',
          Icons.schedule_rounded,
          AppColors.warningOrange,
          () async {
            HapticService.medium();
            await _notificationService.scheduleTestNotificationIn1Minute();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Test scheduled for 1 minute from now!'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 5),
                ),
              );
            }
          },
          1,
        ),
        const SizedBox(height: 12),

        // Request Permissions
        _buildActionButton(
          theme,
          'Request Permissions',
          'Request all necessary permissions',
          Icons.security_rounded,
          AppColors.accentPurple,
          () async {
            HapticService.medium();
            final granted = await _notificationService.requestPermissions();
            await _loadDiagnostics();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(granted
                      ? 'Permissions granted!'
                      : 'Some permissions denied'),
                  backgroundColor: granted ? Colors.green : Colors.orange,
                ),
              );
            }
          },
          2,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    int index,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    )
        .animate(delay: (index * 100).ms)
        .slideX(begin: 0.2, duration: 500.ms)
        .fadeIn();
  }

  Widget _buildTroubleshootingSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.warningGradient.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.warningOrange.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.warningGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.help_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Troubleshooting',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTroubleshootingItem(
            theme,
            'Notifications not appearing?',
            '• Check permissions above\n• Disable battery optimization\n• Enable exact alarms (Android 12+)\n• Test with "Send Test Notification"',
          ),
          const SizedBox(height: 12),
          _buildTroubleshootingItem(
            theme,
            'App crashing?',
            '• Clear app data and restart\n• Ensure all permissions are granted\n• Check device timezone settings',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/settings/notification-debug'),
              icon: const Icon(Icons.bug_report_rounded),
              label: const Text('Advanced Diagnostics'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 600.ms).fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildTroubleshootingItem(ThemeData theme, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _StatItem {

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final int value;
  final IconData icon;
  final Color color;
}

extension on LinearGradient {
  LinearGradient withOpacity(double opacity) {
    return LinearGradient(
      colors: colors.map((color) => color.withOpacity(opacity)).toList(),
      begin: begin,
      end: end,
    );
  }
}
