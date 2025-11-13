class Reminder {

  Reminder({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.scheduleTime,
    required this.frequency,
    required this.createdAt, this.isActive = true,
    this.notes,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      medicationName: json['medicationName'] as String,
      dosage: json['dosage'] as String,
      scheduleTime: DateTime.parse(json['scheduleTime'] as String),
      frequency: json['frequency'] as String,
      isActive: (json['isActive'] as int) == 1,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
  final String id;
  final String medicationName;
  final String dosage;
  final DateTime scheduleTime;
  final String frequency; // daily, weekly, etc.
  final bool isActive;
  final String? notes;
  final DateTime createdAt;

  Reminder copyWith({
    String? id,
    String? medicationName,
    String? dosage,
    DateTime? scheduleTime,
    String? frequency,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      scheduleTime: scheduleTime ?? this.scheduleTime,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationName': medicationName,
      'dosage': dosage,
      'scheduleTime': scheduleTime.toIso8601String(),
      'frequency': frequency,
      'isActive': isActive ? 1 : 0,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
