import 'dart:io';

import 'package:intl/intl.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

/// Analytics Export Service
/// Handles PDF and CSV export of medication adherence data
class AnalyticsExportService {
  /// Export analytics to PDF
  /// Creates a comprehensive report with statistics and charts
  Future<File> exportToPdf({
    required AdherenceStats stats,
    required List<MedicationInsight> medications,
    required StreakInfo streak,
    required List<TrendDataPoint> trendData,
    required List<HourlyAdherenceData> hourlyData,
    required DateTime startDate,
    required DateTime endDate,
    required AppLocalizations l10n,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM dd, yyyy');

    // Add pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader(startDate, endDate, dateFormat, l10n),
          pw.SizedBox(height: 24),

          // Summary Section
          _buildSummarySection(stats, streak, l10n),
          pw.SizedBox(height: 24),

          // Medications Section
          _buildMedicationsSection(medications, l10n),
          pw.SizedBox(height: 24),

          // Trend Analysis
          _buildTrendSection(trendData, l10n),
          pw.SizedBox(height: 24),

          // Time-of-Day Analysis
          _buildTimeAnalysisSection(hourlyData, l10n),
          pw.SizedBox(height: 24),

          // Footer
          _buildFooter(l10n),
        ],
      ),
    );

    // Save to file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/medassist_analytics_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// Share PDF report
  Future<void> sharePdfReport(File pdfFile) async {
    await Share.shareXFiles(
      [XFile(pdfFile.path)],
      subject: 'MedAssist Analytics Report',
      text: 'My medication adherence report from MedAssist',
    );
  }

  /// Export to CSV
  Future<File> exportToCsv({
    required List<Map<String, dynamic>> doseHistory,
  }) async {
    final csv = StringBuffer();

    // Header
    csv.writeln('Date,Time,Medication,Status,Notes');

    // Data rows
    for (final dose in doseHistory) {
      final date = dose['date'] as String;
      final time = dose['time'] as String;
      final medication = dose['medication'] as String;
      final status = dose['status'] as String;
      final notes = (dose['notes'] as String? ?? '').replaceAll(',', ';');

      csv.writeln('$date,$time,$medication,$status,$notes');
    }

    // Save to file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/medassist_data_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv.toString());

    return file;
  }

  // PDF Building Methods

  pw.Widget _buildHeader(DateTime startDate, DateTime endDate, DateFormat format, AppLocalizations l10n) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          l10n.medAssistAnalyticsReport,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          l10n.reportPeriod(format.format(startDate), format.format(endDate)),
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  pw.Widget _buildSummarySection(AdherenceStats stats, StreakInfo streak, AppLocalizations l10n) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          l10n.summary,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              _buildStatRow(l10n.overallAdherence, '${stats.adherencePercentage.toStringAsFixed(1)}%'),
              _buildStatRow(l10n.totalDoses, '${stats.totalDoses}'),
              _buildStatRow(l10n.taken, '${stats.takenDoses}'),
              _buildStatRow(l10n.missed, '${stats.missedDoses}'),
              _buildStatRow(l10n.skipped, '${stats.skippedDoses}'),
              pw.Divider(),
              _buildStatRow(l10n.currentStreak, '${streak.currentStreak} ${l10n.days}'),
              _buildStatRow(l10n.bestStreak, '${streak.bestStreak} ${l10n.days}'),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildStatRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMedicationsSection(List<MedicationInsight> medications, AppLocalizations l10n) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          l10n.medicationPerformance,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell(l10n.medication, isHeader: true),
                _buildTableCell(l10n.adherence, isHeader: true),
                _buildTableCell(l10n.taken, isHeader: true),
                _buildTableCell(l10n.total, isHeader: true),
              ],
            ),
            // Data rows
            ...medications.take(10).map((med) => pw.TableRow(
              children: [
                _buildTableCell(med.medicationName),
                _buildTableCell('${med.adherenceRate.toStringAsFixed(1)}%'),
                _buildTableCell('${med.takenDoses}'),
                _buildTableCell('${med.totalDoses}'),
              ],
            )),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildTrendSection(List<TrendDataPoint> trendData, AppLocalizations l10n) {
    if (trendData.isEmpty) {
      return pw.SizedBox.shrink();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          l10n.adherenceTrend,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          height: 150,
          child: _buildSimpleLineChart(trendData, l10n),
        ),
      ],
    );
  }

  pw.Widget _buildSimpleLineChart(List<TrendDataPoint> data, AppLocalizations l10n) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        '${l10n.adherenceTrend}: ${data.first.adherencePercentage.toStringAsFixed(1)}% → ${data.last.adherencePercentage.toStringAsFixed(1)}%',
        style: const pw.TextStyle(fontSize: 11),
      ),
    );
  }

  pw.Widget _buildTimeAnalysisSection(List<HourlyAdherenceData> hourlyData, AppLocalizations l10n) {
    // Find best and worst hours
    final hoursWithData = hourlyData.where((h) => h.totalDoses > 0).toList();

    if (hoursWithData.isEmpty) {
      return pw.SizedBox.shrink();
    }

    hoursWithData.sort((a, b) => b.adherencePercentage.compareTo(a.adherencePercentage));
    final bestHour = hoursWithData.first;
    final worstHour = hoursWithData.last;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          l10n.timeOfDayAnalysis,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.green50,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '✓ ${_formatHourForPdf(bestHour.hour)}',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.Text(
                '  ${bestHour.adherencePercentage.toStringAsFixed(1)}% ${l10n.adherence} (${bestHour.takenDoses}/${bestHour.totalDoses})',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '⚠ ${_formatHourForPdf(worstHour.hour)}',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.Text(
                '  ${worstHour.adherencePercentage.toStringAsFixed(1)}% ${l10n.adherence} (${worstHour.takenDoses}/${worstHour.totalDoses})',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatHourForPdf(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }

  pw.Widget _buildFooter(AppLocalizations l10n) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Text(
          l10n.generatedOn(DateFormat('MMMM dd, yyyy HH:mm').format(DateTime.now())),
          style: const pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }
}
