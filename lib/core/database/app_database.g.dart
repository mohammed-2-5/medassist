// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _medicineTypeMeta = const VerificationMeta(
    'medicineType',
  );
  @override
  late final GeneratedColumn<String> medicineType = GeneratedColumn<String>(
    'medicine_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicineNameMeta = const VerificationMeta(
    'medicineName',
  );
  @override
  late final GeneratedColumn<String> medicineName = GeneratedColumn<String>(
    'medicine_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicinePhotoPathMeta = const VerificationMeta(
    'medicinePhotoPath',
  );
  @override
  late final GeneratedColumn<String> medicinePhotoPath =
      GeneratedColumn<String>(
        'medicine_photo_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _strengthMeta = const VerificationMeta(
    'strength',
  );
  @override
  late final GeneratedColumn<String> strength = GeneratedColumn<String>(
    'strength',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isScannedMeta = const VerificationMeta(
    'isScanned',
  );
  @override
  late final GeneratedColumn<bool> isScanned = GeneratedColumn<bool>(
    'is_scanned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_scanned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timesPerDayMeta = const VerificationMeta(
    'timesPerDay',
  );
  @override
  late final GeneratedColumn<int> timesPerDay = GeneratedColumn<int>(
    'times_per_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dosePerTimeMeta = const VerificationMeta(
    'dosePerTime',
  );
  @override
  late final GeneratedColumn<double> dosePerTime = GeneratedColumn<double>(
    'dose_per_time',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _doseUnitMeta = const VerificationMeta(
    'doseUnit',
  );
  @override
  late final GeneratedColumn<String> doseUnit = GeneratedColumn<String>(
    'dose_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tablet'),
  );
  static const VerificationMeta _durationDaysMeta = const VerificationMeta(
    'durationDays',
  );
  @override
  late final GeneratedColumn<int> durationDays = GeneratedColumn<int>(
    'duration_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repetitionPatternMeta = const VerificationMeta(
    'repetitionPattern',
  );
  @override
  late final GeneratedColumn<String> repetitionPattern =
      GeneratedColumn<String>(
        'repetition_pattern',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('daily'),
      );
  static const VerificationMeta _specificDaysOfWeekMeta =
      const VerificationMeta('specificDaysOfWeek');
  @override
  late final GeneratedColumn<String> specificDaysOfWeek =
      GeneratedColumn<String>(
        'specific_days_of_week',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('1,2,3,4,5,6,7'),
      );
  static const VerificationMeta _stockQuantityMeta = const VerificationMeta(
    'stockQuantity',
  );
  @override
  late final GeneratedColumn<int> stockQuantity = GeneratedColumn<int>(
    'stock_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _remindBeforeRunOutMeta =
      const VerificationMeta('remindBeforeRunOut');
  @override
  late final GeneratedColumn<bool> remindBeforeRunOut = GeneratedColumn<bool>(
    'remind_before_run_out',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("remind_before_run_out" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _reminderDaysBeforeRunOutMeta =
      const VerificationMeta('reminderDaysBeforeRunOut');
  @override
  late final GeneratedColumn<int> reminderDaysBeforeRunOut =
      GeneratedColumn<int>(
        'reminder_days_before_run_out',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(3),
      );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderDaysBeforeExpiryMeta =
      const VerificationMeta('reminderDaysBeforeExpiry');
  @override
  late final GeneratedColumn<int> reminderDaysBeforeExpiry =
      GeneratedColumn<int>(
        'reminder_days_before_expiry',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(30),
      );
  static const VerificationMeta _customSoundPathMeta = const VerificationMeta(
    'customSoundPath',
  );
  @override
  late final GeneratedColumn<String> customSoundPath = GeneratedColumn<String>(
    'custom_sound_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxSnoozesPerDayMeta = const VerificationMeta(
    'maxSnoozesPerDay',
  );
  @override
  late final GeneratedColumn<int> maxSnoozesPerDay = GeneratedColumn<int>(
    'max_snoozes_per_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _enableRecurringRemindersMeta =
      const VerificationMeta('enableRecurringReminders');
  @override
  late final GeneratedColumn<bool> enableRecurringReminders =
      GeneratedColumn<bool>(
        'enable_recurring_reminders',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("enable_recurring_reminders" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _recurringReminderIntervalMeta =
      const VerificationMeta('recurringReminderInterval');
  @override
  late final GeneratedColumn<int> recurringReminderInterval =
      GeneratedColumn<int>(
        'recurring_reminder_interval',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(30),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicineType,
    medicineName,
    medicinePhotoPath,
    strength,
    unit,
    notes,
    isScanned,
    timesPerDay,
    dosePerTime,
    doseUnit,
    durationDays,
    startDate,
    repetitionPattern,
    specificDaysOfWeek,
    stockQuantity,
    remindBeforeRunOut,
    reminderDaysBeforeRunOut,
    expiryDate,
    reminderDaysBeforeExpiry,
    customSoundPath,
    maxSnoozesPerDay,
    enableRecurringReminders,
    recurringReminderInterval,
    createdAt,
    updatedAt,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medication> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medicine_type')) {
      context.handle(
        _medicineTypeMeta,
        medicineType.isAcceptableOrUnknown(
          data['medicine_type']!,
          _medicineTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicineTypeMeta);
    }
    if (data.containsKey('medicine_name')) {
      context.handle(
        _medicineNameMeta,
        medicineName.isAcceptableOrUnknown(
          data['medicine_name']!,
          _medicineNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicineNameMeta);
    }
    if (data.containsKey('medicine_photo_path')) {
      context.handle(
        _medicinePhotoPathMeta,
        medicinePhotoPath.isAcceptableOrUnknown(
          data['medicine_photo_path']!,
          _medicinePhotoPathMeta,
        ),
      );
    }
    if (data.containsKey('strength')) {
      context.handle(
        _strengthMeta,
        strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_scanned')) {
      context.handle(
        _isScannedMeta,
        isScanned.isAcceptableOrUnknown(data['is_scanned']!, _isScannedMeta),
      );
    }
    if (data.containsKey('times_per_day')) {
      context.handle(
        _timesPerDayMeta,
        timesPerDay.isAcceptableOrUnknown(
          data['times_per_day']!,
          _timesPerDayMeta,
        ),
      );
    }
    if (data.containsKey('dose_per_time')) {
      context.handle(
        _dosePerTimeMeta,
        dosePerTime.isAcceptableOrUnknown(
          data['dose_per_time']!,
          _dosePerTimeMeta,
        ),
      );
    }
    if (data.containsKey('dose_unit')) {
      context.handle(
        _doseUnitMeta,
        doseUnit.isAcceptableOrUnknown(data['dose_unit']!, _doseUnitMeta),
      );
    }
    if (data.containsKey('duration_days')) {
      context.handle(
        _durationDaysMeta,
        durationDays.isAcceptableOrUnknown(
          data['duration_days']!,
          _durationDaysMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('repetition_pattern')) {
      context.handle(
        _repetitionPatternMeta,
        repetitionPattern.isAcceptableOrUnknown(
          data['repetition_pattern']!,
          _repetitionPatternMeta,
        ),
      );
    }
    if (data.containsKey('specific_days_of_week')) {
      context.handle(
        _specificDaysOfWeekMeta,
        specificDaysOfWeek.isAcceptableOrUnknown(
          data['specific_days_of_week']!,
          _specificDaysOfWeekMeta,
        ),
      );
    }
    if (data.containsKey('stock_quantity')) {
      context.handle(
        _stockQuantityMeta,
        stockQuantity.isAcceptableOrUnknown(
          data['stock_quantity']!,
          _stockQuantityMeta,
        ),
      );
    }
    if (data.containsKey('remind_before_run_out')) {
      context.handle(
        _remindBeforeRunOutMeta,
        remindBeforeRunOut.isAcceptableOrUnknown(
          data['remind_before_run_out']!,
          _remindBeforeRunOutMeta,
        ),
      );
    }
    if (data.containsKey('reminder_days_before_run_out')) {
      context.handle(
        _reminderDaysBeforeRunOutMeta,
        reminderDaysBeforeRunOut.isAcceptableOrUnknown(
          data['reminder_days_before_run_out']!,
          _reminderDaysBeforeRunOutMeta,
        ),
      );
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    }
    if (data.containsKey('reminder_days_before_expiry')) {
      context.handle(
        _reminderDaysBeforeExpiryMeta,
        reminderDaysBeforeExpiry.isAcceptableOrUnknown(
          data['reminder_days_before_expiry']!,
          _reminderDaysBeforeExpiryMeta,
        ),
      );
    }
    if (data.containsKey('custom_sound_path')) {
      context.handle(
        _customSoundPathMeta,
        customSoundPath.isAcceptableOrUnknown(
          data['custom_sound_path']!,
          _customSoundPathMeta,
        ),
      );
    }
    if (data.containsKey('max_snoozes_per_day')) {
      context.handle(
        _maxSnoozesPerDayMeta,
        maxSnoozesPerDay.isAcceptableOrUnknown(
          data['max_snoozes_per_day']!,
          _maxSnoozesPerDayMeta,
        ),
      );
    }
    if (data.containsKey('enable_recurring_reminders')) {
      context.handle(
        _enableRecurringRemindersMeta,
        enableRecurringReminders.isAcceptableOrUnknown(
          data['enable_recurring_reminders']!,
          _enableRecurringRemindersMeta,
        ),
      );
    }
    if (data.containsKey('recurring_reminder_interval')) {
      context.handle(
        _recurringReminderIntervalMeta,
        recurringReminderInterval.isAcceptableOrUnknown(
          data['recurring_reminder_interval']!,
          _recurringReminderIntervalMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicineType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicine_type'],
      )!,
      medicineName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicine_name'],
      )!,
      medicinePhotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicine_photo_path'],
      ),
      strength: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strength'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isScanned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_scanned'],
      )!,
      timesPerDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_per_day'],
      )!,
      dosePerTime: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dose_per_time'],
      )!,
      doseUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose_unit'],
      )!,
      durationDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_days'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      repetitionPattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repetition_pattern'],
      )!,
      specificDaysOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specific_days_of_week'],
      )!,
      stockQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_quantity'],
      )!,
      remindBeforeRunOut: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}remind_before_run_out'],
      )!,
      reminderDaysBeforeRunOut: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_days_before_run_out'],
      )!,
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      ),
      reminderDaysBeforeExpiry: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_days_before_expiry'],
      )!,
      customSoundPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_sound_path'],
      ),
      maxSnoozesPerDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_snoozes_per_day'],
      )!,
      enableRecurringReminders: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_recurring_reminders'],
      )!,
      recurringReminderInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurring_reminder_interval'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class Medication extends DataClass implements Insertable<Medication> {
  final int id;
  final String medicineType;
  final String medicineName;
  final String? medicinePhotoPath;
  final String? strength;
  final String? unit;
  final String? notes;
  final bool isScanned;
  final int timesPerDay;
  final double dosePerTime;
  final String doseUnit;
  final int durationDays;
  final DateTime startDate;
  final String repetitionPattern;
  final String specificDaysOfWeek;
  final int stockQuantity;
  final bool remindBeforeRunOut;
  final int reminderDaysBeforeRunOut;
  final DateTime? expiryDate;
  final int reminderDaysBeforeExpiry;
  final String? customSoundPath;
  final int maxSnoozesPerDay;
  final bool enableRecurringReminders;
  final int recurringReminderInterval;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  const Medication({
    required this.id,
    required this.medicineType,
    required this.medicineName,
    this.medicinePhotoPath,
    this.strength,
    this.unit,
    this.notes,
    required this.isScanned,
    required this.timesPerDay,
    required this.dosePerTime,
    required this.doseUnit,
    required this.durationDays,
    required this.startDate,
    required this.repetitionPattern,
    required this.specificDaysOfWeek,
    required this.stockQuantity,
    required this.remindBeforeRunOut,
    required this.reminderDaysBeforeRunOut,
    this.expiryDate,
    required this.reminderDaysBeforeExpiry,
    this.customSoundPath,
    required this.maxSnoozesPerDay,
    required this.enableRecurringReminders,
    required this.recurringReminderInterval,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medicine_type'] = Variable<String>(medicineType);
    map['medicine_name'] = Variable<String>(medicineName);
    if (!nullToAbsent || medicinePhotoPath != null) {
      map['medicine_photo_path'] = Variable<String>(medicinePhotoPath);
    }
    if (!nullToAbsent || strength != null) {
      map['strength'] = Variable<String>(strength);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_scanned'] = Variable<bool>(isScanned);
    map['times_per_day'] = Variable<int>(timesPerDay);
    map['dose_per_time'] = Variable<double>(dosePerTime);
    map['dose_unit'] = Variable<String>(doseUnit);
    map['duration_days'] = Variable<int>(durationDays);
    map['start_date'] = Variable<DateTime>(startDate);
    map['repetition_pattern'] = Variable<String>(repetitionPattern);
    map['specific_days_of_week'] = Variable<String>(specificDaysOfWeek);
    map['stock_quantity'] = Variable<int>(stockQuantity);
    map['remind_before_run_out'] = Variable<bool>(remindBeforeRunOut);
    map['reminder_days_before_run_out'] = Variable<int>(
      reminderDaysBeforeRunOut,
    );
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    map['reminder_days_before_expiry'] = Variable<int>(
      reminderDaysBeforeExpiry,
    );
    if (!nullToAbsent || customSoundPath != null) {
      map['custom_sound_path'] = Variable<String>(customSoundPath);
    }
    map['max_snoozes_per_day'] = Variable<int>(maxSnoozesPerDay);
    map['enable_recurring_reminders'] = Variable<bool>(
      enableRecurringReminders,
    );
    map['recurring_reminder_interval'] = Variable<int>(
      recurringReminderInterval,
    );
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      medicineType: Value(medicineType),
      medicineName: Value(medicineName),
      medicinePhotoPath: medicinePhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(medicinePhotoPath),
      strength: strength == null && nullToAbsent
          ? const Value.absent()
          : Value(strength),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isScanned: Value(isScanned),
      timesPerDay: Value(timesPerDay),
      dosePerTime: Value(dosePerTime),
      doseUnit: Value(doseUnit),
      durationDays: Value(durationDays),
      startDate: Value(startDate),
      repetitionPattern: Value(repetitionPattern),
      specificDaysOfWeek: Value(specificDaysOfWeek),
      stockQuantity: Value(stockQuantity),
      remindBeforeRunOut: Value(remindBeforeRunOut),
      reminderDaysBeforeRunOut: Value(reminderDaysBeforeRunOut),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      reminderDaysBeforeExpiry: Value(reminderDaysBeforeExpiry),
      customSoundPath: customSoundPath == null && nullToAbsent
          ? const Value.absent()
          : Value(customSoundPath),
      maxSnoozesPerDay: Value(maxSnoozesPerDay),
      enableRecurringReminders: Value(enableRecurringReminders),
      recurringReminderInterval: Value(recurringReminderInterval),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isActive: Value(isActive),
    );
  }

  factory Medication.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<int>(json['id']),
      medicineType: serializer.fromJson<String>(json['medicineType']),
      medicineName: serializer.fromJson<String>(json['medicineName']),
      medicinePhotoPath: serializer.fromJson<String?>(
        json['medicinePhotoPath'],
      ),
      strength: serializer.fromJson<String?>(json['strength']),
      unit: serializer.fromJson<String?>(json['unit']),
      notes: serializer.fromJson<String?>(json['notes']),
      isScanned: serializer.fromJson<bool>(json['isScanned']),
      timesPerDay: serializer.fromJson<int>(json['timesPerDay']),
      dosePerTime: serializer.fromJson<double>(json['dosePerTime']),
      doseUnit: serializer.fromJson<String>(json['doseUnit']),
      durationDays: serializer.fromJson<int>(json['durationDays']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      repetitionPattern: serializer.fromJson<String>(json['repetitionPattern']),
      specificDaysOfWeek: serializer.fromJson<String>(
        json['specificDaysOfWeek'],
      ),
      stockQuantity: serializer.fromJson<int>(json['stockQuantity']),
      remindBeforeRunOut: serializer.fromJson<bool>(json['remindBeforeRunOut']),
      reminderDaysBeforeRunOut: serializer.fromJson<int>(
        json['reminderDaysBeforeRunOut'],
      ),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
      reminderDaysBeforeExpiry: serializer.fromJson<int>(
        json['reminderDaysBeforeExpiry'],
      ),
      customSoundPath: serializer.fromJson<String?>(json['customSoundPath']),
      maxSnoozesPerDay: serializer.fromJson<int>(json['maxSnoozesPerDay']),
      enableRecurringReminders: serializer.fromJson<bool>(
        json['enableRecurringReminders'],
      ),
      recurringReminderInterval: serializer.fromJson<int>(
        json['recurringReminderInterval'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicineType': serializer.toJson<String>(medicineType),
      'medicineName': serializer.toJson<String>(medicineName),
      'medicinePhotoPath': serializer.toJson<String?>(medicinePhotoPath),
      'strength': serializer.toJson<String?>(strength),
      'unit': serializer.toJson<String?>(unit),
      'notes': serializer.toJson<String?>(notes),
      'isScanned': serializer.toJson<bool>(isScanned),
      'timesPerDay': serializer.toJson<int>(timesPerDay),
      'dosePerTime': serializer.toJson<double>(dosePerTime),
      'doseUnit': serializer.toJson<String>(doseUnit),
      'durationDays': serializer.toJson<int>(durationDays),
      'startDate': serializer.toJson<DateTime>(startDate),
      'repetitionPattern': serializer.toJson<String>(repetitionPattern),
      'specificDaysOfWeek': serializer.toJson<String>(specificDaysOfWeek),
      'stockQuantity': serializer.toJson<int>(stockQuantity),
      'remindBeforeRunOut': serializer.toJson<bool>(remindBeforeRunOut),
      'reminderDaysBeforeRunOut': serializer.toJson<int>(
        reminderDaysBeforeRunOut,
      ),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
      'reminderDaysBeforeExpiry': serializer.toJson<int>(
        reminderDaysBeforeExpiry,
      ),
      'customSoundPath': serializer.toJson<String?>(customSoundPath),
      'maxSnoozesPerDay': serializer.toJson<int>(maxSnoozesPerDay),
      'enableRecurringReminders': serializer.toJson<bool>(
        enableRecurringReminders,
      ),
      'recurringReminderInterval': serializer.toJson<int>(
        recurringReminderInterval,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Medication copyWith({
    int? id,
    String? medicineType,
    String? medicineName,
    Value<String?> medicinePhotoPath = const Value.absent(),
    Value<String?> strength = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isScanned,
    int? timesPerDay,
    double? dosePerTime,
    String? doseUnit,
    int? durationDays,
    DateTime? startDate,
    String? repetitionPattern,
    String? specificDaysOfWeek,
    int? stockQuantity,
    bool? remindBeforeRunOut,
    int? reminderDaysBeforeRunOut,
    Value<DateTime?> expiryDate = const Value.absent(),
    int? reminderDaysBeforeExpiry,
    Value<String?> customSoundPath = const Value.absent(),
    int? maxSnoozesPerDay,
    bool? enableRecurringReminders,
    int? recurringReminderInterval,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) => Medication(
    id: id ?? this.id,
    medicineType: medicineType ?? this.medicineType,
    medicineName: medicineName ?? this.medicineName,
    medicinePhotoPath: medicinePhotoPath.present
        ? medicinePhotoPath.value
        : this.medicinePhotoPath,
    strength: strength.present ? strength.value : this.strength,
    unit: unit.present ? unit.value : this.unit,
    notes: notes.present ? notes.value : this.notes,
    isScanned: isScanned ?? this.isScanned,
    timesPerDay: timesPerDay ?? this.timesPerDay,
    dosePerTime: dosePerTime ?? this.dosePerTime,
    doseUnit: doseUnit ?? this.doseUnit,
    durationDays: durationDays ?? this.durationDays,
    startDate: startDate ?? this.startDate,
    repetitionPattern: repetitionPattern ?? this.repetitionPattern,
    specificDaysOfWeek: specificDaysOfWeek ?? this.specificDaysOfWeek,
    stockQuantity: stockQuantity ?? this.stockQuantity,
    remindBeforeRunOut: remindBeforeRunOut ?? this.remindBeforeRunOut,
    reminderDaysBeforeRunOut:
        reminderDaysBeforeRunOut ?? this.reminderDaysBeforeRunOut,
    expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
    reminderDaysBeforeExpiry:
        reminderDaysBeforeExpiry ?? this.reminderDaysBeforeExpiry,
    customSoundPath: customSoundPath.present
        ? customSoundPath.value
        : this.customSoundPath,
    maxSnoozesPerDay: maxSnoozesPerDay ?? this.maxSnoozesPerDay,
    enableRecurringReminders:
        enableRecurringReminders ?? this.enableRecurringReminders,
    recurringReminderInterval:
        recurringReminderInterval ?? this.recurringReminderInterval,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isActive: isActive ?? this.isActive,
  );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      medicineType: data.medicineType.present
          ? data.medicineType.value
          : this.medicineType,
      medicineName: data.medicineName.present
          ? data.medicineName.value
          : this.medicineName,
      medicinePhotoPath: data.medicinePhotoPath.present
          ? data.medicinePhotoPath.value
          : this.medicinePhotoPath,
      strength: data.strength.present ? data.strength.value : this.strength,
      unit: data.unit.present ? data.unit.value : this.unit,
      notes: data.notes.present ? data.notes.value : this.notes,
      isScanned: data.isScanned.present ? data.isScanned.value : this.isScanned,
      timesPerDay: data.timesPerDay.present
          ? data.timesPerDay.value
          : this.timesPerDay,
      dosePerTime: data.dosePerTime.present
          ? data.dosePerTime.value
          : this.dosePerTime,
      doseUnit: data.doseUnit.present ? data.doseUnit.value : this.doseUnit,
      durationDays: data.durationDays.present
          ? data.durationDays.value
          : this.durationDays,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      repetitionPattern: data.repetitionPattern.present
          ? data.repetitionPattern.value
          : this.repetitionPattern,
      specificDaysOfWeek: data.specificDaysOfWeek.present
          ? data.specificDaysOfWeek.value
          : this.specificDaysOfWeek,
      stockQuantity: data.stockQuantity.present
          ? data.stockQuantity.value
          : this.stockQuantity,
      remindBeforeRunOut: data.remindBeforeRunOut.present
          ? data.remindBeforeRunOut.value
          : this.remindBeforeRunOut,
      reminderDaysBeforeRunOut: data.reminderDaysBeforeRunOut.present
          ? data.reminderDaysBeforeRunOut.value
          : this.reminderDaysBeforeRunOut,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      reminderDaysBeforeExpiry: data.reminderDaysBeforeExpiry.present
          ? data.reminderDaysBeforeExpiry.value
          : this.reminderDaysBeforeExpiry,
      customSoundPath: data.customSoundPath.present
          ? data.customSoundPath.value
          : this.customSoundPath,
      maxSnoozesPerDay: data.maxSnoozesPerDay.present
          ? data.maxSnoozesPerDay.value
          : this.maxSnoozesPerDay,
      enableRecurringReminders: data.enableRecurringReminders.present
          ? data.enableRecurringReminders.value
          : this.enableRecurringReminders,
      recurringReminderInterval: data.recurringReminderInterval.present
          ? data.recurringReminderInterval.value
          : this.recurringReminderInterval,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('medicineType: $medicineType, ')
          ..write('medicineName: $medicineName, ')
          ..write('medicinePhotoPath: $medicinePhotoPath, ')
          ..write('strength: $strength, ')
          ..write('unit: $unit, ')
          ..write('notes: $notes, ')
          ..write('isScanned: $isScanned, ')
          ..write('timesPerDay: $timesPerDay, ')
          ..write('dosePerTime: $dosePerTime, ')
          ..write('doseUnit: $doseUnit, ')
          ..write('durationDays: $durationDays, ')
          ..write('startDate: $startDate, ')
          ..write('repetitionPattern: $repetitionPattern, ')
          ..write('specificDaysOfWeek: $specificDaysOfWeek, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('remindBeforeRunOut: $remindBeforeRunOut, ')
          ..write('reminderDaysBeforeRunOut: $reminderDaysBeforeRunOut, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('reminderDaysBeforeExpiry: $reminderDaysBeforeExpiry, ')
          ..write('customSoundPath: $customSoundPath, ')
          ..write('maxSnoozesPerDay: $maxSnoozesPerDay, ')
          ..write('enableRecurringReminders: $enableRecurringReminders, ')
          ..write('recurringReminderInterval: $recurringReminderInterval, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    medicineType,
    medicineName,
    medicinePhotoPath,
    strength,
    unit,
    notes,
    isScanned,
    timesPerDay,
    dosePerTime,
    doseUnit,
    durationDays,
    startDate,
    repetitionPattern,
    specificDaysOfWeek,
    stockQuantity,
    remindBeforeRunOut,
    reminderDaysBeforeRunOut,
    expiryDate,
    reminderDaysBeforeExpiry,
    customSoundPath,
    maxSnoozesPerDay,
    enableRecurringReminders,
    recurringReminderInterval,
    createdAt,
    updatedAt,
    isActive,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.medicineType == this.medicineType &&
          other.medicineName == this.medicineName &&
          other.medicinePhotoPath == this.medicinePhotoPath &&
          other.strength == this.strength &&
          other.unit == this.unit &&
          other.notes == this.notes &&
          other.isScanned == this.isScanned &&
          other.timesPerDay == this.timesPerDay &&
          other.dosePerTime == this.dosePerTime &&
          other.doseUnit == this.doseUnit &&
          other.durationDays == this.durationDays &&
          other.startDate == this.startDate &&
          other.repetitionPattern == this.repetitionPattern &&
          other.specificDaysOfWeek == this.specificDaysOfWeek &&
          other.stockQuantity == this.stockQuantity &&
          other.remindBeforeRunOut == this.remindBeforeRunOut &&
          other.reminderDaysBeforeRunOut == this.reminderDaysBeforeRunOut &&
          other.expiryDate == this.expiryDate &&
          other.reminderDaysBeforeExpiry == this.reminderDaysBeforeExpiry &&
          other.customSoundPath == this.customSoundPath &&
          other.maxSnoozesPerDay == this.maxSnoozesPerDay &&
          other.enableRecurringReminders == this.enableRecurringReminders &&
          other.recurringReminderInterval == this.recurringReminderInterval &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isActive == this.isActive);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<int> id;
  final Value<String> medicineType;
  final Value<String> medicineName;
  final Value<String?> medicinePhotoPath;
  final Value<String?> strength;
  final Value<String?> unit;
  final Value<String?> notes;
  final Value<bool> isScanned;
  final Value<int> timesPerDay;
  final Value<double> dosePerTime;
  final Value<String> doseUnit;
  final Value<int> durationDays;
  final Value<DateTime> startDate;
  final Value<String> repetitionPattern;
  final Value<String> specificDaysOfWeek;
  final Value<int> stockQuantity;
  final Value<bool> remindBeforeRunOut;
  final Value<int> reminderDaysBeforeRunOut;
  final Value<DateTime?> expiryDate;
  final Value<int> reminderDaysBeforeExpiry;
  final Value<String?> customSoundPath;
  final Value<int> maxSnoozesPerDay;
  final Value<bool> enableRecurringReminders;
  final Value<int> recurringReminderInterval;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isActive;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.medicineType = const Value.absent(),
    this.medicineName = const Value.absent(),
    this.medicinePhotoPath = const Value.absent(),
    this.strength = const Value.absent(),
    this.unit = const Value.absent(),
    this.notes = const Value.absent(),
    this.isScanned = const Value.absent(),
    this.timesPerDay = const Value.absent(),
    this.dosePerTime = const Value.absent(),
    this.doseUnit = const Value.absent(),
    this.durationDays = const Value.absent(),
    this.startDate = const Value.absent(),
    this.repetitionPattern = const Value.absent(),
    this.specificDaysOfWeek = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.remindBeforeRunOut = const Value.absent(),
    this.reminderDaysBeforeRunOut = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.reminderDaysBeforeExpiry = const Value.absent(),
    this.customSoundPath = const Value.absent(),
    this.maxSnoozesPerDay = const Value.absent(),
    this.enableRecurringReminders = const Value.absent(),
    this.recurringReminderInterval = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  MedicationsCompanion.insert({
    this.id = const Value.absent(),
    required String medicineType,
    required String medicineName,
    this.medicinePhotoPath = const Value.absent(),
    this.strength = const Value.absent(),
    this.unit = const Value.absent(),
    this.notes = const Value.absent(),
    this.isScanned = const Value.absent(),
    this.timesPerDay = const Value.absent(),
    this.dosePerTime = const Value.absent(),
    this.doseUnit = const Value.absent(),
    this.durationDays = const Value.absent(),
    required DateTime startDate,
    this.repetitionPattern = const Value.absent(),
    this.specificDaysOfWeek = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.remindBeforeRunOut = const Value.absent(),
    this.reminderDaysBeforeRunOut = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.reminderDaysBeforeExpiry = const Value.absent(),
    this.customSoundPath = const Value.absent(),
    this.maxSnoozesPerDay = const Value.absent(),
    this.enableRecurringReminders = const Value.absent(),
    this.recurringReminderInterval = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : medicineType = Value(medicineType),
       medicineName = Value(medicineName),
       startDate = Value(startDate);
  static Insertable<Medication> custom({
    Expression<int>? id,
    Expression<String>? medicineType,
    Expression<String>? medicineName,
    Expression<String>? medicinePhotoPath,
    Expression<String>? strength,
    Expression<String>? unit,
    Expression<String>? notes,
    Expression<bool>? isScanned,
    Expression<int>? timesPerDay,
    Expression<double>? dosePerTime,
    Expression<String>? doseUnit,
    Expression<int>? durationDays,
    Expression<DateTime>? startDate,
    Expression<String>? repetitionPattern,
    Expression<String>? specificDaysOfWeek,
    Expression<int>? stockQuantity,
    Expression<bool>? remindBeforeRunOut,
    Expression<int>? reminderDaysBeforeRunOut,
    Expression<DateTime>? expiryDate,
    Expression<int>? reminderDaysBeforeExpiry,
    Expression<String>? customSoundPath,
    Expression<int>? maxSnoozesPerDay,
    Expression<bool>? enableRecurringReminders,
    Expression<int>? recurringReminderInterval,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicineType != null) 'medicine_type': medicineType,
      if (medicineName != null) 'medicine_name': medicineName,
      if (medicinePhotoPath != null) 'medicine_photo_path': medicinePhotoPath,
      if (strength != null) 'strength': strength,
      if (unit != null) 'unit': unit,
      if (notes != null) 'notes': notes,
      if (isScanned != null) 'is_scanned': isScanned,
      if (timesPerDay != null) 'times_per_day': timesPerDay,
      if (dosePerTime != null) 'dose_per_time': dosePerTime,
      if (doseUnit != null) 'dose_unit': doseUnit,
      if (durationDays != null) 'duration_days': durationDays,
      if (startDate != null) 'start_date': startDate,
      if (repetitionPattern != null) 'repetition_pattern': repetitionPattern,
      if (specificDaysOfWeek != null)
        'specific_days_of_week': specificDaysOfWeek,
      if (stockQuantity != null) 'stock_quantity': stockQuantity,
      if (remindBeforeRunOut != null)
        'remind_before_run_out': remindBeforeRunOut,
      if (reminderDaysBeforeRunOut != null)
        'reminder_days_before_run_out': reminderDaysBeforeRunOut,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (reminderDaysBeforeExpiry != null)
        'reminder_days_before_expiry': reminderDaysBeforeExpiry,
      if (customSoundPath != null) 'custom_sound_path': customSoundPath,
      if (maxSnoozesPerDay != null) 'max_snoozes_per_day': maxSnoozesPerDay,
      if (enableRecurringReminders != null)
        'enable_recurring_reminders': enableRecurringReminders,
      if (recurringReminderInterval != null)
        'recurring_reminder_interval': recurringReminderInterval,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isActive != null) 'is_active': isActive,
    });
  }

  MedicationsCompanion copyWith({
    Value<int>? id,
    Value<String>? medicineType,
    Value<String>? medicineName,
    Value<String?>? medicinePhotoPath,
    Value<String?>? strength,
    Value<String?>? unit,
    Value<String?>? notes,
    Value<bool>? isScanned,
    Value<int>? timesPerDay,
    Value<double>? dosePerTime,
    Value<String>? doseUnit,
    Value<int>? durationDays,
    Value<DateTime>? startDate,
    Value<String>? repetitionPattern,
    Value<String>? specificDaysOfWeek,
    Value<int>? stockQuantity,
    Value<bool>? remindBeforeRunOut,
    Value<int>? reminderDaysBeforeRunOut,
    Value<DateTime?>? expiryDate,
    Value<int>? reminderDaysBeforeExpiry,
    Value<String?>? customSoundPath,
    Value<int>? maxSnoozesPerDay,
    Value<bool>? enableRecurringReminders,
    Value<int>? recurringReminderInterval,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isActive,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      medicineType: medicineType ?? this.medicineType,
      medicineName: medicineName ?? this.medicineName,
      medicinePhotoPath: medicinePhotoPath ?? this.medicinePhotoPath,
      strength: strength ?? this.strength,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      isScanned: isScanned ?? this.isScanned,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      dosePerTime: dosePerTime ?? this.dosePerTime,
      doseUnit: doseUnit ?? this.doseUnit,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      repetitionPattern: repetitionPattern ?? this.repetitionPattern,
      specificDaysOfWeek: specificDaysOfWeek ?? this.specificDaysOfWeek,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      remindBeforeRunOut: remindBeforeRunOut ?? this.remindBeforeRunOut,
      reminderDaysBeforeRunOut:
          reminderDaysBeforeRunOut ?? this.reminderDaysBeforeRunOut,
      expiryDate: expiryDate ?? this.expiryDate,
      reminderDaysBeforeExpiry:
          reminderDaysBeforeExpiry ?? this.reminderDaysBeforeExpiry,
      customSoundPath: customSoundPath ?? this.customSoundPath,
      maxSnoozesPerDay: maxSnoozesPerDay ?? this.maxSnoozesPerDay,
      enableRecurringReminders:
          enableRecurringReminders ?? this.enableRecurringReminders,
      recurringReminderInterval:
          recurringReminderInterval ?? this.recurringReminderInterval,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicineType.present) {
      map['medicine_type'] = Variable<String>(medicineType.value);
    }
    if (medicineName.present) {
      map['medicine_name'] = Variable<String>(medicineName.value);
    }
    if (medicinePhotoPath.present) {
      map['medicine_photo_path'] = Variable<String>(medicinePhotoPath.value);
    }
    if (strength.present) {
      map['strength'] = Variable<String>(strength.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isScanned.present) {
      map['is_scanned'] = Variable<bool>(isScanned.value);
    }
    if (timesPerDay.present) {
      map['times_per_day'] = Variable<int>(timesPerDay.value);
    }
    if (dosePerTime.present) {
      map['dose_per_time'] = Variable<double>(dosePerTime.value);
    }
    if (doseUnit.present) {
      map['dose_unit'] = Variable<String>(doseUnit.value);
    }
    if (durationDays.present) {
      map['duration_days'] = Variable<int>(durationDays.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (repetitionPattern.present) {
      map['repetition_pattern'] = Variable<String>(repetitionPattern.value);
    }
    if (specificDaysOfWeek.present) {
      map['specific_days_of_week'] = Variable<String>(specificDaysOfWeek.value);
    }
    if (stockQuantity.present) {
      map['stock_quantity'] = Variable<int>(stockQuantity.value);
    }
    if (remindBeforeRunOut.present) {
      map['remind_before_run_out'] = Variable<bool>(remindBeforeRunOut.value);
    }
    if (reminderDaysBeforeRunOut.present) {
      map['reminder_days_before_run_out'] = Variable<int>(
        reminderDaysBeforeRunOut.value,
      );
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (reminderDaysBeforeExpiry.present) {
      map['reminder_days_before_expiry'] = Variable<int>(
        reminderDaysBeforeExpiry.value,
      );
    }
    if (customSoundPath.present) {
      map['custom_sound_path'] = Variable<String>(customSoundPath.value);
    }
    if (maxSnoozesPerDay.present) {
      map['max_snoozes_per_day'] = Variable<int>(maxSnoozesPerDay.value);
    }
    if (enableRecurringReminders.present) {
      map['enable_recurring_reminders'] = Variable<bool>(
        enableRecurringReminders.value,
      );
    }
    if (recurringReminderInterval.present) {
      map['recurring_reminder_interval'] = Variable<int>(
        recurringReminderInterval.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('medicineType: $medicineType, ')
          ..write('medicineName: $medicineName, ')
          ..write('medicinePhotoPath: $medicinePhotoPath, ')
          ..write('strength: $strength, ')
          ..write('unit: $unit, ')
          ..write('notes: $notes, ')
          ..write('isScanned: $isScanned, ')
          ..write('timesPerDay: $timesPerDay, ')
          ..write('dosePerTime: $dosePerTime, ')
          ..write('doseUnit: $doseUnit, ')
          ..write('durationDays: $durationDays, ')
          ..write('startDate: $startDate, ')
          ..write('repetitionPattern: $repetitionPattern, ')
          ..write('specificDaysOfWeek: $specificDaysOfWeek, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('remindBeforeRunOut: $remindBeforeRunOut, ')
          ..write('reminderDaysBeforeRunOut: $reminderDaysBeforeRunOut, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('reminderDaysBeforeExpiry: $reminderDaysBeforeExpiry, ')
          ..write('customSoundPath: $customSoundPath, ')
          ..write('maxSnoozesPerDay: $maxSnoozesPerDay, ')
          ..write('enableRecurringReminders: $enableRecurringReminders, ')
          ..write('recurringReminderInterval: $recurringReminderInterval, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $ReminderTimesTable extends ReminderTimes
    with TableInfo<$ReminderTimesTable, ReminderTime> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderTimesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<int> medicationId = GeneratedColumn<int>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id)',
    ),
  );
  static const VerificationMeta _hourMeta = const VerificationMeta('hour');
  @override
  late final GeneratedColumn<int> hour = GeneratedColumn<int>(
    'hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minuteMeta = const VerificationMeta('minute');
  @override
  late final GeneratedColumn<int> minute = GeneratedColumn<int>(
    'minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealTimingMeta = const VerificationMeta(
    'mealTiming',
  );
  @override
  late final GeneratedColumn<String> mealTiming = GeneratedColumn<String>(
    'meal_timing',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('anytime'),
  );
  static const VerificationMeta _mealOffsetMinutesMeta = const VerificationMeta(
    'mealOffsetMinutes',
  );
  @override
  late final GeneratedColumn<int> mealOffsetMinutes = GeneratedColumn<int>(
    'meal_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationId,
    hour,
    minute,
    orderIndex,
    mealTiming,
    mealOffsetMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_times';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderTime> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('hour')) {
      context.handle(
        _hourMeta,
        hour.isAcceptableOrUnknown(data['hour']!, _hourMeta),
      );
    } else if (isInserting) {
      context.missing(_hourMeta);
    }
    if (data.containsKey('minute')) {
      context.handle(
        _minuteMeta,
        minute.isAcceptableOrUnknown(data['minute']!, _minuteMeta),
      );
    } else if (isInserting) {
      context.missing(_minuteMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('meal_timing')) {
      context.handle(
        _mealTimingMeta,
        mealTiming.isAcceptableOrUnknown(data['meal_timing']!, _mealTimingMeta),
      );
    }
    if (data.containsKey('meal_offset_minutes')) {
      context.handle(
        _mealOffsetMinutesMeta,
        mealOffsetMinutes.isAcceptableOrUnknown(
          data['meal_offset_minutes']!,
          _mealOffsetMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderTime map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderTime(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medication_id'],
      )!,
      hour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour'],
      )!,
      minute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      mealTiming: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_timing'],
      )!,
      mealOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meal_offset_minutes'],
      )!,
    );
  }

  @override
  $ReminderTimesTable createAlias(String alias) {
    return $ReminderTimesTable(attachedDatabase, alias);
  }
}

class ReminderTime extends DataClass implements Insertable<ReminderTime> {
  final int id;
  final int medicationId;
  final int hour;
  final int minute;
  final int orderIndex;
  final String mealTiming;
  final int mealOffsetMinutes;
  const ReminderTime({
    required this.id,
    required this.medicationId,
    required this.hour,
    required this.minute,
    required this.orderIndex,
    required this.mealTiming,
    required this.mealOffsetMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medication_id'] = Variable<int>(medicationId);
    map['hour'] = Variable<int>(hour);
    map['minute'] = Variable<int>(minute);
    map['order_index'] = Variable<int>(orderIndex);
    map['meal_timing'] = Variable<String>(mealTiming);
    map['meal_offset_minutes'] = Variable<int>(mealOffsetMinutes);
    return map;
  }

  ReminderTimesCompanion toCompanion(bool nullToAbsent) {
    return ReminderTimesCompanion(
      id: Value(id),
      medicationId: Value(medicationId),
      hour: Value(hour),
      minute: Value(minute),
      orderIndex: Value(orderIndex),
      mealTiming: Value(mealTiming),
      mealOffsetMinutes: Value(mealOffsetMinutes),
    );
  }

  factory ReminderTime.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderTime(
      id: serializer.fromJson<int>(json['id']),
      medicationId: serializer.fromJson<int>(json['medicationId']),
      hour: serializer.fromJson<int>(json['hour']),
      minute: serializer.fromJson<int>(json['minute']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      mealTiming: serializer.fromJson<String>(json['mealTiming']),
      mealOffsetMinutes: serializer.fromJson<int>(json['mealOffsetMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicationId': serializer.toJson<int>(medicationId),
      'hour': serializer.toJson<int>(hour),
      'minute': serializer.toJson<int>(minute),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'mealTiming': serializer.toJson<String>(mealTiming),
      'mealOffsetMinutes': serializer.toJson<int>(mealOffsetMinutes),
    };
  }

  ReminderTime copyWith({
    int? id,
    int? medicationId,
    int? hour,
    int? minute,
    int? orderIndex,
    String? mealTiming,
    int? mealOffsetMinutes,
  }) => ReminderTime(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    orderIndex: orderIndex ?? this.orderIndex,
    mealTiming: mealTiming ?? this.mealTiming,
    mealOffsetMinutes: mealOffsetMinutes ?? this.mealOffsetMinutes,
  );
  ReminderTime copyWithCompanion(ReminderTimesCompanion data) {
    return ReminderTime(
      id: data.id.present ? data.id.value : this.id,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      hour: data.hour.present ? data.hour.value : this.hour,
      minute: data.minute.present ? data.minute.value : this.minute,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      mealTiming: data.mealTiming.present
          ? data.mealTiming.value
          : this.mealTiming,
      mealOffsetMinutes: data.mealOffsetMinutes.present
          ? data.mealOffsetMinutes.value
          : this.mealOffsetMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderTime(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('mealTiming: $mealTiming, ')
          ..write('mealOffsetMinutes: $mealOffsetMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicationId,
    hour,
    minute,
    orderIndex,
    mealTiming,
    mealOffsetMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderTime &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.hour == this.hour &&
          other.minute == this.minute &&
          other.orderIndex == this.orderIndex &&
          other.mealTiming == this.mealTiming &&
          other.mealOffsetMinutes == this.mealOffsetMinutes);
}

class ReminderTimesCompanion extends UpdateCompanion<ReminderTime> {
  final Value<int> id;
  final Value<int> medicationId;
  final Value<int> hour;
  final Value<int> minute;
  final Value<int> orderIndex;
  final Value<String> mealTiming;
  final Value<int> mealOffsetMinutes;
  const ReminderTimesCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.hour = const Value.absent(),
    this.minute = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.mealTiming = const Value.absent(),
    this.mealOffsetMinutes = const Value.absent(),
  });
  ReminderTimesCompanion.insert({
    this.id = const Value.absent(),
    required int medicationId,
    required int hour,
    required int minute,
    required int orderIndex,
    this.mealTiming = const Value.absent(),
    this.mealOffsetMinutes = const Value.absent(),
  }) : medicationId = Value(medicationId),
       hour = Value(hour),
       minute = Value(minute),
       orderIndex = Value(orderIndex);
  static Insertable<ReminderTime> custom({
    Expression<int>? id,
    Expression<int>? medicationId,
    Expression<int>? hour,
    Expression<int>? minute,
    Expression<int>? orderIndex,
    Expression<String>? mealTiming,
    Expression<int>? mealOffsetMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (hour != null) 'hour': hour,
      if (minute != null) 'minute': minute,
      if (orderIndex != null) 'order_index': orderIndex,
      if (mealTiming != null) 'meal_timing': mealTiming,
      if (mealOffsetMinutes != null) 'meal_offset_minutes': mealOffsetMinutes,
    });
  }

  ReminderTimesCompanion copyWith({
    Value<int>? id,
    Value<int>? medicationId,
    Value<int>? hour,
    Value<int>? minute,
    Value<int>? orderIndex,
    Value<String>? mealTiming,
    Value<int>? mealOffsetMinutes,
  }) {
    return ReminderTimesCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      orderIndex: orderIndex ?? this.orderIndex,
      mealTiming: mealTiming ?? this.mealTiming,
      mealOffsetMinutes: mealOffsetMinutes ?? this.mealOffsetMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<int>(medicationId.value);
    }
    if (hour.present) {
      map['hour'] = Variable<int>(hour.value);
    }
    if (minute.present) {
      map['minute'] = Variable<int>(minute.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (mealTiming.present) {
      map['meal_timing'] = Variable<String>(mealTiming.value);
    }
    if (mealOffsetMinutes.present) {
      map['meal_offset_minutes'] = Variable<int>(mealOffsetMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderTimesCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('mealTiming: $mealTiming, ')
          ..write('mealOffsetMinutes: $mealOffsetMinutes')
          ..write(')'))
        .toString();
  }
}

class $DoseHistoryTable extends DoseHistory
    with TableInfo<$DoseHistoryTable, DoseHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoseHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<int> medicationId = GeneratedColumn<int>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id)',
    ),
  );
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>(
        'scheduled_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _scheduledHourMeta = const VerificationMeta(
    'scheduledHour',
  );
  @override
  late final GeneratedColumn<int> scheduledHour = GeneratedColumn<int>(
    'scheduled_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledMinuteMeta = const VerificationMeta(
    'scheduledMinute',
  );
  @override
  late final GeneratedColumn<int> scheduledMinute = GeneratedColumn<int>(
    'scheduled_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualTimeMeta = const VerificationMeta(
    'actualTime',
  );
  @override
  late final GeneratedColumn<DateTime> actualTime = GeneratedColumn<DateTime>(
    'actual_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationId,
    scheduledDate,
    scheduledHour,
    scheduledMinute,
    status,
    actualTime,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dose_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<DoseHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledDateMeta);
    }
    if (data.containsKey('scheduled_hour')) {
      context.handle(
        _scheduledHourMeta,
        scheduledHour.isAcceptableOrUnknown(
          data['scheduled_hour']!,
          _scheduledHourMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledHourMeta);
    }
    if (data.containsKey('scheduled_minute')) {
      context.handle(
        _scheduledMinuteMeta,
        scheduledMinute.isAcceptableOrUnknown(
          data['scheduled_minute']!,
          _scheduledMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledMinuteMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('actual_time')) {
      context.handle(
        _actualTimeMeta,
        actualTime.isAcceptableOrUnknown(data['actual_time']!, _actualTimeMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DoseHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DoseHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medication_id'],
      )!,
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_date'],
      )!,
      scheduledHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_hour'],
      )!,
      scheduledMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_minute'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      actualTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actual_time'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DoseHistoryTable createAlias(String alias) {
    return $DoseHistoryTable(attachedDatabase, alias);
  }
}

class DoseHistoryData extends DataClass implements Insertable<DoseHistoryData> {
  final int id;
  final int medicationId;
  final DateTime scheduledDate;
  final int scheduledHour;
  final int scheduledMinute;
  final String status;
  final DateTime? actualTime;
  final String? notes;
  final DateTime createdAt;
  const DoseHistoryData({
    required this.id,
    required this.medicationId,
    required this.scheduledDate,
    required this.scheduledHour,
    required this.scheduledMinute,
    required this.status,
    this.actualTime,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medication_id'] = Variable<int>(medicationId);
    map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    map['scheduled_hour'] = Variable<int>(scheduledHour);
    map['scheduled_minute'] = Variable<int>(scheduledMinute);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || actualTime != null) {
      map['actual_time'] = Variable<DateTime>(actualTime);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DoseHistoryCompanion toCompanion(bool nullToAbsent) {
    return DoseHistoryCompanion(
      id: Value(id),
      medicationId: Value(medicationId),
      scheduledDate: Value(scheduledDate),
      scheduledHour: Value(scheduledHour),
      scheduledMinute: Value(scheduledMinute),
      status: Value(status),
      actualTime: actualTime == null && nullToAbsent
          ? const Value.absent()
          : Value(actualTime),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory DoseHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DoseHistoryData(
      id: serializer.fromJson<int>(json['id']),
      medicationId: serializer.fromJson<int>(json['medicationId']),
      scheduledDate: serializer.fromJson<DateTime>(json['scheduledDate']),
      scheduledHour: serializer.fromJson<int>(json['scheduledHour']),
      scheduledMinute: serializer.fromJson<int>(json['scheduledMinute']),
      status: serializer.fromJson<String>(json['status']),
      actualTime: serializer.fromJson<DateTime?>(json['actualTime']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicationId': serializer.toJson<int>(medicationId),
      'scheduledDate': serializer.toJson<DateTime>(scheduledDate),
      'scheduledHour': serializer.toJson<int>(scheduledHour),
      'scheduledMinute': serializer.toJson<int>(scheduledMinute),
      'status': serializer.toJson<String>(status),
      'actualTime': serializer.toJson<DateTime?>(actualTime),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DoseHistoryData copyWith({
    int? id,
    int? medicationId,
    DateTime? scheduledDate,
    int? scheduledHour,
    int? scheduledMinute,
    String? status,
    Value<DateTime?> actualTime = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => DoseHistoryData(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    scheduledDate: scheduledDate ?? this.scheduledDate,
    scheduledHour: scheduledHour ?? this.scheduledHour,
    scheduledMinute: scheduledMinute ?? this.scheduledMinute,
    status: status ?? this.status,
    actualTime: actualTime.present ? actualTime.value : this.actualTime,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  DoseHistoryData copyWithCompanion(DoseHistoryCompanion data) {
    return DoseHistoryData(
      id: data.id.present ? data.id.value : this.id,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      scheduledHour: data.scheduledHour.present
          ? data.scheduledHour.value
          : this.scheduledHour,
      scheduledMinute: data.scheduledMinute.present
          ? data.scheduledMinute.value
          : this.scheduledMinute,
      status: data.status.present ? data.status.value : this.status,
      actualTime: data.actualTime.present
          ? data.actualTime.value
          : this.actualTime,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DoseHistoryData(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('scheduledHour: $scheduledHour, ')
          ..write('scheduledMinute: $scheduledMinute, ')
          ..write('status: $status, ')
          ..write('actualTime: $actualTime, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicationId,
    scheduledDate,
    scheduledHour,
    scheduledMinute,
    status,
    actualTime,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DoseHistoryData &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.scheduledDate == this.scheduledDate &&
          other.scheduledHour == this.scheduledHour &&
          other.scheduledMinute == this.scheduledMinute &&
          other.status == this.status &&
          other.actualTime == this.actualTime &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class DoseHistoryCompanion extends UpdateCompanion<DoseHistoryData> {
  final Value<int> id;
  final Value<int> medicationId;
  final Value<DateTime> scheduledDate;
  final Value<int> scheduledHour;
  final Value<int> scheduledMinute;
  final Value<String> status;
  final Value<DateTime?> actualTime;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const DoseHistoryCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.scheduledHour = const Value.absent(),
    this.scheduledMinute = const Value.absent(),
    this.status = const Value.absent(),
    this.actualTime = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DoseHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int medicationId,
    required DateTime scheduledDate,
    required int scheduledHour,
    required int scheduledMinute,
    required String status,
    this.actualTime = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : medicationId = Value(medicationId),
       scheduledDate = Value(scheduledDate),
       scheduledHour = Value(scheduledHour),
       scheduledMinute = Value(scheduledMinute),
       status = Value(status);
  static Insertable<DoseHistoryData> custom({
    Expression<int>? id,
    Expression<int>? medicationId,
    Expression<DateTime>? scheduledDate,
    Expression<int>? scheduledHour,
    Expression<int>? scheduledMinute,
    Expression<String>? status,
    Expression<DateTime>? actualTime,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (scheduledHour != null) 'scheduled_hour': scheduledHour,
      if (scheduledMinute != null) 'scheduled_minute': scheduledMinute,
      if (status != null) 'status': status,
      if (actualTime != null) 'actual_time': actualTime,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DoseHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? medicationId,
    Value<DateTime>? scheduledDate,
    Value<int>? scheduledHour,
    Value<int>? scheduledMinute,
    Value<String>? status,
    Value<DateTime?>? actualTime,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return DoseHistoryCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledHour: scheduledHour ?? this.scheduledHour,
      scheduledMinute: scheduledMinute ?? this.scheduledMinute,
      status: status ?? this.status,
      actualTime: actualTime ?? this.actualTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<int>(medicationId.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (scheduledHour.present) {
      map['scheduled_hour'] = Variable<int>(scheduledHour.value);
    }
    if (scheduledMinute.present) {
      map['scheduled_minute'] = Variable<int>(scheduledMinute.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (actualTime.present) {
      map['actual_time'] = Variable<DateTime>(actualTime.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoseHistoryCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('scheduledHour: $scheduledHour, ')
          ..write('scheduledMinute: $scheduledMinute, ')
          ..write('status: $status, ')
          ..write('actualTime: $actualTime, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $StockHistoryTable extends StockHistory
    with TableInfo<$StockHistoryTable, StockHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<int> medicationId = GeneratedColumn<int>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id)',
    ),
  );
  static const VerificationMeta _previousStockMeta = const VerificationMeta(
    'previousStock',
  );
  @override
  late final GeneratedColumn<int> previousStock = GeneratedColumn<int>(
    'previous_stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newStockMeta = const VerificationMeta(
    'newStock',
  );
  @override
  late final GeneratedColumn<int> newStock = GeneratedColumn<int>(
    'new_stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeAmountMeta = const VerificationMeta(
    'changeAmount',
  );
  @override
  late final GeneratedColumn<int> changeAmount = GeneratedColumn<int>(
    'change_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeTypeMeta = const VerificationMeta(
    'changeType',
  );
  @override
  late final GeneratedColumn<String> changeType = GeneratedColumn<String>(
    'change_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _changeDateMeta = const VerificationMeta(
    'changeDate',
  );
  @override
  late final GeneratedColumn<DateTime> changeDate = GeneratedColumn<DateTime>(
    'change_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationId,
    previousStock,
    newStock,
    changeAmount,
    changeType,
    notes,
    changeDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('previous_stock')) {
      context.handle(
        _previousStockMeta,
        previousStock.isAcceptableOrUnknown(
          data['previous_stock']!,
          _previousStockMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previousStockMeta);
    }
    if (data.containsKey('new_stock')) {
      context.handle(
        _newStockMeta,
        newStock.isAcceptableOrUnknown(data['new_stock']!, _newStockMeta),
      );
    } else if (isInserting) {
      context.missing(_newStockMeta);
    }
    if (data.containsKey('change_amount')) {
      context.handle(
        _changeAmountMeta,
        changeAmount.isAcceptableOrUnknown(
          data['change_amount']!,
          _changeAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_changeAmountMeta);
    }
    if (data.containsKey('change_type')) {
      context.handle(
        _changeTypeMeta,
        changeType.isAcceptableOrUnknown(data['change_type']!, _changeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_changeTypeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('change_date')) {
      context.handle(
        _changeDateMeta,
        changeDate.isAcceptableOrUnknown(data['change_date']!, _changeDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medication_id'],
      )!,
      previousStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}previous_stock'],
      )!,
      newStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_stock'],
      )!,
      changeAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}change_amount'],
      )!,
      changeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}change_type'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      changeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}change_date'],
      )!,
    );
  }

  @override
  $StockHistoryTable createAlias(String alias) {
    return $StockHistoryTable(attachedDatabase, alias);
  }
}

class StockHistoryData extends DataClass
    implements Insertable<StockHistoryData> {
  final int id;
  final int medicationId;
  final int previousStock;
  final int newStock;
  final int changeAmount;
  final String changeType;
  final String? notes;
  final DateTime changeDate;
  const StockHistoryData({
    required this.id,
    required this.medicationId,
    required this.previousStock,
    required this.newStock,
    required this.changeAmount,
    required this.changeType,
    this.notes,
    required this.changeDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medication_id'] = Variable<int>(medicationId);
    map['previous_stock'] = Variable<int>(previousStock);
    map['new_stock'] = Variable<int>(newStock);
    map['change_amount'] = Variable<int>(changeAmount);
    map['change_type'] = Variable<String>(changeType);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['change_date'] = Variable<DateTime>(changeDate);
    return map;
  }

  StockHistoryCompanion toCompanion(bool nullToAbsent) {
    return StockHistoryCompanion(
      id: Value(id),
      medicationId: Value(medicationId),
      previousStock: Value(previousStock),
      newStock: Value(newStock),
      changeAmount: Value(changeAmount),
      changeType: Value(changeType),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      changeDate: Value(changeDate),
    );
  }

  factory StockHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockHistoryData(
      id: serializer.fromJson<int>(json['id']),
      medicationId: serializer.fromJson<int>(json['medicationId']),
      previousStock: serializer.fromJson<int>(json['previousStock']),
      newStock: serializer.fromJson<int>(json['newStock']),
      changeAmount: serializer.fromJson<int>(json['changeAmount']),
      changeType: serializer.fromJson<String>(json['changeType']),
      notes: serializer.fromJson<String?>(json['notes']),
      changeDate: serializer.fromJson<DateTime>(json['changeDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicationId': serializer.toJson<int>(medicationId),
      'previousStock': serializer.toJson<int>(previousStock),
      'newStock': serializer.toJson<int>(newStock),
      'changeAmount': serializer.toJson<int>(changeAmount),
      'changeType': serializer.toJson<String>(changeType),
      'notes': serializer.toJson<String?>(notes),
      'changeDate': serializer.toJson<DateTime>(changeDate),
    };
  }

  StockHistoryData copyWith({
    int? id,
    int? medicationId,
    int? previousStock,
    int? newStock,
    int? changeAmount,
    String? changeType,
    Value<String?> notes = const Value.absent(),
    DateTime? changeDate,
  }) => StockHistoryData(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    previousStock: previousStock ?? this.previousStock,
    newStock: newStock ?? this.newStock,
    changeAmount: changeAmount ?? this.changeAmount,
    changeType: changeType ?? this.changeType,
    notes: notes.present ? notes.value : this.notes,
    changeDate: changeDate ?? this.changeDate,
  );
  StockHistoryData copyWithCompanion(StockHistoryCompanion data) {
    return StockHistoryData(
      id: data.id.present ? data.id.value : this.id,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      previousStock: data.previousStock.present
          ? data.previousStock.value
          : this.previousStock,
      newStock: data.newStock.present ? data.newStock.value : this.newStock,
      changeAmount: data.changeAmount.present
          ? data.changeAmount.value
          : this.changeAmount,
      changeType: data.changeType.present
          ? data.changeType.value
          : this.changeType,
      notes: data.notes.present ? data.notes.value : this.notes,
      changeDate: data.changeDate.present
          ? data.changeDate.value
          : this.changeDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockHistoryData(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('previousStock: $previousStock, ')
          ..write('newStock: $newStock, ')
          ..write('changeAmount: $changeAmount, ')
          ..write('changeType: $changeType, ')
          ..write('notes: $notes, ')
          ..write('changeDate: $changeDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicationId,
    previousStock,
    newStock,
    changeAmount,
    changeType,
    notes,
    changeDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockHistoryData &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.previousStock == this.previousStock &&
          other.newStock == this.newStock &&
          other.changeAmount == this.changeAmount &&
          other.changeType == this.changeType &&
          other.notes == this.notes &&
          other.changeDate == this.changeDate);
}

class StockHistoryCompanion extends UpdateCompanion<StockHistoryData> {
  final Value<int> id;
  final Value<int> medicationId;
  final Value<int> previousStock;
  final Value<int> newStock;
  final Value<int> changeAmount;
  final Value<String> changeType;
  final Value<String?> notes;
  final Value<DateTime> changeDate;
  const StockHistoryCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.previousStock = const Value.absent(),
    this.newStock = const Value.absent(),
    this.changeAmount = const Value.absent(),
    this.changeType = const Value.absent(),
    this.notes = const Value.absent(),
    this.changeDate = const Value.absent(),
  });
  StockHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int medicationId,
    required int previousStock,
    required int newStock,
    required int changeAmount,
    required String changeType,
    this.notes = const Value.absent(),
    this.changeDate = const Value.absent(),
  }) : medicationId = Value(medicationId),
       previousStock = Value(previousStock),
       newStock = Value(newStock),
       changeAmount = Value(changeAmount),
       changeType = Value(changeType);
  static Insertable<StockHistoryData> custom({
    Expression<int>? id,
    Expression<int>? medicationId,
    Expression<int>? previousStock,
    Expression<int>? newStock,
    Expression<int>? changeAmount,
    Expression<String>? changeType,
    Expression<String>? notes,
    Expression<DateTime>? changeDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (previousStock != null) 'previous_stock': previousStock,
      if (newStock != null) 'new_stock': newStock,
      if (changeAmount != null) 'change_amount': changeAmount,
      if (changeType != null) 'change_type': changeType,
      if (notes != null) 'notes': notes,
      if (changeDate != null) 'change_date': changeDate,
    });
  }

  StockHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? medicationId,
    Value<int>? previousStock,
    Value<int>? newStock,
    Value<int>? changeAmount,
    Value<String>? changeType,
    Value<String?>? notes,
    Value<DateTime>? changeDate,
  }) {
    return StockHistoryCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      previousStock: previousStock ?? this.previousStock,
      newStock: newStock ?? this.newStock,
      changeAmount: changeAmount ?? this.changeAmount,
      changeType: changeType ?? this.changeType,
      notes: notes ?? this.notes,
      changeDate: changeDate ?? this.changeDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<int>(medicationId.value);
    }
    if (previousStock.present) {
      map['previous_stock'] = Variable<int>(previousStock.value);
    }
    if (newStock.present) {
      map['new_stock'] = Variable<int>(newStock.value);
    }
    if (changeAmount.present) {
      map['change_amount'] = Variable<int>(changeAmount.value);
    }
    if (changeType.present) {
      map['change_type'] = Variable<String>(changeType.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (changeDate.present) {
      map['change_date'] = Variable<DateTime>(changeDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockHistoryCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('previousStock: $previousStock, ')
          ..write('newStock: $newStock, ')
          ..write('changeAmount: $changeAmount, ')
          ..write('changeType: $changeType, ')
          ..write('notes: $notes, ')
          ..write('changeDate: $changeDate')
          ..write(')'))
        .toString();
  }
}

class $SnoozeHistoryTableTable extends SnoozeHistoryTable
    with TableInfo<$SnoozeHistoryTableTable, SnoozeHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnoozeHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<int> medicationId = GeneratedColumn<int>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snoozeDateMeta = const VerificationMeta(
    'snoozeDate',
  );
  @override
  late final GeneratedColumn<DateTime> snoozeDate = GeneratedColumn<DateTime>(
    'snooze_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snoozeCountMeta = const VerificationMeta(
    'snoozeCount',
  );
  @override
  late final GeneratedColumn<int> snoozeCount = GeneratedColumn<int>(
    'snooze_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSnoozeTimeMeta = const VerificationMeta(
    'lastSnoozeTime',
  );
  @override
  late final GeneratedColumn<DateTime> lastSnoozeTime =
      GeneratedColumn<DateTime>(
        'last_snooze_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _suggestedMinutesMeta = const VerificationMeta(
    'suggestedMinutes',
  );
  @override
  late final GeneratedColumn<int> suggestedMinutes = GeneratedColumn<int>(
    'suggested_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(15),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationId,
    snoozeDate,
    snoozeCount,
    lastSnoozeTime,
    suggestedMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'snooze_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<SnoozeHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('snooze_date')) {
      context.handle(
        _snoozeDateMeta,
        snoozeDate.isAcceptableOrUnknown(data['snooze_date']!, _snoozeDateMeta),
      );
    } else if (isInserting) {
      context.missing(_snoozeDateMeta);
    }
    if (data.containsKey('snooze_count')) {
      context.handle(
        _snoozeCountMeta,
        snoozeCount.isAcceptableOrUnknown(
          data['snooze_count']!,
          _snoozeCountMeta,
        ),
      );
    }
    if (data.containsKey('last_snooze_time')) {
      context.handle(
        _lastSnoozeTimeMeta,
        lastSnoozeTime.isAcceptableOrUnknown(
          data['last_snooze_time']!,
          _lastSnoozeTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSnoozeTimeMeta);
    }
    if (data.containsKey('suggested_minutes')) {
      context.handle(
        _suggestedMinutesMeta,
        suggestedMinutes.isAcceptableOrUnknown(
          data['suggested_minutes']!,
          _suggestedMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnoozeHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnoozeHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medication_id'],
      )!,
      snoozeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}snooze_date'],
      )!,
      snoozeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_count'],
      )!,
      lastSnoozeTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_snooze_time'],
      )!,
      suggestedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}suggested_minutes'],
      )!,
    );
  }

  @override
  $SnoozeHistoryTableTable createAlias(String alias) {
    return $SnoozeHistoryTableTable(attachedDatabase, alias);
  }
}

class SnoozeHistoryData extends DataClass
    implements Insertable<SnoozeHistoryData> {
  /// Auto-incrementing primary key
  final int id;

  /// Foreign key to medications table
  final int medicationId;

  /// Date for this snooze record (date only, no time)
  final DateTime snoozeDate;

  /// Number of times snoozed today
  final int snoozeCount;

  /// Last snooze timestamp
  final DateTime lastSnoozeTime;

  /// Suggested snooze minutes used
  final int suggestedMinutes;
  const SnoozeHistoryData({
    required this.id,
    required this.medicationId,
    required this.snoozeDate,
    required this.snoozeCount,
    required this.lastSnoozeTime,
    required this.suggestedMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medication_id'] = Variable<int>(medicationId);
    map['snooze_date'] = Variable<DateTime>(snoozeDate);
    map['snooze_count'] = Variable<int>(snoozeCount);
    map['last_snooze_time'] = Variable<DateTime>(lastSnoozeTime);
    map['suggested_minutes'] = Variable<int>(suggestedMinutes);
    return map;
  }

  SnoozeHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return SnoozeHistoryTableCompanion(
      id: Value(id),
      medicationId: Value(medicationId),
      snoozeDate: Value(snoozeDate),
      snoozeCount: Value(snoozeCount),
      lastSnoozeTime: Value(lastSnoozeTime),
      suggestedMinutes: Value(suggestedMinutes),
    );
  }

  factory SnoozeHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnoozeHistoryData(
      id: serializer.fromJson<int>(json['id']),
      medicationId: serializer.fromJson<int>(json['medicationId']),
      snoozeDate: serializer.fromJson<DateTime>(json['snoozeDate']),
      snoozeCount: serializer.fromJson<int>(json['snoozeCount']),
      lastSnoozeTime: serializer.fromJson<DateTime>(json['lastSnoozeTime']),
      suggestedMinutes: serializer.fromJson<int>(json['suggestedMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicationId': serializer.toJson<int>(medicationId),
      'snoozeDate': serializer.toJson<DateTime>(snoozeDate),
      'snoozeCount': serializer.toJson<int>(snoozeCount),
      'lastSnoozeTime': serializer.toJson<DateTime>(lastSnoozeTime),
      'suggestedMinutes': serializer.toJson<int>(suggestedMinutes),
    };
  }

  SnoozeHistoryData copyWith({
    int? id,
    int? medicationId,
    DateTime? snoozeDate,
    int? snoozeCount,
    DateTime? lastSnoozeTime,
    int? suggestedMinutes,
  }) => SnoozeHistoryData(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    snoozeDate: snoozeDate ?? this.snoozeDate,
    snoozeCount: snoozeCount ?? this.snoozeCount,
    lastSnoozeTime: lastSnoozeTime ?? this.lastSnoozeTime,
    suggestedMinutes: suggestedMinutes ?? this.suggestedMinutes,
  );
  SnoozeHistoryData copyWithCompanion(SnoozeHistoryTableCompanion data) {
    return SnoozeHistoryData(
      id: data.id.present ? data.id.value : this.id,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      snoozeDate: data.snoozeDate.present
          ? data.snoozeDate.value
          : this.snoozeDate,
      snoozeCount: data.snoozeCount.present
          ? data.snoozeCount.value
          : this.snoozeCount,
      lastSnoozeTime: data.lastSnoozeTime.present
          ? data.lastSnoozeTime.value
          : this.lastSnoozeTime,
      suggestedMinutes: data.suggestedMinutes.present
          ? data.suggestedMinutes.value
          : this.suggestedMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnoozeHistoryData(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('snoozeDate: $snoozeDate, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('lastSnoozeTime: $lastSnoozeTime, ')
          ..write('suggestedMinutes: $suggestedMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicationId,
    snoozeDate,
    snoozeCount,
    lastSnoozeTime,
    suggestedMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnoozeHistoryData &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.snoozeDate == this.snoozeDate &&
          other.snoozeCount == this.snoozeCount &&
          other.lastSnoozeTime == this.lastSnoozeTime &&
          other.suggestedMinutes == this.suggestedMinutes);
}

class SnoozeHistoryTableCompanion extends UpdateCompanion<SnoozeHistoryData> {
  final Value<int> id;
  final Value<int> medicationId;
  final Value<DateTime> snoozeDate;
  final Value<int> snoozeCount;
  final Value<DateTime> lastSnoozeTime;
  final Value<int> suggestedMinutes;
  const SnoozeHistoryTableCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.snoozeDate = const Value.absent(),
    this.snoozeCount = const Value.absent(),
    this.lastSnoozeTime = const Value.absent(),
    this.suggestedMinutes = const Value.absent(),
  });
  SnoozeHistoryTableCompanion.insert({
    this.id = const Value.absent(),
    required int medicationId,
    required DateTime snoozeDate,
    this.snoozeCount = const Value.absent(),
    required DateTime lastSnoozeTime,
    this.suggestedMinutes = const Value.absent(),
  }) : medicationId = Value(medicationId),
       snoozeDate = Value(snoozeDate),
       lastSnoozeTime = Value(lastSnoozeTime);
  static Insertable<SnoozeHistoryData> custom({
    Expression<int>? id,
    Expression<int>? medicationId,
    Expression<DateTime>? snoozeDate,
    Expression<int>? snoozeCount,
    Expression<DateTime>? lastSnoozeTime,
    Expression<int>? suggestedMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (snoozeDate != null) 'snooze_date': snoozeDate,
      if (snoozeCount != null) 'snooze_count': snoozeCount,
      if (lastSnoozeTime != null) 'last_snooze_time': lastSnoozeTime,
      if (suggestedMinutes != null) 'suggested_minutes': suggestedMinutes,
    });
  }

  SnoozeHistoryTableCompanion copyWith({
    Value<int>? id,
    Value<int>? medicationId,
    Value<DateTime>? snoozeDate,
    Value<int>? snoozeCount,
    Value<DateTime>? lastSnoozeTime,
    Value<int>? suggestedMinutes,
  }) {
    return SnoozeHistoryTableCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      snoozeDate: snoozeDate ?? this.snoozeDate,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      lastSnoozeTime: lastSnoozeTime ?? this.lastSnoozeTime,
      suggestedMinutes: suggestedMinutes ?? this.suggestedMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<int>(medicationId.value);
    }
    if (snoozeDate.present) {
      map['snooze_date'] = Variable<DateTime>(snoozeDate.value);
    }
    if (snoozeCount.present) {
      map['snooze_count'] = Variable<int>(snoozeCount.value);
    }
    if (lastSnoozeTime.present) {
      map['last_snooze_time'] = Variable<DateTime>(lastSnoozeTime.value);
    }
    if (suggestedMinutes.present) {
      map['suggested_minutes'] = Variable<int>(suggestedMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnoozeHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('snoozeDate: $snoozeDate, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('lastSnoozeTime: $lastSnoozeTime, ')
          ..write('suggestedMinutes: $suggestedMinutes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $ReminderTimesTable reminderTimes = $ReminderTimesTable(this);
  late final $DoseHistoryTable doseHistory = $DoseHistoryTable(this);
  late final $StockHistoryTable stockHistory = $StockHistoryTable(this);
  late final $SnoozeHistoryTableTable snoozeHistoryTable =
      $SnoozeHistoryTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    medications,
    reminderTimes,
    doseHistory,
    stockHistory,
    snoozeHistoryTable,
  ];
}

typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      required String medicineType,
      required String medicineName,
      Value<String?> medicinePhotoPath,
      Value<String?> strength,
      Value<String?> unit,
      Value<String?> notes,
      Value<bool> isScanned,
      Value<int> timesPerDay,
      Value<double> dosePerTime,
      Value<String> doseUnit,
      Value<int> durationDays,
      required DateTime startDate,
      Value<String> repetitionPattern,
      Value<String> specificDaysOfWeek,
      Value<int> stockQuantity,
      Value<bool> remindBeforeRunOut,
      Value<int> reminderDaysBeforeRunOut,
      Value<DateTime?> expiryDate,
      Value<int> reminderDaysBeforeExpiry,
      Value<String?> customSoundPath,
      Value<int> maxSnoozesPerDay,
      Value<bool> enableRecurringReminders,
      Value<int> recurringReminderInterval,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<int> id,
      Value<String> medicineType,
      Value<String> medicineName,
      Value<String?> medicinePhotoPath,
      Value<String?> strength,
      Value<String?> unit,
      Value<String?> notes,
      Value<bool> isScanned,
      Value<int> timesPerDay,
      Value<double> dosePerTime,
      Value<String> doseUnit,
      Value<int> durationDays,
      Value<DateTime> startDate,
      Value<String> repetitionPattern,
      Value<String> specificDaysOfWeek,
      Value<int> stockQuantity,
      Value<bool> remindBeforeRunOut,
      Value<int> reminderDaysBeforeRunOut,
      Value<DateTime?> expiryDate,
      Value<int> reminderDaysBeforeExpiry,
      Value<String?> customSoundPath,
      Value<int> maxSnoozesPerDay,
      Value<bool> enableRecurringReminders,
      Value<int> recurringReminderInterval,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
    });

final class $$MedicationsTableReferences
    extends BaseReferences<_$AppDatabase, $MedicationsTable, Medication> {
  $$MedicationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReminderTimesTable, List<ReminderTime>>
  _reminderTimesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reminderTimes,
    aliasName: $_aliasNameGenerator(
      db.medications.id,
      db.reminderTimes.medicationId,
    ),
  );

  $$ReminderTimesTableProcessedTableManager get reminderTimesRefs {
    final manager = $$ReminderTimesTableTableManager(
      $_db,
      $_db.reminderTimes,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reminderTimesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DoseHistoryTable, List<DoseHistoryData>>
  _doseHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.doseHistory,
    aliasName: $_aliasNameGenerator(
      db.medications.id,
      db.doseHistory.medicationId,
    ),
  );

  $$DoseHistoryTableProcessedTableManager get doseHistoryRefs {
    final manager = $$DoseHistoryTableTableManager(
      $_db,
      $_db.doseHistory,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_doseHistoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockHistoryTable, List<StockHistoryData>>
  _stockHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockHistory,
    aliasName: $_aliasNameGenerator(
      db.medications.id,
      db.stockHistory.medicationId,
    ),
  );

  $$StockHistoryTableProcessedTableManager get stockHistoryRefs {
    final manager = $$StockHistoryTableTableManager(
      $_db,
      $_db.stockHistory,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockHistoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicineType => $composableBuilder(
    column: $table.medicineType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicineName => $composableBuilder(
    column: $table.medicineName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicinePhotoPath => $composableBuilder(
    column: $table.medicinePhotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isScanned => $composableBuilder(
    column: $table.isScanned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesPerDay => $composableBuilder(
    column: $table.timesPerDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dosePerTime => $composableBuilder(
    column: $table.dosePerTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doseUnit => $composableBuilder(
    column: $table.doseUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repetitionPattern => $composableBuilder(
    column: $table.repetitionPattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specificDaysOfWeek => $composableBuilder(
    column: $table.specificDaysOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get remindBeforeRunOut => $composableBuilder(
    column: $table.remindBeforeRunOut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderDaysBeforeRunOut => $composableBuilder(
    column: $table.reminderDaysBeforeRunOut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderDaysBeforeExpiry => $composableBuilder(
    column: $table.reminderDaysBeforeExpiry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customSoundPath => $composableBuilder(
    column: $table.customSoundPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxSnoozesPerDay => $composableBuilder(
    column: $table.maxSnoozesPerDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableRecurringReminders => $composableBuilder(
    column: $table.enableRecurringReminders,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recurringReminderInterval => $composableBuilder(
    column: $table.recurringReminderInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> reminderTimesRefs(
    Expression<bool> Function($$ReminderTimesTableFilterComposer f) f,
  ) {
    final $$ReminderTimesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderTimes,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderTimesTableFilterComposer(
            $db: $db,
            $table: $db.reminderTimes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> doseHistoryRefs(
    Expression<bool> Function($$DoseHistoryTableFilterComposer f) f,
  ) {
    final $$DoseHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doseHistory,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoseHistoryTableFilterComposer(
            $db: $db,
            $table: $db.doseHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockHistoryRefs(
    Expression<bool> Function($$StockHistoryTableFilterComposer f) f,
  ) {
    final $$StockHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockHistory,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockHistoryTableFilterComposer(
            $db: $db,
            $table: $db.stockHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicineType => $composableBuilder(
    column: $table.medicineType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicineName => $composableBuilder(
    column: $table.medicineName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicinePhotoPath => $composableBuilder(
    column: $table.medicinePhotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isScanned => $composableBuilder(
    column: $table.isScanned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesPerDay => $composableBuilder(
    column: $table.timesPerDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dosePerTime => $composableBuilder(
    column: $table.dosePerTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doseUnit => $composableBuilder(
    column: $table.doseUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repetitionPattern => $composableBuilder(
    column: $table.repetitionPattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specificDaysOfWeek => $composableBuilder(
    column: $table.specificDaysOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get remindBeforeRunOut => $composableBuilder(
    column: $table.remindBeforeRunOut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderDaysBeforeRunOut => $composableBuilder(
    column: $table.reminderDaysBeforeRunOut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderDaysBeforeExpiry => $composableBuilder(
    column: $table.reminderDaysBeforeExpiry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customSoundPath => $composableBuilder(
    column: $table.customSoundPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxSnoozesPerDay => $composableBuilder(
    column: $table.maxSnoozesPerDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableRecurringReminders => $composableBuilder(
    column: $table.enableRecurringReminders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recurringReminderInterval => $composableBuilder(
    column: $table.recurringReminderInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get medicineType => $composableBuilder(
    column: $table.medicineType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get medicineName => $composableBuilder(
    column: $table.medicineName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get medicinePhotoPath => $composableBuilder(
    column: $table.medicinePhotoPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isScanned =>
      $composableBuilder(column: $table.isScanned, builder: (column) => column);

  GeneratedColumn<int> get timesPerDay => $composableBuilder(
    column: $table.timesPerDay,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dosePerTime => $composableBuilder(
    column: $table.dosePerTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get doseUnit =>
      $composableBuilder(column: $table.doseUnit, builder: (column) => column);

  GeneratedColumn<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get repetitionPattern => $composableBuilder(
    column: $table.repetitionPattern,
    builder: (column) => column,
  );

  GeneratedColumn<String> get specificDaysOfWeek => $composableBuilder(
    column: $table.specificDaysOfWeek,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get remindBeforeRunOut => $composableBuilder(
    column: $table.remindBeforeRunOut,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderDaysBeforeRunOut => $composableBuilder(
    column: $table.reminderDaysBeforeRunOut,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderDaysBeforeExpiry => $composableBuilder(
    column: $table.reminderDaysBeforeExpiry,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customSoundPath => $composableBuilder(
    column: $table.customSoundPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxSnoozesPerDay => $composableBuilder(
    column: $table.maxSnoozesPerDay,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableRecurringReminders => $composableBuilder(
    column: $table.enableRecurringReminders,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recurringReminderInterval => $composableBuilder(
    column: $table.recurringReminderInterval,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> reminderTimesRefs<T extends Object>(
    Expression<T> Function($$ReminderTimesTableAnnotationComposer a) f,
  ) {
    final $$ReminderTimesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminderTimes,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReminderTimesTableAnnotationComposer(
            $db: $db,
            $table: $db.reminderTimes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> doseHistoryRefs<T extends Object>(
    Expression<T> Function($$DoseHistoryTableAnnotationComposer a) f,
  ) {
    final $$DoseHistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doseHistory,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoseHistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.doseHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stockHistoryRefs<T extends Object>(
    Expression<T> Function($$StockHistoryTableAnnotationComposer a) f,
  ) {
    final $$StockHistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockHistory,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockHistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.stockHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationsTable,
          Medication,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (Medication, $$MedicationsTableReferences),
          Medication,
          PrefetchHooks Function({
            bool reminderTimesRefs,
            bool doseHistoryRefs,
            bool stockHistoryRefs,
          })
        > {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> medicineType = const Value.absent(),
                Value<String> medicineName = const Value.absent(),
                Value<String?> medicinePhotoPath = const Value.absent(),
                Value<String?> strength = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isScanned = const Value.absent(),
                Value<int> timesPerDay = const Value.absent(),
                Value<double> dosePerTime = const Value.absent(),
                Value<String> doseUnit = const Value.absent(),
                Value<int> durationDays = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<String> repetitionPattern = const Value.absent(),
                Value<String> specificDaysOfWeek = const Value.absent(),
                Value<int> stockQuantity = const Value.absent(),
                Value<bool> remindBeforeRunOut = const Value.absent(),
                Value<int> reminderDaysBeforeRunOut = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<int> reminderDaysBeforeExpiry = const Value.absent(),
                Value<String?> customSoundPath = const Value.absent(),
                Value<int> maxSnoozesPerDay = const Value.absent(),
                Value<bool> enableRecurringReminders = const Value.absent(),
                Value<int> recurringReminderInterval = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                medicineType: medicineType,
                medicineName: medicineName,
                medicinePhotoPath: medicinePhotoPath,
                strength: strength,
                unit: unit,
                notes: notes,
                isScanned: isScanned,
                timesPerDay: timesPerDay,
                dosePerTime: dosePerTime,
                doseUnit: doseUnit,
                durationDays: durationDays,
                startDate: startDate,
                repetitionPattern: repetitionPattern,
                specificDaysOfWeek: specificDaysOfWeek,
                stockQuantity: stockQuantity,
                remindBeforeRunOut: remindBeforeRunOut,
                reminderDaysBeforeRunOut: reminderDaysBeforeRunOut,
                expiryDate: expiryDate,
                reminderDaysBeforeExpiry: reminderDaysBeforeExpiry,
                customSoundPath: customSoundPath,
                maxSnoozesPerDay: maxSnoozesPerDay,
                enableRecurringReminders: enableRecurringReminders,
                recurringReminderInterval: recurringReminderInterval,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String medicineType,
                required String medicineName,
                Value<String?> medicinePhotoPath = const Value.absent(),
                Value<String?> strength = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isScanned = const Value.absent(),
                Value<int> timesPerDay = const Value.absent(),
                Value<double> dosePerTime = const Value.absent(),
                Value<String> doseUnit = const Value.absent(),
                Value<int> durationDays = const Value.absent(),
                required DateTime startDate,
                Value<String> repetitionPattern = const Value.absent(),
                Value<String> specificDaysOfWeek = const Value.absent(),
                Value<int> stockQuantity = const Value.absent(),
                Value<bool> remindBeforeRunOut = const Value.absent(),
                Value<int> reminderDaysBeforeRunOut = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
                Value<int> reminderDaysBeforeExpiry = const Value.absent(),
                Value<String?> customSoundPath = const Value.absent(),
                Value<int> maxSnoozesPerDay = const Value.absent(),
                Value<bool> enableRecurringReminders = const Value.absent(),
                Value<int> recurringReminderInterval = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => MedicationsCompanion.insert(
                id: id,
                medicineType: medicineType,
                medicineName: medicineName,
                medicinePhotoPath: medicinePhotoPath,
                strength: strength,
                unit: unit,
                notes: notes,
                isScanned: isScanned,
                timesPerDay: timesPerDay,
                dosePerTime: dosePerTime,
                doseUnit: doseUnit,
                durationDays: durationDays,
                startDate: startDate,
                repetitionPattern: repetitionPattern,
                specificDaysOfWeek: specificDaysOfWeek,
                stockQuantity: stockQuantity,
                remindBeforeRunOut: remindBeforeRunOut,
                reminderDaysBeforeRunOut: reminderDaysBeforeRunOut,
                expiryDate: expiryDate,
                reminderDaysBeforeExpiry: reminderDaysBeforeExpiry,
                customSoundPath: customSoundPath,
                maxSnoozesPerDay: maxSnoozesPerDay,
                enableRecurringReminders: enableRecurringReminders,
                recurringReminderInterval: recurringReminderInterval,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                reminderTimesRefs = false,
                doseHistoryRefs = false,
                stockHistoryRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (reminderTimesRefs) db.reminderTimes,
                    if (doseHistoryRefs) db.doseHistory,
                    if (stockHistoryRefs) db.stockHistory,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (reminderTimesRefs)
                        await $_getPrefetchedData<
                          Medication,
                          $MedicationsTable,
                          ReminderTime
                        >(
                          currentTable: table,
                          referencedTable: $$MedicationsTableReferences
                              ._reminderTimesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).reminderTimesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (doseHistoryRefs)
                        await $_getPrefetchedData<
                          Medication,
                          $MedicationsTable,
                          DoseHistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$MedicationsTableReferences
                              ._doseHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).doseHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stockHistoryRefs)
                        await $_getPrefetchedData<
                          Medication,
                          $MedicationsTable,
                          StockHistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$MedicationsTableReferences
                              ._stockHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationsTable,
      Medication,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (Medication, $$MedicationsTableReferences),
      Medication,
      PrefetchHooks Function({
        bool reminderTimesRefs,
        bool doseHistoryRefs,
        bool stockHistoryRefs,
      })
    >;
typedef $$ReminderTimesTableCreateCompanionBuilder =
    ReminderTimesCompanion Function({
      Value<int> id,
      required int medicationId,
      required int hour,
      required int minute,
      required int orderIndex,
      Value<String> mealTiming,
      Value<int> mealOffsetMinutes,
    });
typedef $$ReminderTimesTableUpdateCompanionBuilder =
    ReminderTimesCompanion Function({
      Value<int> id,
      Value<int> medicationId,
      Value<int> hour,
      Value<int> minute,
      Value<int> orderIndex,
      Value<String> mealTiming,
      Value<int> mealOffsetMinutes,
    });

final class $$ReminderTimesTableReferences
    extends BaseReferences<_$AppDatabase, $ReminderTimesTable, ReminderTime> {
  $$ReminderTimesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) =>
      db.medications.createAlias(
        $_aliasNameGenerator(db.reminderTimes.medicationId, db.medications.id),
      );

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<int>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReminderTimesTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderTimesTable> {
  $$ReminderTimesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealTiming => $composableBuilder(
    column: $table.mealTiming,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mealOffsetMinutes => $composableBuilder(
    column: $table.mealOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderTimesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderTimesTable> {
  $$ReminderTimesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealTiming => $composableBuilder(
    column: $table.mealTiming,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mealOffsetMinutes => $composableBuilder(
    column: $table.mealOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderTimesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderTimesTable> {
  $$ReminderTimesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => column);

  GeneratedColumn<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mealTiming => $composableBuilder(
    column: $table.mealTiming,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mealOffsetMinutes => $composableBuilder(
    column: $table.mealOffsetMinutes,
    builder: (column) => column,
  );

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReminderTimesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderTimesTable,
          ReminderTime,
          $$ReminderTimesTableFilterComposer,
          $$ReminderTimesTableOrderingComposer,
          $$ReminderTimesTableAnnotationComposer,
          $$ReminderTimesTableCreateCompanionBuilder,
          $$ReminderTimesTableUpdateCompanionBuilder,
          (ReminderTime, $$ReminderTimesTableReferences),
          ReminderTime,
          PrefetchHooks Function({bool medicationId})
        > {
  $$ReminderTimesTableTableManager(_$AppDatabase db, $ReminderTimesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderTimesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderTimesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderTimesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> medicationId = const Value.absent(),
                Value<int> hour = const Value.absent(),
                Value<int> minute = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String> mealTiming = const Value.absent(),
                Value<int> mealOffsetMinutes = const Value.absent(),
              }) => ReminderTimesCompanion(
                id: id,
                medicationId: medicationId,
                hour: hour,
                minute: minute,
                orderIndex: orderIndex,
                mealTiming: mealTiming,
                mealOffsetMinutes: mealOffsetMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int medicationId,
                required int hour,
                required int minute,
                required int orderIndex,
                Value<String> mealTiming = const Value.absent(),
                Value<int> mealOffsetMinutes = const Value.absent(),
              }) => ReminderTimesCompanion.insert(
                id: id,
                medicationId: medicationId,
                hour: hour,
                minute: minute,
                orderIndex: orderIndex,
                mealTiming: mealTiming,
                mealOffsetMinutes: mealOffsetMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReminderTimesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (medicationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.medicationId,
                                referencedTable: $$ReminderTimesTableReferences
                                    ._medicationIdTable(db),
                                referencedColumn: $$ReminderTimesTableReferences
                                    ._medicationIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReminderTimesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderTimesTable,
      ReminderTime,
      $$ReminderTimesTableFilterComposer,
      $$ReminderTimesTableOrderingComposer,
      $$ReminderTimesTableAnnotationComposer,
      $$ReminderTimesTableCreateCompanionBuilder,
      $$ReminderTimesTableUpdateCompanionBuilder,
      (ReminderTime, $$ReminderTimesTableReferences),
      ReminderTime,
      PrefetchHooks Function({bool medicationId})
    >;
typedef $$DoseHistoryTableCreateCompanionBuilder =
    DoseHistoryCompanion Function({
      Value<int> id,
      required int medicationId,
      required DateTime scheduledDate,
      required int scheduledHour,
      required int scheduledMinute,
      required String status,
      Value<DateTime?> actualTime,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$DoseHistoryTableUpdateCompanionBuilder =
    DoseHistoryCompanion Function({
      Value<int> id,
      Value<int> medicationId,
      Value<DateTime> scheduledDate,
      Value<int> scheduledHour,
      Value<int> scheduledMinute,
      Value<String> status,
      Value<DateTime?> actualTime,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$DoseHistoryTableReferences
    extends BaseReferences<_$AppDatabase, $DoseHistoryTable, DoseHistoryData> {
  $$DoseHistoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) =>
      db.medications.createAlias(
        $_aliasNameGenerator(db.doseHistory.medicationId, db.medications.id),
      );

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<int>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DoseHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $DoseHistoryTable> {
  $$DoseHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledHour => $composableBuilder(
    column: $table.scheduledHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledMinute => $composableBuilder(
    column: $table.scheduledMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualTime => $composableBuilder(
    column: $table.actualTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DoseHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $DoseHistoryTable> {
  $$DoseHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledHour => $composableBuilder(
    column: $table.scheduledHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledMinute => $composableBuilder(
    column: $table.scheduledMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualTime => $composableBuilder(
    column: $table.actualTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DoseHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $DoseHistoryTable> {
  $$DoseHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledHour => $composableBuilder(
    column: $table.scheduledHour,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledMinute => $composableBuilder(
    column: $table.scheduledMinute,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get actualTime => $composableBuilder(
    column: $table.actualTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DoseHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DoseHistoryTable,
          DoseHistoryData,
          $$DoseHistoryTableFilterComposer,
          $$DoseHistoryTableOrderingComposer,
          $$DoseHistoryTableAnnotationComposer,
          $$DoseHistoryTableCreateCompanionBuilder,
          $$DoseHistoryTableUpdateCompanionBuilder,
          (DoseHistoryData, $$DoseHistoryTableReferences),
          DoseHistoryData,
          PrefetchHooks Function({bool medicationId})
        > {
  $$DoseHistoryTableTableManager(_$AppDatabase db, $DoseHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DoseHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DoseHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DoseHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> medicationId = const Value.absent(),
                Value<DateTime> scheduledDate = const Value.absent(),
                Value<int> scheduledHour = const Value.absent(),
                Value<int> scheduledMinute = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> actualTime = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DoseHistoryCompanion(
                id: id,
                medicationId: medicationId,
                scheduledDate: scheduledDate,
                scheduledHour: scheduledHour,
                scheduledMinute: scheduledMinute,
                status: status,
                actualTime: actualTime,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int medicationId,
                required DateTime scheduledDate,
                required int scheduledHour,
                required int scheduledMinute,
                required String status,
                Value<DateTime?> actualTime = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DoseHistoryCompanion.insert(
                id: id,
                medicationId: medicationId,
                scheduledDate: scheduledDate,
                scheduledHour: scheduledHour,
                scheduledMinute: scheduledMinute,
                status: status,
                actualTime: actualTime,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DoseHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (medicationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.medicationId,
                                referencedTable: $$DoseHistoryTableReferences
                                    ._medicationIdTable(db),
                                referencedColumn: $$DoseHistoryTableReferences
                                    ._medicationIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DoseHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DoseHistoryTable,
      DoseHistoryData,
      $$DoseHistoryTableFilterComposer,
      $$DoseHistoryTableOrderingComposer,
      $$DoseHistoryTableAnnotationComposer,
      $$DoseHistoryTableCreateCompanionBuilder,
      $$DoseHistoryTableUpdateCompanionBuilder,
      (DoseHistoryData, $$DoseHistoryTableReferences),
      DoseHistoryData,
      PrefetchHooks Function({bool medicationId})
    >;
typedef $$StockHistoryTableCreateCompanionBuilder =
    StockHistoryCompanion Function({
      Value<int> id,
      required int medicationId,
      required int previousStock,
      required int newStock,
      required int changeAmount,
      required String changeType,
      Value<String?> notes,
      Value<DateTime> changeDate,
    });
typedef $$StockHistoryTableUpdateCompanionBuilder =
    StockHistoryCompanion Function({
      Value<int> id,
      Value<int> medicationId,
      Value<int> previousStock,
      Value<int> newStock,
      Value<int> changeAmount,
      Value<String> changeType,
      Value<String?> notes,
      Value<DateTime> changeDate,
    });

final class $$StockHistoryTableReferences
    extends
        BaseReferences<_$AppDatabase, $StockHistoryTable, StockHistoryData> {
  $$StockHistoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) =>
      db.medications.createAlias(
        $_aliasNameGenerator(db.stockHistory.medicationId, db.medications.id),
      );

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<int>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $StockHistoryTable> {
  $$StockHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get previousStock => $composableBuilder(
    column: $table.previousStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newStock => $composableBuilder(
    column: $table.newStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changeDate => $composableBuilder(
    column: $table.changeDate,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $StockHistoryTable> {
  $$StockHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previousStock => $composableBuilder(
    column: $table.previousStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newStock => $composableBuilder(
    column: $table.newStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changeDate => $composableBuilder(
    column: $table.changeDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockHistoryTable> {
  $$StockHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get previousStock => $composableBuilder(
    column: $table.previousStock,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newStock =>
      $composableBuilder(column: $table.newStock, builder: (column) => column);

  GeneratedColumn<int> get changeAmount => $composableBuilder(
    column: $table.changeAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get changeDate => $composableBuilder(
    column: $table.changeDate,
    builder: (column) => column,
  );

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockHistoryTable,
          StockHistoryData,
          $$StockHistoryTableFilterComposer,
          $$StockHistoryTableOrderingComposer,
          $$StockHistoryTableAnnotationComposer,
          $$StockHistoryTableCreateCompanionBuilder,
          $$StockHistoryTableUpdateCompanionBuilder,
          (StockHistoryData, $$StockHistoryTableReferences),
          StockHistoryData,
          PrefetchHooks Function({bool medicationId})
        > {
  $$StockHistoryTableTableManager(_$AppDatabase db, $StockHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> medicationId = const Value.absent(),
                Value<int> previousStock = const Value.absent(),
                Value<int> newStock = const Value.absent(),
                Value<int> changeAmount = const Value.absent(),
                Value<String> changeType = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> changeDate = const Value.absent(),
              }) => StockHistoryCompanion(
                id: id,
                medicationId: medicationId,
                previousStock: previousStock,
                newStock: newStock,
                changeAmount: changeAmount,
                changeType: changeType,
                notes: notes,
                changeDate: changeDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int medicationId,
                required int previousStock,
                required int newStock,
                required int changeAmount,
                required String changeType,
                Value<String?> notes = const Value.absent(),
                Value<DateTime> changeDate = const Value.absent(),
              }) => StockHistoryCompanion.insert(
                id: id,
                medicationId: medicationId,
                previousStock: previousStock,
                newStock: newStock,
                changeAmount: changeAmount,
                changeType: changeType,
                notes: notes,
                changeDate: changeDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (medicationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.medicationId,
                                referencedTable: $$StockHistoryTableReferences
                                    ._medicationIdTable(db),
                                referencedColumn: $$StockHistoryTableReferences
                                    ._medicationIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StockHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockHistoryTable,
      StockHistoryData,
      $$StockHistoryTableFilterComposer,
      $$StockHistoryTableOrderingComposer,
      $$StockHistoryTableAnnotationComposer,
      $$StockHistoryTableCreateCompanionBuilder,
      $$StockHistoryTableUpdateCompanionBuilder,
      (StockHistoryData, $$StockHistoryTableReferences),
      StockHistoryData,
      PrefetchHooks Function({bool medicationId})
    >;
typedef $$SnoozeHistoryTableTableCreateCompanionBuilder =
    SnoozeHistoryTableCompanion Function({
      Value<int> id,
      required int medicationId,
      required DateTime snoozeDate,
      Value<int> snoozeCount,
      required DateTime lastSnoozeTime,
      Value<int> suggestedMinutes,
    });
typedef $$SnoozeHistoryTableTableUpdateCompanionBuilder =
    SnoozeHistoryTableCompanion Function({
      Value<int> id,
      Value<int> medicationId,
      Value<DateTime> snoozeDate,
      Value<int> snoozeCount,
      Value<DateTime> lastSnoozeTime,
      Value<int> suggestedMinutes,
    });

class $$SnoozeHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $SnoozeHistoryTableTable> {
  $$SnoozeHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get medicationId => $composableBuilder(
    column: $table.medicationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get snoozeDate => $composableBuilder(
    column: $table.snoozeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSnoozeTime => $composableBuilder(
    column: $table.lastSnoozeTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get suggestedMinutes => $composableBuilder(
    column: $table.suggestedMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SnoozeHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SnoozeHistoryTableTable> {
  $$SnoozeHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get medicationId => $composableBuilder(
    column: $table.medicationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get snoozeDate => $composableBuilder(
    column: $table.snoozeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSnoozeTime => $composableBuilder(
    column: $table.lastSnoozeTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get suggestedMinutes => $composableBuilder(
    column: $table.suggestedMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SnoozeHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnoozeHistoryTableTable> {
  $$SnoozeHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get medicationId => $composableBuilder(
    column: $table.medicationId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get snoozeDate => $composableBuilder(
    column: $table.snoozeDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSnoozeTime => $composableBuilder(
    column: $table.lastSnoozeTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get suggestedMinutes => $composableBuilder(
    column: $table.suggestedMinutes,
    builder: (column) => column,
  );
}

class $$SnoozeHistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SnoozeHistoryTableTable,
          SnoozeHistoryData,
          $$SnoozeHistoryTableTableFilterComposer,
          $$SnoozeHistoryTableTableOrderingComposer,
          $$SnoozeHistoryTableTableAnnotationComposer,
          $$SnoozeHistoryTableTableCreateCompanionBuilder,
          $$SnoozeHistoryTableTableUpdateCompanionBuilder,
          (
            SnoozeHistoryData,
            BaseReferences<
              _$AppDatabase,
              $SnoozeHistoryTableTable,
              SnoozeHistoryData
            >,
          ),
          SnoozeHistoryData,
          PrefetchHooks Function()
        > {
  $$SnoozeHistoryTableTableTableManager(
    _$AppDatabase db,
    $SnoozeHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnoozeHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnoozeHistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SnoozeHistoryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> medicationId = const Value.absent(),
                Value<DateTime> snoozeDate = const Value.absent(),
                Value<int> snoozeCount = const Value.absent(),
                Value<DateTime> lastSnoozeTime = const Value.absent(),
                Value<int> suggestedMinutes = const Value.absent(),
              }) => SnoozeHistoryTableCompanion(
                id: id,
                medicationId: medicationId,
                snoozeDate: snoozeDate,
                snoozeCount: snoozeCount,
                lastSnoozeTime: lastSnoozeTime,
                suggestedMinutes: suggestedMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int medicationId,
                required DateTime snoozeDate,
                Value<int> snoozeCount = const Value.absent(),
                required DateTime lastSnoozeTime,
                Value<int> suggestedMinutes = const Value.absent(),
              }) => SnoozeHistoryTableCompanion.insert(
                id: id,
                medicationId: medicationId,
                snoozeDate: snoozeDate,
                snoozeCount: snoozeCount,
                lastSnoozeTime: lastSnoozeTime,
                suggestedMinutes: suggestedMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SnoozeHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SnoozeHistoryTableTable,
      SnoozeHistoryData,
      $$SnoozeHistoryTableTableFilterComposer,
      $$SnoozeHistoryTableTableOrderingComposer,
      $$SnoozeHistoryTableTableAnnotationComposer,
      $$SnoozeHistoryTableTableCreateCompanionBuilder,
      $$SnoozeHistoryTableTableUpdateCompanionBuilder,
      (
        SnoozeHistoryData,
        BaseReferences<
          _$AppDatabase,
          $SnoozeHistoryTableTable,
          SnoozeHistoryData
        >,
      ),
      SnoozeHistoryData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$ReminderTimesTableTableManager get reminderTimes =>
      $$ReminderTimesTableTableManager(_db, _db.reminderTimes);
  $$DoseHistoryTableTableManager get doseHistory =>
      $$DoseHistoryTableTableManager(_db, _db.doseHistory);
  $$StockHistoryTableTableManager get stockHistory =>
      $$StockHistoryTableTableManager(_db, _db.stockHistory);
  $$SnoozeHistoryTableTableTableManager get snoozeHistoryTable =>
      $$SnoozeHistoryTableTableTableManager(_db, _db.snoozeHistoryTable);
}
