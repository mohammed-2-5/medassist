import 'dart:io';
import 'package:flutter/material.dart';
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
        _isProcessing = false;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.document_scanner,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Scan Medication Label',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _buildContent(colorScheme, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme, ThemeData theme) {
    if (_isProcessing) {
      return _buildProcessing();
    }

    if (_scanResult != null) {
      return _buildResults(colorScheme, theme);
    }

    if (_selectedImage != null) {
      return _buildImagePreview(colorScheme);
    }

    return _buildOptions(colorScheme, theme);
  }

  Widget _buildProcessing() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Scanning medication label...'),
          SizedBox(height: 8),
          Text(
            'This may take a few seconds',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(ColorScheme colorScheme, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 80,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Scan a medication label to automatically extract details',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),

          // Camera button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _captureFromCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Gallery button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _selectFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose from Gallery'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tips for best results:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTip('Ensure good lighting'),
                _buildTip('Focus on the label'),
                _buildTip('Keep the camera steady'),
                _buildTip('Avoid glare and shadows'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildImagePreview(ColorScheme colorScheme) {
    return Column(
      children: [
        Expanded(
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.contain,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                      _scanResult = null;
                    });
                  },
                  child: const Text('Retake'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    setState(() => _isProcessing = true);
                    final result = await _ocrService.scanMedicationLabel(_selectedImage!);
                    if (mounted) {
                      setState(() {
                        _scanResult = result;
                        _isProcessing = false;
                      });
                    }
                  },
                  child: const Text('Scan'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResults(ColorScheme colorScheme, ThemeData theme) {
    if (!_scanResult!.success) {
      return _buildError(colorScheme, theme);
    }

    final confidence = _ocrService.getConfidenceLevel(_scanResult!);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Confidence indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getConfidenceColor(confidence).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getConfidenceColor(confidence),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getConfidenceIcon(confidence),
                  color: _getConfidenceColor(confidence),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getConfidenceText(confidence),
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: confidence,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(_getConfidenceColor(confidence)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Extracted information
          Text('Extracted Information:', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          _buildResultField('Medication Name', _scanResult!.medicationName, Icons.medication),
          _buildResultField('Strength', '${_scanResult!.strength ?? ''} ${_scanResult!.unit ?? ''}'.trim(), Icons.science),
          _buildResultField('Dosage Form', _scanResult!.dosageForm, Icons.category),
          _buildResultField('Manufacturer', _scanResult!.manufacturer, Icons.business),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                      _scanResult = null;
                    });
                  },
                  child: const Text('Scan Again'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _useResults,
                  child: const Text('Use Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError(ColorScheme colorScheme, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Scan Failed',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _scanResult!.errorMessage ?? 'Unable to extract medication details',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              setState(() {
                _selectedImage = null;
                _scanResult = null;
              });
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultField(String label, String? value, IconData icon) {
    final hasValue = value != null && value.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: hasValue ? Colors.green : Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasValue ? value : 'Not found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal,
                    color: hasValue ? null : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.7) return Colors.green;
    if (confidence >= 0.4) return Colors.orange;
    return Colors.red;
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 0.7) return Icons.check_circle;
    if (confidence >= 0.4) return Icons.warning;
    return Icons.error;
  }

  String _getConfidenceText(double confidence) {
    if (confidence >= 0.7) return 'High Confidence';
    if (confidence >= 0.4) return 'Medium Confidence - Please verify';
    return 'Low Confidence - Manual entry recommended';
  }
}
