import 'package:med_assist/core/database/app_database.dart';

/// Service to provide medication context for AI chatbot
class MedicationContextService {
  MedicationContextService(this._database);
  final AppDatabase _database;

  /// Get current medication context for AI
  Future<String> getMedicationContext() async {
    final medications = await _database.getAllMedications();

    if (medications.isEmpty) {
      return '''
User Status: No medications currently being tracked.
Suggestion: Help user understand how to add their first medication.
''';
    }

    final buffer = StringBuffer();
    buffer.writeln('User is currently taking ${medications.length} medication(s):');
    buffer.writeln();

    for (final med in medications) {
      buffer.writeln('${med.medicineName}:');
      buffer.writeln('  - Type: ${med.medicineType}');
      if (med.strength != null && med.unit != null) {
        buffer.writeln('  - Strength: ${med.strength} ${med.unit}');
      }
      buffer.writeln('  - Frequency: ${med.timesPerDay} times per day');
      buffer.writeln('  - Dose: ${med.dosePerTime} ${med.doseUnit ?? 'unit'}(s) per time');

      if (med.stockQuantity > 0) {
        buffer.writeln('  - Stock: ${med.stockQuantity} remaining');
      }

      if (med.expiryDate != null) {
        final daysUntilExpiry = med.expiryDate!.difference(DateTime.now()).inDays;
        buffer.writeln('  - Expires in: $daysUntilExpiry days');
      }

      if (med.notes != null && med.notes!.isNotEmpty) {
        buffer.writeln('  - Notes: ${med.notes}');
      }

      buffer.writeln();
    }

    // Add adherence context
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final stats = await _database.getAdherenceStats(weekAgo, now);

    final taken = stats['taken'] ?? 0;
    final skipped = stats['skipped'] ?? 0;
    final total = taken + skipped;

    if (total > 0) {
      final adherence = ((taken / total) * 100).toStringAsFixed(1);
      buffer.writeln('Recent Adherence (7 days): $adherence% ($taken taken, $skipped skipped)');
    }

    return buffer.toString();
  }

  /// Get specific medication details
  Future<String?> getMedicationDetails(String medicationName) async {
    final medications = await _database.getAllMedications();
    final med = medications.where(
      (m) => m.medicineName.toLowerCase().contains(medicationName.toLowerCase()),
    ).firstOrNull;

    if (med == null) return null;

    final buffer = StringBuffer();
    buffer.writeln('Details for ${med.medicineName}:');
    buffer.writeln('Type: ${med.medicineType}');

    if (med.strength != null && med.unit != null) {
      buffer.writeln('Strength: ${med.strength} ${med.unit}');
    }

    buffer.writeln('Schedule: ${med.timesPerDay} times per day');
    buffer.writeln('Dose: ${med.dosePerTime} ${med.doseUnit ?? 'unit'}(s)');

    if (med.startDate != null) {
      final daysSince = DateTime.now().difference(med.startDate!).inDays;
      buffer.writeln('Taking since: $daysSince days ago');
    }

    if (med.stockQuantity > 0) {
      buffer.writeln('Stock remaining: ${med.stockQuantity}');

      // Calculate days until run out
      final dailyUsage = med.timesPerDay * med.dosePerTime;
      final daysRemaining = (med.stockQuantity / dailyUsage).floor();
      buffer.writeln('Will last approximately: $daysRemaining days');
    }

    if (med.expiryDate != null) {
      final daysUntilExpiry = med.expiryDate!.difference(DateTime.now()).inDays;
      if (daysUntilExpiry > 0) {
        buffer.writeln('Expires in: $daysUntilExpiry days');
      } else {
        buffer.writeln('WARNING: This medication has expired!');
      }
    }

    // Get recent dose history
    final history = await _database.getDoseHistory(med.id);
    final recentHistory = history.take(7).toList();
    if (recentHistory.isNotEmpty) {
      final recentTaken = recentHistory.where((d) => d.status == 'taken').length;
      final recentTotal = recentHistory.length;
      final recentAdherence = ((recentTaken / recentTotal) * 100).toStringAsFixed(1);
      buffer.writeln('Recent adherence: $recentAdherence% ($recentTaken/$recentTotal)');
    }

    if (med.notes != null && med.notes!.isNotEmpty) {
      buffer.writeln('Notes: ${med.notes}');
    }

    return buffer.toString();
  }

  /// Get low stock warnings
  Future<String> getLowStockWarnings() async {
    final lowStockMeds = await _database.getLowStockMedications();

    if (lowStockMeds.isEmpty) {
      return 'All medications have sufficient stock.';
    }

    final buffer = StringBuffer();
    buffer.writeln('⚠️ Low Stock Warnings:');
    buffer.writeln();

    for (final med in lowStockMeds) {
      final dailyUsage = med.timesPerDay * med.dosePerTime;
      final daysRemaining = dailyUsage > 0 ? (med.stockQuantity / dailyUsage).floor() : 0;

      buffer.writeln('${med.medicineName}:');
      buffer.writeln('  - Current stock: ${med.stockQuantity}');
      buffer.writeln('  - Days remaining: ~$daysRemaining days');
      buffer.writeln('  - Refill recommended');
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Get expiring medications
  Future<String> getExpiringMedications({int daysAhead = 30}) async {
    final expiringMeds = await _database.getExpiringMedications(daysAhead: daysAhead);

    if (expiringMeds.isEmpty) {
      return 'No medications expiring in the next $daysAhead days.';
    }

    final buffer = StringBuffer();
    buffer.writeln('⚠️ Expiring Soon:');
    buffer.writeln();

    for (final med in expiringMeds) {
      if (med.expiryDate == null) continue;

      final daysUntilExpiry = med.expiryDate!.difference(DateTime.now()).inDays;

      buffer.writeln('${med.medicineName}:');
      if (daysUntilExpiry > 0) {
        buffer.writeln('  - Expires in: $daysUntilExpiry days');
      } else {
        buffer.writeln('  - EXPIRED');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Get adherence summary
  Future<String> getAdherenceSummary({int days = 30}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final stats = await _database.getAdherenceStats(startDate, now);

    final taken = stats['taken'] ?? 0;
    final skipped = stats['skipped'] ?? 0;
    final total = taken + skipped;

    if (total == 0) {
      return 'No dose history recorded in the last $days days.';
    }

    final adherence = ((taken / total) * 100).toStringAsFixed(1);

    final buffer = StringBuffer();
    buffer.writeln('Adherence Summary (Last $days days):');
    buffer.writeln('  - Overall Adherence: $adherence%');
    buffer.writeln('  - Doses Taken: $taken');
    buffer.writeln('  - Doses Skipped: $skipped');
    buffer.writeln('  - Total Scheduled: $total');

    if (double.parse(adherence) >= 90) {
      buffer.writeln('  - Status: Excellent! 🎉');
    } else if (double.parse(adherence) >= 75) {
      buffer.writeln('  - Status: Good 👍');
    } else if (double.parse(adherence) >= 60) {
      buffer.writeln('  - Status: Fair - Room for improvement');
    } else {
      buffer.writeln('  - Status: Needs attention ⚠️');
    }

    return buffer.toString();
  }

  /// Build system prompt with medication context
  Future<String> buildSystemPrompt() async {
    return '''
You are a helpful AI assistant specialized in medication management. You help users:
- Track their medications
- Remember dosage schedules
- Understand their medications better
- Maintain adherence to their medication regimen
- Identify potential issues (low stock, expiring meds, missed doses)

Guidelines:
- Always be supportive and encouraging
- Provide clear, accurate information
- When discussing medical advice, remind users to consult their healthcare provider
- Help users stay on track with their medications
- Be concise but thorough
- Use simple, easy-to-understand language
- If asked about specific drugs, provide general educational information but emphasize consulting a doctor

${await getMedicationContext()}

Remember: You should never provide medical diagnosis or treatment recommendations. Always encourage users to consult with healthcare professionals for medical advice.
''';
  }

  /// Get quick suggestions based on context
  Future<List<String>> getQuickSuggestions() async {
    final suggestions = <String>[];
    final medications = await _database.getAllMedications();

    if (medications.isEmpty) {
      suggestions.addAll([
        'How do I add my first medication?',
        'What information do I need to track a medication?',
        'Can you help me set up reminders?',
      ]);
      return suggestions;
    }

    // Check for low stock
    final lowStock = await _database.getLowStockMedications();
    if (lowStock.isNotEmpty) {
      suggestions.add('Show me medications running low');
    }

    // Check for expiring meds
    final expiring = await _database.getExpiringMedications();
    if (expiring.isNotEmpty) {
      suggestions.add('Which medications are expiring soon?');
    }

    // General suggestions
    suggestions.addAll([
      'Show my adherence summary',
      'What medications am I taking?',
      'How am I doing with my medications?',
    ]);

    return suggestions.take(4).toList();
  }
}
