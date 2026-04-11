import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/features/add_medication/utils/step1_actions.dart';
import 'package:med_assist/features/add_medication/widgets/medicine_name_input.dart';
import 'package:med_assist/features/add_medication/widgets/medicine_photo_picker.dart';
import 'package:med_assist/features/add_medication/widgets/medicine_type_card.dart';
import 'package:med_assist/features/add_medication/widgets/section_title.dart';
import 'package:med_assist/features/add_medication/widgets/step_validation_indicator.dart';
import 'package:med_assist/features/add_medication/widgets/strength_unit_input.dart';
import 'package:med_assist/features/add_medication/widgets/type_info_header.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Step 1: Type & Info - Medicine basic information.
class Step1TypeInfo extends ConsumerStatefulWidget {
  const Step1TypeInfo({super.key});

  @override
  ConsumerState<Step1TypeInfo> createState() => _Step1TypeInfoState();
}

class _Step1TypeInfoState extends ConsumerState<Step1TypeInfo>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _nameController = TextEditingController();
  final _strengthController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const _strengthUnits = ['mg', 'g', 'ml', 'mcg', 'IU', '%'];
  String _selectedUnit = 'mg';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final formData = ref.read(medicationFormProvider);
      if (formData.medicineName != null) {
        _nameController.text = formData.medicineName!;
      }
      if (formData.strength != null) {
        _strengthController.text = formData.strength!;
      }
      if (formData.unit != null) {
        _selectedUnit = formData.unit!;
      }
      if (formData.notes != null) {
        _notesController.text = formData.notes!;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _strengthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formData = ref.watch(medicationFormProvider);
    final l10n = AppLocalizations.of(context)!;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TypeInfoHeader(),
                const SizedBox(height: 32),

                SectionTitle(l10n.chooseMedicineType),
                const SizedBox(height: 16),
                _MedicineTypeGrid(formData: formData),
                const SizedBox(height: 32),

                SectionTitle('${l10n.medicineName} *'),
                const SizedBox(height: 12),
                MedicineNameInput(
                  controller: _nameController,
                  onChanged: (value) => ref
                      .read(medicationFormProvider.notifier)
                      .setMedicineName(value),
                  onScanName: () => Step1Actions.scanMedicineName(
                    context: context,
                    ref: ref,
                    nameController: _nameController,
                    strengthController: _strengthController,
                    onUnitChanged: (u) => setState(() => _selectedUnit = u),
                  ),
                  onScanBarcode: () => Step1Actions.scanBarcode(
                    context: context,
                    ref: ref,
                    nameController: _nameController,
                    strengthController: _strengthController,
                    notesController: _notesController,
                    strengthUnits: _strengthUnits,
                    onUnitChanged: (u) => setState(() => _selectedUnit = u),
                  ),
                ),
                const SizedBox(height: 24),

                SectionTitle(l10n.medicinePhoto, isOptional: true),
                const SizedBox(height: 12),
                MedicinePhotoPicker(
                  photoPath: formData.medicinePhotoPath,
                  onTakePhoto: () =>
                      Step1Actions.takePhoto(context: context, ref: ref),
                  onPickFromGallery: () =>
                      Step1Actions.pickFromGallery(context: context, ref: ref),
                  onRemovePhoto: () =>
                      Step1Actions.removePhoto(context: context, ref: ref),
                ),
                const SizedBox(height: 24),

                SectionTitle(l10n.strengthAndUnit, isOptional: true),
                const SizedBox(height: 12),
                StrengthUnitInput(
                  controller: _strengthController,
                  selectedUnit: _selectedUnit,
                  units: _strengthUnits,
                  onStrengthChanged: (value) => ref
                      .read(medicationFormProvider.notifier)
                      .setStrength(value),
                  onUnitChanged: (value) {
                    setState(() => _selectedUnit = value);
                    ref.read(medicationFormProvider.notifier).setUnit(value);
                  },
                ),
                const SizedBox(height: 24),

                SectionTitle(l10n.notes, isOptional: true),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Take with food, Avoid alcohol',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 60),
                      child: Icon(Icons.note_alt_outlined),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.grey[100],
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) => ref
                      .read(medicationFormProvider.notifier)
                      .setNotes(value),
                ),
                const SizedBox(height: 32),

                StepValidationIndicator(
                  isValid: formData.isStep1Valid,
                  validMessage: l10n.readyToContinue,
                  invalidMessage: l10n.pleaseSelectMedicineType,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MedicineTypeGrid extends ConsumerWidget {
  const _MedicineTypeGrid({required this.formData});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: MedicineType.values.map((type) {
        return MedicineTypeCard(
          type: type,
          isSelected: formData.medicineType == type,
          onTap: () =>
              ref.read(medicationFormProvider.notifier).setMedicineType(type),
        );
      }).toList(),
    );
  }
}
