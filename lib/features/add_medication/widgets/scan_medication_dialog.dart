import 'dart:io';
import 'package:flutter/material.dart';
import 'package:med_assist/features/add_medication/widgets/scan_medication_header.dart';
import 'package:med_assist/features/add_medication/widgets/scan_medication_image_preview.dart';
import 'package:med_assist/features/add_medication/widgets/scan_medication_options_view.dart';
import 'package:med_assist/features/add_medication/widgets/scan_medication_processing_view.dart';
import 'package:med_assist/features/add_medication/widgets/scan_medication_results_view.dart';
import 'package:med_assist/services/ocr/ocr_service.dart';

/// Dialog for scanning medication labels using camera or gallery
class ScanMedicationDialog extends StatefulWidget {
  const ScanMedicationDialog({super.key});

  @override
  State<ScanMedicationDialog> createState() => _ScanMedicationDialogState();
}

class _ScanMedicationDialogState extends State<ScanMedicationDialog> {
  final OCRService _ocrService = OCRService();
  bool _isProcessing = false;
  File? _selectedImage;
  MedicationScanResult? _scanResult;

  Future<void> _captureFromCamera() async {
    try {
      final image = await _ocrService.capturePhoto();
      if (image == null || !mounted) return;

      setState(() {
        _selectedImage = image;
        _isProcessing = true;
      });

      // Process OCR
      final result = await _ocrService.scanMedicationLabel(image);

      if (!mounted) return;

      setState(() {
        _scanResult = result;
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      _showError('Failed to capture photo: $e');
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final image = await _ocrService.selectPhoto();
      if (image == null || !mounted) return;

      setState(() {
        _selectedImage = image;
        _isProcessing = true;
      });

      // Process OCR
      final result = await _ocrService.scanMedicationLabel(image);

      if (!mounted) return;

      setState(() {
        _scanResult = result;
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      _showError('Failed to select photo: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _useResults() {
    if (_scanResult == null || !_scanResult!.success) return;

    // Return the scan result to caller
    Navigator.of(context).pop(_scanResult);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ScanMedicationHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isProcessing) {
      return const ScanMedicationProcessingView();
    }

    if (_scanResult != null) {
      return ScanMedicationResultsView(
        scanResult: _scanResult!,
        confidence: _ocrService.getConfidenceLevel(_scanResult!),
        onScanAgain: _resetScan,
        onUseDetails: _useResults,
      );
    }

    if (_selectedImage != null) {
      return ScanMedicationImagePreview(
        selectedImage: _selectedImage!,
        onRetake: _resetScan,
        onScan: _scanSelectedImage,
      );
    }

    return ScanMedicationOptionsView(
      onCaptureFromCamera: _captureFromCamera,
      onSelectFromGallery: _selectFromGallery,
    );
  }

  Future<void> _scanSelectedImage() async {
    if (_selectedImage == null) return;
    setState(() => _isProcessing = true);
    final result = await _ocrService.scanMedicationLabel(_selectedImage!);
    if (mounted) {
      setState(() {
        _scanResult = result;
        _isProcessing = false;
      });
    }
  }

  void _resetScan() {
    setState(() {
      _selectedImage = null;
      _scanResult = null;
      _isProcessing = false;
    });
  }
}
