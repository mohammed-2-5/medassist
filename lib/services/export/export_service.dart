import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Service for exporting medication data to various formats
class ExportService {
  ExportService._();

  /// Export medications list to CSV
  static Future<File> exportMedicationsToCSV(
    List<Medication> medications,
  ) async {
    final csvData = [
      // Header row
      [
        'ID',
        'Name',
        'Type',
        'Dosage',
        'Unit',
        'Times Per Day',
        'Duration (Days)',
        'Stock Quantity',
        'Low Stock Alert (Days)',
        'Expiry Date',
        'Expiry Alert (Days)',
        'Active',
        'Start Date',
        'Created At',
      ],
      // Data rows
      ...medications.map((med) => [
            med.id.toString(),
            med.medicineName,
            med.medicineType,
            med.dosePerTime.toString(),
            med.doseUnit,
            med.timesPerDay.toString(),
            med.durationDays.toString(),
            med.stockQuantity.toString(),
            med.reminderDaysBeforeRunOut.toString(),
            med.expiryDate?.toIso8601String() ?? 'N/A',
            med.reminderDaysBeforeExpiry.toString(),
            if (med.isActive) 'Yes' else 'No',
            DateFormat('yyyy-MM-dd').format(med.startDate),
            DateFormat('yyyy-MM-dd HH:mm').format(med.createdAt),
          ]),
    ];

    final csv = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/medications_$timestamp.csv';
    final file = File(filePath);
    await file.writeAsString(csv);

    return file;
  }

  /// Export dose history to CSV
  static Future<File> exportDoseHistoryToCSV(
    List<DoseHistoryData> history,
    Map<int, Medication> medicationsMap,
  ) async {
    final csvData = [
      // Header row
      [
        'Date',
        'Time',
        'Medication',
        'Status',
        'Actual Time',
        'Notes',
      ],
      // Data rows
      ...history.map((record) {
        final medication = medicationsMap[record.medicationId];
        final scheduledTime = TimeOfDay(
          hour: record.scheduledHour,
          minute: record.scheduledMinute,
        );
        return [
          DateFormat('yyyy-MM-dd').format(record.scheduledDate),
          '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}',
          medication?.medicineName ?? 'Unknown',
          record.status,
          if (record.actualTime != null) DateFormat('HH:mm').format(record.actualTime!) else 'N/A',
          record.notes ?? '',
        ];
      }),
    ];

    final csv = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/dose_history_$timestamp.csv';
    final file = File(filePath);
    await file.writeAsString(csv);

    return file;
  }

  /// Export stock history to CSV
  static Future<File> exportStockHistoryToCSV(
    List<StockHistoryData> history,
    Map<int, Medication> medicationsMap,
  ) async {
    final csvData = [
      // Header row
      [
        'Date',
        'Medication',
        'Previous Stock',
        'New Stock',
        'Change Amount',
        'Change Type',
        'Notes',
      ],
      // Data rows
      ...history.map((record) {
        final medication = medicationsMap[record.medicationId];
        return [
          DateFormat('yyyy-MM-dd HH:mm').format(record.changeDate),
          medication?.medicineName ?? 'Unknown',
          record.previousStock.toString(),
          record.newStock.toString(),
          record.changeAmount.toString(),
          record.changeType,
          record.notes ?? '',
        ];
      }),
    ];

    final csv = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/stock_history_$timestamp.csv';
    final file = File(filePath);
    await file.writeAsString(csv);

    return file;
  }

  /// Generate PDF report for medications
  static Future<File> generateMedicationsPDF(
    List<Medication> medications,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Title
          pw.Header(
            level: 0,
            child: pw.Text(
              'Medications Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Generated on: ${DateFormat('MMMM dd, yyyy HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Summary',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text('Total Medications: ${medications.length}'),
                pw.Text(
                    'Active: ${medications.where((m) => m.isActive).length}'),
                pw.Text(
                    'Paused: ${medications.where((m) => !m.isActive).length}'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Medications table
          pw.Text(
            'Medications List',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            context: context,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blue700,
            ),
            cellHeight: 25,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
            },
            headers: [
              'Name',
              'Type',
              'Dosage',
              'Frequency',
              'Status',
            ],
            data: medications.map((med) {
              return [
                med.medicineName,
                med.medicineType,
                '${med.dosePerTime} ${med.doseUnit}',
                '${med.timesPerDay}x/day',
                if (med.isActive) 'Active' else 'Paused',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/medications_report_$timestamp.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// Generate adherence PDF report
  static Future<File> generateAdherencePDF({
    required Map<String, int> stats,
    required List<DoseHistoryData> recentHistory,
    required Map<int, Medication> medicationsMap,
  }) async {
    final pdf = pw.Document();

    final total = stats.values.fold<int>(0, (sum, val) => sum + val);
    final takenPercentage = total > 0
        ? ((stats['taken'] ?? 0) / total * 100).toStringAsFixed(1)
        : '0.0';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Title
          pw.Header(
            level: 0,
            child: pw.Text(
              'Adherence Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Generated on: ${DateFormat('MMMM dd, yyyy HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),

          // Statistics
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Adherence Statistics',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Overall Adherence:'),
                    pw.Text(
                      '$takenPercentage%',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green700,
                      ),
                    ),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Taken:'),
                    pw.Text(
                      '${stats['taken'] ?? 0}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Skipped:'),
                    pw.Text(
                      '${stats['skipped'] ?? 0}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Missed:'),
                    pw.Text(
                      '${stats['missed'] ?? 0}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Doses:'),
                    pw.Text(
                      '$total',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Recent history
          if (recentHistory.isNotEmpty) ...[
            pw.Text(
              'Recent Dose History',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue700,
              ),
              cellHeight: 25,
              headers: [
                'Date',
                'Medication',
                'Time',
                'Status',
              ],
              data: recentHistory.take(20).map((record) {
                final medication = medicationsMap[record.medicationId];
                final scheduledTime = TimeOfDay(
                  hour: record.scheduledHour,
                  minute: record.scheduledMinute,
                );
                return [
                  DateFormat('MMM dd').format(record.scheduledDate),
                  medication?.medicineName ?? 'Unknown',
                  '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}',
                  record.status.toUpperCase(),
                ];
              }).toList(),
            ),
          ],
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/adherence_report_$timestamp.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}

/// TimeOfDay helper for formatting
class TimeOfDay {

  const TimeOfDay({required this.hour, required this.minute});
  final int hour;
  final int minute;
}
