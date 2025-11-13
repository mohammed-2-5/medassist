import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/features/add_medication/screens/barcode_scanner_screen.dart';
import 'package:med_assist/features/add_medication/widgets/medicine_photo_picker.dart';
import 'package:med_assist/features/add_medication/widgets/medicine_type_card.dart';
import 'package:med_assist/features/add_medication/widgets/scan_medication_dialog.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/drug_database/models/drug_info.dart';
import 'package:med_assist/services/ocr/ocr_service.dart';
import 'package:med_assist/services/permissions/permissions_service.dart';

/// Step 1: Type & Info - Medicine basic information
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

  final List<String> _strengthUnits = [
    'mg',
    'g',
    'ml',
    'mcg',
    'IU',
    '%',
  ];

  String _selectedUnit = 'mg';

  // Image picker instance
  final ImagePicker _imagePicker = ImagePicker();
  final PermissionsService _permissionsService = PermissionsService();

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

    // Load existing data
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
    final colorScheme = theme.colorScheme;
    final formData = ref.watch(medicationFormProvider);

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
                // Header
                _buildHeader(theme),

                const SizedBox(height: 32),

                // Medicine Type Selection
                _buildSectionTitle(AppLocalizations.of(context)!.chooseMedicineType, theme),
                const SizedBox(height: 16),
                _buildMedicineTypeGrid(formData),

                const SizedBox(height: 32),

                // Scan Label Button
                _buildScanButton(theme, colorScheme),

                const SizedBox(height: 24),

                // Medicine Name
                _buildSectionTitle('${AppLocalizations.of(context)!.medicineName} *', theme),
                const SizedBox(height: 12),
                _buildNameInput(colorScheme, theme),

                const SizedBox(height: 24),

                // Medicine Photo
                _buildSectionTitle(AppLocalizations.of(context)!.medicinePhoto, theme, isOptional: true),
                const SizedBox(height: 12),
                _buildPhotoSection(formData),

                const SizedBox(height: 24),

                // Strength & Unit
                _buildSectionTitle(AppLocalizations.of(context)!.strengthAndUnit, theme, isOptional: true),
                const SizedBox(height: 12),
                _buildStrengthSection(colorScheme, theme),

                const SizedBox(height: 24),

                // Notes
                _buildSectionTitle(AppLocalizations.of(context)!.notes, theme, isOptional: true),
                const SizedBox(height: 12),
                _buildNotesInput(colorScheme, theme),

                const SizedBox(height: 32),

                // Validation indicator
                _buildValidationIndicator(formData, theme, colorScheme),

                const SizedBox(height: 100), // Bottom padding for FAB
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.step1Of3,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.basicInformation,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.tellUsAboutMedicine,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    ThemeData theme, {
    bool isOptional = false,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isOptional) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              AppLocalizations.of(context)!.optional,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMedicineTypeGrid(MedicationFormData formData) {
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
          onTap: () {
            ref.read(medicationFormProvider.notifier).setMedicineType(type);
          },
        );
      }).toList(),
    );
  }

  Widget _buildNameInput(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'e.g., Aspirin, Paracetamol',
              prefixIcon: Icon(Icons.medication, color: colorScheme.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppLocalizations.of(context)!.pleaseEnterMedicineName;
              }
              return null;
            },
            onChanged: (value) {
              ref.read(medicationFormProvider.notifier).setMedicineName(value);
            },
          ),

          // Action buttons row
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _scanMedicineName,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt,
                              size: 20, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Scan Name',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: colorScheme.outlineVariant,
                ),
                Expanded(
                  child: InkWell(
                    onTap: _scanBarcode,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner,
                              size: 20, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Scan Barcode',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(MedicationFormData formData) {
    return MedicinePhotoPicker(
      photoPath: formData.medicinePhotoPath,
      onTakePhoto: _takePhoto,
      onPickFromGallery: _pickFromGallery,
      onRemovePhoto: _removePhoto,
    );
  }

  Widget _buildStrengthSection(ColorScheme colorScheme, ThemeData theme) {
    return Row(
      children: [
        // Strength input
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _strengthController,
            decoration: InputDecoration(
              hintText: 'e.g., 100',
              prefixIcon: const Icon(Icons.science_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? Colors.grey[850]
                  : Colors.grey[100],
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              ref.read(medicationFormProvider.notifier).setStrength(value);
            },
          ),
        ),

        const SizedBox(width: 12),

        // Unit dropdown
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _selectedUnit,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? Colors.grey[850]
                  : Colors.grey[100],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: _strengthUnits.map((unit) {
              return DropdownMenuItem(
                value: unit,
                child: Text(unit),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedUnit = value);
                ref.read(medicationFormProvider.notifier).setUnit(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotesInput(ColorScheme colorScheme, ThemeData theme) {
    return TextFormField(
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
      onChanged: (value) {
        ref.read(medicationFormProvider.notifier).setNotes(value);
      },
    );
  }

  Widget _buildValidationIndicator(
    MedicationFormData formData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isValid = formData.isStep1Valid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isValid
            ? colorScheme.secondaryContainer.withOpacity(0.5)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid
              ? colorScheme.secondary
              : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.info_outline,
            color: isValid ? colorScheme.secondary : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isValid
                  ? AppLocalizations.of(context)!.readyToContinue
                  : AppLocalizations.of(context)!.pleaseSelectMedicineType,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isValid
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: isValid ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Action handlers
  Future<void> _scanMedicineName() async {
    // Show scan dialog
    final result = await showDialog<MedicationScanResult>(
      context: context,
      builder: (context) => const ScanMedicationDialog(),
    );

    if (result == null || !result.success || !mounted) return;

    // Populate form fields with scan results
    if (result.medicationName != null && result.medicationName!.isNotEmpty) {
      _nameController.text = result.medicationName!;
      ref.read(medicationFormProvider.notifier).setMedicineName(result.medicationName!);
    }

    if (result.strength != null && result.strength!.isNotEmpty) {
      _strengthController.text = result.strength!;
      ref.read(medicationFormProvider.notifier).setStrength(result.strength!);
    }

    if (result.unit != null && result.unit!.isNotEmpty) {
      setState(() => _selectedUnit = result.unit!);
      ref.read(medicationFormProvider.notifier).setUnit(result.unit!);
    }

    // Detect medicine type from dosage form if available
    if (result.dosageForm != null) {
      final detectedType = _detectMedicineType(result.dosageForm!);
      if (detectedType != null) {
        ref.read(medicationFormProvider.notifier).setMedicineType(detectedType);
      }
    }

    // Mark as scanned
    ref.read(medicationFormProvider.notifier).setIsScanned(true);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scanned: ${result.medicationName ?? "Unknown"}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  MedicineType? _detectMedicineType(String dosageForm) {
    final form = dosageForm.toLowerCase();
    if (form.contains('tablet') || form.contains('pill') || form.contains('capsule')) {
      return MedicineType.pill;
    } else if (form.contains('syrup') || form.contains('liquid') || form.contains('solution')) {
      return MedicineType.syrup;
    } else if (form.contains('injection') || form.contains('syringe')) {
      return MedicineType.injection;
    } else if (form.contains('drop')) {
      return MedicineType.drops;
    } else if (form.contains('suppository')) {
      return MedicineType.suppository;
    } else if (form.contains('iv') || form.contains('intravenous') || form.contains('drip')) {
      return MedicineType.ivSolution;
    }
    // Cream, ointment, gel, etc. - no matching type, return null
    return null;
  }

  Widget _buildScanButton(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _scanMedicineName,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
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
                        'Scan Medication Label',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Auto-fill details from photo',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _scanBarcode() async {
    try {
      // Check and request camera permission
      final hasPermission = await _permissionsService.isCameraGranted();

      if (!hasPermission) {
        final granted = await _permissionsService.requestCameraPermission();

        if (!granted) {
          if (!mounted) return;

          await _permissionsService.showPermissionDeniedDialog(
            context,
            title: 'Camera Permission Required',
            message:
                'Camera access is needed to scan medication barcodes. '
                'Please grant permission in Settings.',
          );
          return;
        }
      }

      if (!mounted) return;

      // Open barcode scanner
      final result = await Navigator.push<dynamic>(
        context,
        MaterialPageRoute(
          builder: (context) => const BarcodeScannerScreen(),
        ),
      );

      if (result == null || !mounted) return;

      // Handle result
      if (result is DrugInfo) {
        // Auto-fill form with drug information
        _nameController.text = result.displayName;

        // Update medicine type
        // Convert string medicine type to enum
        MedicineType medicineTypeEnum;
        switch (result.medicineType.toLowerCase()) {
          case 'injection':
            medicineTypeEnum = MedicineType.injection;
          case 'syrup':
          case 'solution':
          case 'suspension':
            medicineTypeEnum = MedicineType.syrup;
          case 'suppository':
            medicineTypeEnum = MedicineType.suppository;
          case 'inhaler':
          case 'drops':
            medicineTypeEnum = MedicineType.drops;
          case 'cream':
          case 'ointment':
          case 'gel':
          case 'tablet':
          case 'capsule':
          default:
            medicineTypeEnum = MedicineType.pill;
        }
        ref.read(medicationFormProvider.notifier).setMedicineType(
              medicineTypeEnum,
            );

        // Set strength if available
        if (result.strength != null && result.strength!.isNotEmpty) {
          // Try to parse strength (e.g., "500mg" -> "500" and "mg")
          final strengthMatch =
              RegExp(r'(\d+\.?\d*)\s*([a-zA-Z]+)').firstMatch(result.strength!);

          if (strengthMatch != null) {
            _strengthController.text = strengthMatch.group(1)!;
            final unit = strengthMatch.group(2)!.toLowerCase();

            // Find matching unit or use mg as default
            if (_strengthUnits.contains(unit)) {
              setState(() {
                _selectedUnit = unit;
              });
            }
          } else {
            _strengthController.text = result.strength!;
          }
        }

        // Add manufacturer info to notes if available
        if (result.manufacturer != null) {
          final currentNotes = _notesController.text;
          final manufacturerNote = 'Manufacturer: ${result.manufacturer}';

          _notesController.text = currentNotes.isEmpty
              ? manufacturerNote
              : '$currentNotes\n\n$manufacturerNote';
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Medication found: ${result.displayName}'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else if (result is String) {
        // Barcode scanned but no drug found
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Scanned code: $result\nPlease enter details manually'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning barcode: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      // Check and request camera permission
      final hasPermission = await _permissionsService.isCameraGranted();

      if (!hasPermission) {
        final granted = await _permissionsService.requestCameraPermission();

        if (!granted) {
          if (!mounted) return;

          // Show dialog to explain why we need permission
          await _permissionsService.showPermissionDeniedDialog(
            context,
            title: 'Camera Permission Required',
            message:
                'Camera access is needed to take photos of your medications. '
                'Please grant permission in Settings.',
          );
          return;
        }
      }

      // Capture photo from camera
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        // Save photo path to form data
        ref.read(medicationFormProvider.notifier).setMedicinePhoto(photo.path);

        if (!mounted) return;

        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Photo captured successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Failed to capture photo: $e'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      // Check and request storage/photos permission
      final hasPermission = await _permissionsService.isStorageGranted();

      if (!hasPermission) {
        final granted = await _permissionsService.requestStoragePermission();

        if (!granted) {
          if (!mounted) return;

          // Show dialog to explain why we need permission
          await _permissionsService.showPermissionDeniedDialog(
            context,
            title: 'Photos Permission Required',
            message:
                'Photos access is needed to select medication images from your gallery. '
                'Please grant permission in Settings.',
          );
          return;
        }
      }

      // Pick image from gallery
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // Save photo path to form data
        ref.read(medicationFormProvider.notifier).setMedicinePhoto(image.path);

        if (!mounted) return;

        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Photo selected successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking from gallery: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Failed to pick photo: $e'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _removePhoto() {
    ref.read(medicationFormProvider.notifier).setMedicinePhoto(null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(width: 12),
            Text('Photo removed'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
