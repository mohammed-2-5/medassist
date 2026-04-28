import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/features/add_medication/widgets/scan_medication_dialog.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/ocr/ocr_service.dart';
import 'package:med_assist/services/permissions/permissions_service.dart';

class Step1Actions {
  Step1Actions._();

  static final _imagePicker = ImagePicker();
  static final _permissionsService = PermissionsService();

  static Future<void> scanMedicineName({
    required BuildContext context,
    required WidgetRef ref,
    required TextEditingController nameController,
    required TextEditingController strengthController,
    required ValueChanged<String> onUnitChanged,
  }) async {
    final result = await showDialog<MedicationScanResult>(
      context: context,
      builder: (context) => const ScanMedicationDialog(),
    );

    if (result == null || !result.success || !context.mounted) return;

    if (result.medicationName != null && result.medicationName!.isNotEmpty) {
      nameController.text = result.medicationName!;
      ref
          .read(medicationFormProvider.notifier)
          .setMedicineName(result.medicationName!);
    }

    if (result.strength != null && result.strength!.isNotEmpty) {
      strengthController.text = result.strength!;
      ref.read(medicationFormProvider.notifier).setStrength(result.strength!);
    }

    if (result.unit != null && result.unit!.isNotEmpty) {
      onUnitChanged(result.unit!);
      ref.read(medicationFormProvider.notifier).setUnit(result.unit!);
    }

    if (result.dosageForm != null) {
      final detectedType = _detectMedicineType(result.dosageForm!);
      if (detectedType != null) {
        ref.read(medicationFormProvider.notifier).setMedicineType(detectedType);
      }
    }

    ref.read(medicationFormProvider.notifier).setIsScanned(true);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.scannedMedication(
            result.medicationName ?? AppLocalizations.of(context)!.unknown,
          ),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static Future<void> takePhoto({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      final hasPermission = await _permissionsService.isCameraGranted();
      if (!hasPermission) {
        final granted = await _permissionsService.requestCameraPermission();
        if (!granted) {
          if (!context.mounted) return;
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

      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        ref.read(medicationFormProvider.notifier).setMedicinePhoto(photo.path);

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.photoCapturedSuccess),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(
                    context,
                  )!.failedToCapturePhoto(e.toString()),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  static Future<void> pickFromGallery({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      final hasPermission = await _permissionsService.isStorageGranted();
      if (!hasPermission) {
        final granted = await _permissionsService.requestStoragePermission();
        if (!granted) {
          if (!context.mounted) return;
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

      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        ref.read(medicationFormProvider.notifier).setMedicinePhoto(image.path);

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.photoSelectedSuccess),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.failedToPickPhoto(e.toString()),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  static void removePhoto({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    ref.read(medicationFormProvider.notifier).clearMedicinePhoto();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete, color: Colors.white),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.photoRemovedSuccess),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static MedicineType? _detectMedicineType(String dosageForm) {
    final form = dosageForm.toLowerCase();
    if (form.contains('tablet') ||
        form.contains('pill') ||
        form.contains('capsule')) {
      return MedicineType.pill;
    } else if (form.contains('syrup') ||
        form.contains('liquid') ||
        form.contains('solution')) {
      return MedicineType.syrup;
    } else if (form.contains('injection') || form.contains('syringe')) {
      return MedicineType.injection;
    } else if (form.contains('drop')) {
      return MedicineType.drops;
    } else if (form.contains('suppository')) {
      return MedicineType.suppository;
    } else if (form.contains('iv') ||
        form.contains('intravenous') ||
        form.contains('drip')) {
      return MedicineType.ivSolution;
    }
    return null;
  }
}
