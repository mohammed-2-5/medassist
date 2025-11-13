import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// Service for OCR (Optical Character Recognition) on medication labels
/// Extracts medication name, dosage, and other details from photos
class OCRService {
  factory OCRService() => _instance;
  OCRService._internal();
  static final OCRService _instance = OCRService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Capture photo from camera
  Future<File?> capturePhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      return null;
    }
  }

  /// Select photo from gallery
  Future<File?> selectPhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint('Error selecting photo: $e');
      return null;
    }
  }

  /// Extract text from image using Google ML Kit
  Future<String> extractText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText =
          await _textRecognizer.processImage(inputImage);

      return recognizedText.text;
    } catch (e) {
      debugPrint('Error extracting text: $e');
      return '';
    }
  }

  /// Scan medication label and extract structured information
  Future<MedicationScanResult> scanMedicationLabel(File imageFile) async {
    try {
      // Extract raw text
      final rawText = await extractText(imageFile);
      if (rawText.isEmpty) {
        return MedicationScanResult(
          success: false,
          errorMessage: 'No text found in image',
        );
      }

      debugPrint('OCR Raw Text:\n$rawText');

      // Parse the text to extract medication details
      final parsed = _parseMedicationInfo(rawText);

      return MedicationScanResult(
        success: true,
        rawText: rawText,
        medicationName: parsed['name'],
        strength: parsed['strength'],
        unit: parsed['unit'],
        dosageForm: parsed['form'],
        manufacturer: parsed['manufacturer'],
      );
    } catch (e) {
      debugPrint('Error scanning medication: $e');
      return MedicationScanResult(
        success: false,
        errorMessage: 'Failed to scan: $e',
      );
    }
  }

  /// Parse medication information from raw text
  /// Uses regex patterns to identify medication name, strength, dosage form, etc.
  Map<String, String?> _parseMedicationInfo(String text) {
    final result = <String, String?>{
      'name': null,
      'strength': null,
      'unit': null,
      'form': null,
      'manufacturer': null,
    };

    // Split text into lines for easier processing
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();

    // Patterns for medication details
    final strengthPattern = RegExp(
      r'(\d+\.?\d*)\s*(mg|mcg|g|ml|%|iu|units?)',
      caseSensitive: false,
    );
    final formPattern = RegExp(
      r'\b(tablet|capsule|syrup|injection|cream|ointment|drops|solution|suspension|gel|inhaler|patch)s?\b',
      caseSensitive: false,
    );

    // Common medication name indicators (usually first non-generic line)
    final excludeWords = [
      'rx',
      'only',
      'prescription',
      'pharmacist',
      'manufactured',
      'distributed',
      'batch',
      'lot',
      'exp',
      'mfg',
    ];

    // Extract medication name (usually the most prominent text)
    for (var i = 0; i < lines.length && result['name'] == null; i++) {
      final line = lines[i].trim();

      // Skip short lines or lines with excluded words
      if (line.length < 3 ||
          excludeWords.any((word) => line.toLowerCase().contains(word))) {
        continue;
      }

      // Check if line looks like a medication name
      // (Usually all caps or title case, no numbers except Roman numerals)
      if (RegExp(r'^[A-Z][A-Za-z\s\-]+$').hasMatch(line)) {
        result['name'] = _cleanMedicationName(line);
        break;
      }
    }

    // Extract strength and unit
    final strengthMatch = strengthPattern.firstMatch(text);
    if (strengthMatch != null) {
      result['strength'] = strengthMatch.group(1);
      result['unit'] = strengthMatch.group(2)?.toLowerCase();
    }

    // Extract dosage form
    final formMatch = formPattern.firstMatch(text.toLowerCase());
    if (formMatch != null) {
      result['form'] = _capitalizeDosageForm(formMatch.group(1)!);
    }

    // Extract manufacturer (usually has words like "manufactured by", "mfg by", etc.)
    final mfgPattern = RegExp(
      r'(?:manufactured|mfg|made)\s+(?:by|in)[\s:]+([A-Za-z\s&.,-]+)',
      caseSensitive: false,
    );
    final mfgMatch = mfgPattern.firstMatch(text);
    if (mfgMatch != null) {
      result['manufacturer'] = mfgMatch.group(1)?.trim();
    }

    return result;
  }

  /// Clean and format medication name
  String _cleanMedicationName(String name) {
    // Remove extra spaces
    name = name.trim().replaceAll(RegExp(r'\s+'), ' ');

    // Capitalize properly (title case)
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Capitalize dosage form properly
  String _capitalizeDosageForm(String form) {
    return form[0].toUpperCase() + form.substring(1).toLowerCase();
  }

  /// Get confidence level of OCR result (0.0 to 1.0)
  /// Based on how many fields were successfully extracted
  double getConfidenceLevel(MedicationScanResult result) {
    if (!result.success) return 0;

    var fieldsFound = 0;
    const totalFields = 5;

    if (result.medicationName != null && result.medicationName!.isNotEmpty) {
      fieldsFound++;
    }
    if (result.strength != null && result.strength!.isNotEmpty) {
      fieldsFound++;
    }
    if (result.unit != null && result.unit!.isNotEmpty) {
      fieldsFound++;
    }
    if (result.dosageForm != null && result.dosageForm!.isNotEmpty) {
      fieldsFound++;
    }
    if (result.manufacturer != null && result.manufacturer!.isNotEmpty) {
      fieldsFound++;
    }

    return fieldsFound / totalFields;
  }

  /// Dispose resources
  void dispose() {
    _textRecognizer.close();
  }
}

/// Result of medication label scanning
class MedicationScanResult {

  MedicationScanResult({
    required this.success,
    this.errorMessage,
    this.rawText,
    this.medicationName,
    this.strength,
    this.unit,
    this.dosageForm,
    this.manufacturer,
  });
  final bool success;
  final String? errorMessage;
  final String? rawText;
  final String? medicationName;
  final String? strength;
  final String? unit;
  final String? dosageForm;
  final String? manufacturer;

  @override
  String toString() {
    if (!success) {
      return 'Scan failed: $errorMessage';
    }

    return '''
Medication Scan Result:
  Name: $medicationName
  Strength: $strength $unit
  Form: $dosageForm
  Manufacturer: $manufacturer
''';
  }
}
