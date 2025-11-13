import 'package:dio/dio.dart';
import 'package:med_assist/services/drug_database/models/drug_info.dart';

/// Service for interacting with OpenFDA Drug Database API
/// https://open.fda.gov/apis/drug/
class OpenFdaService {

  OpenFdaService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ));
  final Dio _dio;
  static const String _baseUrl = 'https://api.fda.gov/drug';

  /// Search drug by NDC (National Drug Code) from barcode
  /// NDC codes are typically 10 or 11 digits
  Future<DrugInfo?> searchByNdc(String ndc) async {
    try {
      // Clean NDC code (remove dashes, spaces)
      final cleanNdc = ndc.replaceAll(RegExp('[^0-9]'), '');

      // Try different NDC formats (10-digit, 11-digit)
      final ndcFormats = _generateNdcFormats(cleanNdc);

      for (final formattedNdc in ndcFormats) {
        try {
          final result = await _searchNdcFormat(formattedNdc);
          if (result != null) return result;
        } catch (_) {
          // Try next format
          continue;
        }
      }

      return null;
    } catch (e) {
      throw DrugLookupException('Failed to search drug by NDC: $e');
    }
  }

  /// Search drug by name
  Future<List<DrugInfo>> searchByName(String name) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/label.json',
        queryParameters: {
          'search': 'openfda.brand_name:"$name"+openfda.generic_name:"$name"',
          'limit': 10,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;

        if (results == null || results.isEmpty) return [];

        return results
            .map((json) => DrugInfo.fromOpenFdaJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      throw DrugLookupException('Failed to search drug by name: $e');
    }
  }

  /// Search by UPC/barcode
  Future<DrugInfo?> searchByBarcode(String barcode) async {
    try {
      // First try as NDC
      final result = await searchByNdc(barcode);
      if (result != null) return result;

      // If not found, barcode might be UPC - try different approaches
      // UPC codes don't directly map to NDC, so this might fail
      return null;
    } catch (e) {
      throw DrugLookupException('Failed to search drug by barcode: $e');
    }
  }

  /// Internal method to search with specific NDC format
  Future<DrugInfo?> _searchNdcFormat(String ndc) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/label.json',
        queryParameters: {
          'search': 'openfda.product_ndc:"$ndc"',
          'limit': 1,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;

        if (results != null && results.isNotEmpty) {
          return DrugInfo.fromOpenFdaJson(results.first as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Generate different NDC formats for searching
  /// NDC codes can be 10 or 11 digits with various dash formats
  List<String> _generateNdcFormats(String ndc) {
    final formats = <String>[ndc];

    // 10-digit NDC formats: 4-4-2, 5-3-2, 5-4-1
    if (ndc.length == 10) {
      formats.addAll([
        '${ndc.substring(0, 4)}-${ndc.substring(4, 8)}-${ndc.substring(8)}', // 4-4-2
        '${ndc.substring(0, 5)}-${ndc.substring(5, 8)}-${ndc.substring(8)}', // 5-3-2
        '${ndc.substring(0, 5)}-${ndc.substring(5, 9)}-${ndc.substring(9)}', // 5-4-1
      ]);
    }

    // 11-digit NDC formats: 5-4-2
    if (ndc.length == 11) {
      formats.add(
        '${ndc.substring(0, 5)}-${ndc.substring(5, 9)}-${ndc.substring(9)}',
      );
    }

    // Pad to 11 digits if needed
    if (ndc.length < 11) {
      final paddedNdc = ndc.padLeft(11, '0');
      formats.add(paddedNdc);
      formats.add(
        '${paddedNdc.substring(0, 5)}-${paddedNdc.substring(5, 9)}-${paddedNdc.substring(9)}',
      );
    }

    return formats;
  }
}

/// Exception thrown when drug lookup fails
class DrugLookupException implements Exception {

  DrugLookupException(this.message);
  final String message;

  @override
  String toString() => 'DrugLookupException: $message';
}
