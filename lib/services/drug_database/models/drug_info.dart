/// Model for drug information from OpenFDA API
class DrugInfo {

  DrugInfo({
    this.brandName,
    this.genericName,
    this.manufacturer,
    this.dosageForm,
    this.route,
    this.strength,
    this.productNdc,
    this.substanceName,
    this.activeIngredients,
    this.purpose,
    this.warnings,
    this.dosageAndAdministration,
  });

  /// Create DrugInfo from OpenFDA API JSON response
  factory DrugInfo.fromOpenFdaJson(Map<String, dynamic> json) {
    final openfda = json['openfda'] as Map<String, dynamic>?;

    // Helper to get first item from list or null
    String? getFirst(dynamic value) {
      if (value == null) return null;
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }
      return value.toString();
    }

    // Helper to get all items from list
    List<String>? getList(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [value.toString()];
    }

    return DrugInfo(
      brandName: getFirst(openfda?['brand_name']),
      genericName: getFirst(openfda?['generic_name']),
      manufacturer: getFirst(openfda?['manufacturer_name']),
      dosageForm: getFirst(openfda?['dosage_form']),
      route: getFirst(openfda?['route']),
      strength: getFirst(json['active_ingredient_text']),
      productNdc: getFirst(openfda?['product_ndc']),
      substanceName: getFirst(openfda?['substance_name']),
      activeIngredients: getList(openfda?['substance_name']),
      purpose: getFirst(json['purpose']),
      warnings: getFirst(json['warnings']),
      dosageAndAdministration: getFirst(json['dosage_and_administration']),
    );
  }
  final String? brandName;
  final String? genericName;
  final String? manufacturer;
  final String? dosageForm;
  final String? route;
  final String? strength;
  final String? productNdc;
  final String? substanceName;
  final List<String>? activeIngredients;
  final String? purpose;
  final String? warnings;
  final String? dosageAndAdministration;

  /// Get display name (brand name or generic name)
  String get displayName => brandName ?? genericName ?? 'Unknown Medication';

  /// Get medicine type based on dosage form
  String get medicineType {
    if (dosageForm == null) return 'Tablet';

    final form = dosageForm!.toLowerCase();
    if (form.contains('tablet')) return 'Tablet';
    if (form.contains('capsule')) return 'Capsule';
    if (form.contains('syrup') || form.contains('solution') || form.contains('suspension')) {
      return 'Syrup';
    }
    if (form.contains('injection') || form.contains('injectable')) return 'Injection';
    if (form.contains('cream') || form.contains('ointment') || form.contains('gel')) {
      return 'Cream';
    }
    if (form.contains('inhaler') || form.contains('aerosol')) return 'Inhaler';

    return 'Tablet'; // Default
  }

  /// Check if drug info is valid
  bool get isValid => brandName != null || genericName != null;

  @override
  String toString() {
    return 'DrugInfo(brandName: $brandName, genericName: $genericName, '
        'manufacturer: $manufacturer, dosageForm: $dosageForm)';
  }
}
