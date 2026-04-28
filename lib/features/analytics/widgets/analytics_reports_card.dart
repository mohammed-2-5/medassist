import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/haptic/haptic_service.dart';

/// Card that links to the Reports screen and provides quick export shortcuts.
class AnalyticsReportsCard extends StatelessWidget {
  const AnalyticsReportsCard({
    required this.onNavigateToReports,
    required this.onExportPdf,
    super.key,
  });

  /// Called when the card or the "Medications CSV" chip is tapped.
  final VoidCallback onNavigateToReports;

  /// Called when the "Adherence PDF" chip is tapped.
  final VoidCallback onExportPdf;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      child: InkWell(
        onTap: () {
          HapticService.light();
          onNavigateToReports();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.secondaryContainer,
                colorScheme.tertiaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh.withValues(
                        alpha: 0.9,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.file_download_outlined,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.reportsExport,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSecondaryContainer,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.exportYourDataDescription,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: colorScheme.onSecondaryContainer
                                    .withOpacity(0.8),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_back_ios
                        : Icons.arrow_forward_ios,
                    color: colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickExportChip(
                    label: l10n.medicationsCsv,
                    icon: Icons.medication,
                    colorScheme: colorScheme,
                    onTap: onNavigateToReports,
                  ),
                  _QuickExportChip(
                    label: l10n.adherencePDF,
                    icon: Icons.analytics,
                    colorScheme: colorScheme,
                    onTap: onExportPdf,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickExportChip extends StatelessWidget {
  const _QuickExportChip({
    required this.label,
    required this.icon,
    required this.colorScheme,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
