import 'package:med_assist/core/database/app_database.dart';

/// Drug interaction warning model
class InteractionWarning {
  InteractionWarning({
    required this.medication1,
    required this.medication2,
    required this.severity,
    required this.description,
    required this.recommendation,
  });

  final String medication1;
  final String medication2;
  final InteractionSeverity severity;
  final String description;
  final String recommendation;

  @override
  String toString() {
    return '$medication1 + $medication2: $description';
  }
}

/// Interaction severity levels
enum InteractionSeverity {
  minor,     // Minor interaction, monitor
  moderate,  // Moderate interaction, caution advised
  major,     // Major interaction, avoid if possible
  severe,    // Severe interaction, do not combine
}

/// Service for checking drug-drug interactions
class DrugInteractionService {
  DrugInteractionService(this._database);

  final AppDatabase _database;

  /// Common drug interactions database
  /// Format: 'drug1' -> List of drugs that interact with drug1
  /// This is a simplified database. In production, use a comprehensive medical API
  static const Map<String, List<String>> _interactionPairs = {
    // Anticoagulants
    'warfarin': ['aspirin', 'ibuprofen', 'naproxen', 'diclofenac', 'vitamin k', 'vitamin e'],

    // NSAIDs
    'aspirin': ['warfarin', 'ibuprofen', 'naproxen', 'heparin'],
    'ibuprofen': ['warfarin', 'aspirin', 'lithium', 'methotrexate'],
    'naproxen': ['warfarin', 'aspirin', 'lithium'],
    'diclofenac': ['warfarin', 'methotrexate'],

    // Diabetes medications
    'metformin': ['alcohol', 'contrast dye', 'iodine'],
    'insulin': ['alcohol', 'beta blockers'],
    'glipizide': ['alcohol', 'beta blockers'],

    // Blood pressure medications
    'lisinopril': ['potassium', 'nsaids', 'lithium'],
    'losartan': ['potassium', 'nsaids'],
    'amlodipine': ['simvastatin', 'clarithromycin'],
    'atenolol': ['insulin', 'calcium'],

    // Statins
    'atorvastatin': ['clarithromycin', 'itraconazole', 'grapefruit'],
    'simvastatin': ['amlodipine', 'clarithromycin', 'grapefruit'],

    // Antibiotics
    'ciprofloxacin': ['theophylline', 'warfarin', 'antacids'],
    'azithromycin': ['warfarin', 'digoxin'],
    'clarithromycin': ['simvastatin', 'atorvastatin', 'warfarin'],

    // Antidepressants
    'sertraline': ['tramadol', 'warfarin', 'nsaids'],
    'fluoxetine': ['tramadol', 'warfarin', 'aspirin'],
    'citalopram': ['tramadol', 'nsaids'],

    // Pain medications
    'tramadol': ['sertraline', 'fluoxetine', 'citalopram'],

    // Other common medications
    'digoxin': ['amiodarone', 'verapamil', 'quinidine'],
    'lithium': ['ibuprofen', 'naproxen', 'lisinopril'],
    'theophylline': ['ciprofloxacin', 'erythromycin'],
    'levothyroxine': ['calcium', 'iron', 'antacids'],
  };

  /// Severity levels for drug pairs
  /// Format: 'drug1:drug2' -> severity
  static const Map<String, InteractionSeverity> _severityLevels = {
    // Severe interactions
    'warfarin:aspirin': InteractionSeverity.severe,
    'warfarin:ibuprofen': InteractionSeverity.major,
    'warfarin:naproxen': InteractionSeverity.major,
    'metformin:alcohol': InteractionSeverity.major,
    'insulin:alcohol': InteractionSeverity.major,

    // Major interactions
    'atorvastatin:clarithromycin': InteractionSeverity.major,
    'simvastatin:amlodipine': InteractionSeverity.major,
    'lisinopril:potassium': InteractionSeverity.major,
    'tramadol:sertraline': InteractionSeverity.major,

    // Moderate interactions
    'aspirin:ibuprofen': InteractionSeverity.moderate,
    'levothyroxine:calcium': InteractionSeverity.moderate,
    'atenolol:insulin': InteractionSeverity.moderate,

    // Default to moderate for unlisted pairs
  };

  /// Detailed descriptions for common interactions
  static const Map<String, String> _interactionDescriptions = {
    'warfarin:aspirin': 'Increased risk of bleeding. Both medications thin the blood.',
    'warfarin:ibuprofen': 'NSAIDs can increase bleeding risk when combined with warfarin.',
    'metformin:alcohol': 'Alcohol can increase risk of lactic acidosis with metformin.',
    'lisinopril:potassium': 'ACE inhibitors can increase potassium levels, leading to hyperkalemia.',
    'atorvastatin:clarithromycin': 'Clarithromycin increases statin levels, raising risk of muscle damage.',
    'simvastatin:amlodipine': 'Amlodipine increases simvastatin levels, raising muscle damage risk.',
    'tramadol:sertraline': 'Increased risk of serotonin syndrome when combined.',
    'levothyroxine:calcium': 'Calcium can reduce thyroid hormone absorption.',
    'aspirin:ibuprofen': 'Taking together may reduce aspirin\'s cardioprotective effects.',
    'insulin:alcohol': 'Alcohol can cause dangerous blood sugar drops with insulin.',
  };

  /// Recommendations for common interactions
  static const Map<String, String> _interactionRecommendations = {
    'warfarin:aspirin': 'Consult your doctor immediately. This combination requires careful monitoring.',
    'warfarin:ibuprofen': 'Consider acetaminophen as an alternative. If necessary, use lowest dose and monitor closely.',
    'metformin:alcohol': 'Avoid alcohol or limit to small amounts. Discuss with your doctor.',
    'lisinopril:potassium': 'Monitor potassium levels regularly. Avoid potassium supplements without doctor approval.',
    'atorvastatin:clarithromycin': 'Consider suspending statin during antibiotic treatment. Consult your doctor.',
    'tramadol:sertraline': 'Watch for symptoms of serotonin syndrome. Notify doctor if you experience confusion, fever, or rapid heart rate.',
    'levothyroxine:calcium': 'Take calcium at least 4 hours apart from thyroid medication.',
    'aspirin:ibuprofen': 'Take aspirin at least 2 hours before ibuprofen if both are needed.',
    'insulin:alcohol': 'Monitor blood sugar closely if consuming alcohol. Have snacks available.',
  };

  /// Check for interactions between all user's medications
  Future<List<InteractionWarning>> checkAllInteractions() async {
    final medications = await _database.getAllMedications();
    return checkInteractions(medications);
  }

  /// Check for interactions in a list of medications
  List<InteractionWarning> checkInteractions(List<Medication> medications) {
    final warnings = <InteractionWarning>[];

    // Check each pair of medications
    for (var i = 0; i < medications.length; i++) {
      for (var j = i + 1; j < medications.length; j++) {
        final med1Name = medications[i].medicineName.toLowerCase();
        final med2Name = medications[j].medicineName.toLowerCase();

        final warning = _checkPairInteraction(
          medications[i].medicineName,
          medications[j].medicineName,
          med1Name,
          med2Name,
        );

        if (warning != null) {
          warnings.add(warning);
        }
      }
    }

    // Sort by severity (severe first)
    warnings.sort((a, b) => b.severity.index.compareTo(a.severity.index));

    return warnings;
  }

  /// Check if a specific medication would interact with existing medications
  Future<List<InteractionWarning>> checkNewMedication(String medicationName) async {
    final existingMedications = await _database.getAllMedications();
    final warnings = <InteractionWarning>[];

    final newMedName = medicationName.toLowerCase();

    for (final existingMed in existingMedications) {
      final existingMedName = existingMed.medicineName.toLowerCase();

      final warning = _checkPairInteraction(
        medicationName,
        existingMed.medicineName,
        newMedName,
        existingMedName,
      );

      if (warning != null) {
        warnings.add(warning);
      }
    }

    warnings.sort((a, b) => b.severity.index.compareTo(a.severity.index));

    return warnings;
  }

  /// Check interaction between two medication names
  InteractionWarning? _checkPairInteraction(
    String med1Display,
    String med2Display,
    String med1Lower,
    String med2Lower,
  ) {
    // Check if med1 interacts with med2
    final interactsWithMed1 = _interactionPairs[med1Lower];
    final interactsWithMed2 = _interactionPairs[med2Lower];

    bool hasInteraction = false;
    String? pairKey;

    if (interactsWithMed1 != null && interactsWithMed1.contains(med2Lower)) {
      hasInteraction = true;
      pairKey = '$med1Lower:$med2Lower';
    } else if (interactsWithMed2 != null && interactsWithMed2.contains(med1Lower)) {
      hasInteraction = true;
      pairKey = '$med2Lower:$med1Lower';
    }

    if (!hasInteraction) return null;

    // Get severity (default to moderate if not specified)
    final severity = _severityLevels[pairKey] ?? InteractionSeverity.moderate;

    // Get description (or use generic)
    final description = _interactionDescriptions[pairKey] ??
        'These medications may interact. Monitor for side effects.';

    // Get recommendation (or use generic)
    final recommendation = _interactionRecommendations[pairKey] ??
        'Consult your doctor or pharmacist about this combination.';

    return InteractionWarning(
      medication1: med1Display,
      medication2: med2Display,
      severity: severity,
      description: description,
      recommendation: recommendation,
    );
  }

  /// Get severity color for UI display
  static String getSeverityColor(InteractionSeverity severity) {
    switch (severity) {
      case InteractionSeverity.minor:
        return '#4CAF50'; // Green
      case InteractionSeverity.moderate:
        return '#FF9800'; // Orange
      case InteractionSeverity.major:
        return '#FF5722'; // Deep Orange
      case InteractionSeverity.severe:
        return '#F44336'; // Red
    }
  }

  /// Get severity label for UI display
  static String getSeverityLabel(InteractionSeverity severity) {
    switch (severity) {
      case InteractionSeverity.minor:
        return 'Minor';
      case InteractionSeverity.moderate:
        return 'Moderate';
      case InteractionSeverity.major:
        return 'Major';
      case InteractionSeverity.severe:
        return 'Severe';
    }
  }

  /// Get severity description
  static String getSeverityDescription(InteractionSeverity severity) {
    switch (severity) {
      case InteractionSeverity.minor:
        return 'Monitor for side effects';
      case InteractionSeverity.moderate:
        return 'Use with caution';
      case InteractionSeverity.major:
        return 'Avoid if possible';
      case InteractionSeverity.severe:
        return 'Do not combine';
    }
  }

  /// Check if any severe interactions exist
  Future<bool> hasSevereInteractions() async {
    final warnings = await checkAllInteractions();
    return warnings.any((w) =>
        w.severity == InteractionSeverity.severe ||
        w.severity == InteractionSeverity.major);
  }

  /// Get count of interactions by severity
  Future<Map<InteractionSeverity, int>> getInteractionCounts() async {
    final warnings = await checkAllInteractions();
    final counts = <InteractionSeverity, int>{
      InteractionSeverity.minor: 0,
      InteractionSeverity.moderate: 0,
      InteractionSeverity.major: 0,
      InteractionSeverity.severe: 0,
    };

    for (final warning in warnings) {
      counts[warning.severity] = (counts[warning.severity] ?? 0) + 1;
    }

    return counts;
  }
}
