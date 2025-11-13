import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/services/export/export_service.dart';
import 'package:share_plus/share_plus.dart';

/// Reports screen for exporting data
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home') ,
        ),
        title: const Text('Reports & Export'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text(
            'Export Your Data',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate reports and export your medication data in various formats',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // CSV Exports Section
          _buildSectionHeader(theme, 'CSV Exports', Icons.table_chart),
          const SizedBox(height: 16),
          _buildExportCard(
            context,
            ref,
            title: 'Medications List',
            description: 'Export all medications data to CSV',
            icon: Icons.medication,
            color: Colors.blue,
            onExport: () => _exportMedicationsCSV(context, ref),
          ),
          const SizedBox(height: 12),
          _buildExportCard(
            context,
            ref,
            title: 'Dose History',
            description: 'Export complete dose history to CSV',
            icon: Icons.history,
            color: Colors.green,
            onExport: () => _exportDoseHistoryCSV(context, ref),
          ),
          const SizedBox(height: 12),
          _buildExportCard(
            context,
            ref,
            title: 'Stock History',
            description: 'Export stock changes history to CSV',
            icon: Icons.inventory,
            color: Colors.orange,
            onExport: () => _exportStockHistoryCSV(context, ref),
          ),

          const SizedBox(height: 32),

          // PDF Reports Section
          _buildSectionHeader(theme, 'PDF Reports', Icons.picture_as_pdf),
          const SizedBox(height: 16),
          _buildExportCard(
            context,
            ref,
            title: 'Medications Report',
            description: 'Generate detailed PDF report of all medications',
            icon: Icons.description,
            color: Colors.purple,
            onExport: () => _generateMedicationsPDF(context, ref),
          ),
          const SizedBox(height: 12),
          _buildExportCard(
            context,
            ref,
            title: 'Adherence Report',
            description: 'Generate PDF report with adherence statistics',
            icon: Icons.analytics,
            color: Colors.teal,
            onExport: () => _generateAdherencePDF(context, ref),
          ),

          const SizedBox(height: 32),

          // Info card
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Exported files will be saved to your device and can be shared immediately',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
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
        Icon(icon, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExportCard(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onExport,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onExport,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
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
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.file_download,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportMedicationsCSV(BuildContext context, WidgetRef ref) async {
    try {
      _showLoadingDialog(context);

      final medications = await ref.read(medicationsProvider.future);
      final file = await ExportService.exportMedicationsToCSV(medications);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        // Share the file with proper description
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Med Assist - Medications Export',
          text: 'Here is your medications list exported from Med Assist app. '
              'File: ${file.path.split('/').last}',
        );

        _showSuccessSnackbar(context, 'Medications exported successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorSnackbar(context, 'Failed to export: $e');
      }
    }
  }

  Future<void> _exportDoseHistoryCSV(BuildContext context, WidgetRef ref) async {
    try {
      _showLoadingDialog(context);

      final database = ref.read(appDatabaseProvider);
      final history = await database.getAllDoseHistory();
      final medications = await ref.read(medicationsProvider.future);

      // Create medications map
      final medicationsMap = {
        for (final med in medications) med.id: med,
      };

      final file =
          await ExportService.exportDoseHistoryToCSV(history, medicationsMap);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Med Assist - Dose History Export',
          text: 'Here is your complete dose history exported from Med Assist app. '
              'File: ${file.path.split('/').last}',
        );

        _showSuccessSnackbar(context, 'Dose history exported successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorSnackbar(context, 'Failed to export: $e');
      }
    }
  }

  Future<void> _exportStockHistoryCSV(BuildContext context, WidgetRef ref) async {
    try {
      _showLoadingDialog(context);

      final database = ref.read(appDatabaseProvider);
      final medications = await ref.read(medicationsProvider.future);

      // Get all stock history for all medications
      final allHistory = <StockHistoryData>[];
      for (final med in medications) {
        final history = await database.getStockHistory(med.id);
        allHistory.addAll(history);
      }

      // Create medications map
      final medicationsMap = {
        for (final med in medications) med.id: med,
      };

      final file = await ExportService.exportStockHistoryToCSV(
        allHistory,
        medicationsMap,
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Med Assist - Stock History Export',
          text: 'Here is your stock changes history exported from Med Assist app. '
              'File: ${file.path.split('/').last}',
        );

        _showSuccessSnackbar(context, 'Stock history exported successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorSnackbar(context, 'Failed to export: $e');
      }
    }
  }

  Future<void> _generateMedicationsPDF(BuildContext context, WidgetRef ref) async {
    try {
      _showLoadingDialog(context);

      final medications = await ref.read(medicationsProvider.future);
      final file = await ExportService.generateMedicationsPDF(medications);

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Med Assist - Medications Report',
          text: 'Here is your detailed medications report from Med Assist app. '
              'File: ${file.path.split('/').last}',
        );

        _showSuccessSnackbar(context, 'PDF report generated successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorSnackbar(context, 'Failed to generate PDF: $e');
      }
    }
  }

  Future<void> _generateAdherencePDF(BuildContext context, WidgetRef ref) async {
    try {
      _showLoadingDialog(context);

      final database = ref.read(appDatabaseProvider);
      final now = DateTime.now();
      final monthAgo = now.subtract(const Duration(days: 30));

      // Get adherence stats for last 30 days
      final stats = await database.getAdherenceStats(monthAgo, now);
      final history = await database.getAllDoseHistory();
      final medications = await ref.read(medicationsProvider.future);

      // Create medications map
      final medicationsMap = {
        for (final med in medications) med.id: med,
      };

      // Filter recent history (last 30 days)
      final recentHistory = history.where((record) {
        return record.scheduledDate.isAfter(monthAgo);
      }).toList();

      final file = await ExportService.generateAdherencePDF(
        stats: stats,
        recentHistory: recentHistory,
        medicationsMap: medicationsMap,
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Med Assist - Adherence Report',
          text: 'Here is your medication adherence report (last 30 days) from Med Assist app. '
              'File: ${file.path.split('/').last}',
        );

        _showSuccessSnackbar(context, 'Adherence report generated successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorSnackbar(context, 'Failed to generate PDF: $e');
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating export...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
