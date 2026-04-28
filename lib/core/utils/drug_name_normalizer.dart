/// Normalizes drug names, strengths, and units across English and Arabic
/// so duplicate detection and interaction matching work regardless of script.
class DrugNameNormalizer {
  const DrugNameNormalizer._();

  static final RegExp _tashkeel = RegExp(r'[\u064B-\u0652]');
  static final RegExp _whitespace = RegExp(r'\s+');
  static final RegExp _nonAlphaNum = RegExp(r'[^\p{L}\p{N} ]', unicode: true);
  static final RegExp _strengthSplit = RegExp(
    r'([0-9]+(?:[.,][0-9]+)?)\s*([^\s0-9]+)?',
  );

  /// Common Arabic brand/ingredient spellings → English canonical token.
  /// Covers top pharmacy items in Egypt/MENA region.
  static const Map<String, String> _arabicAliases = {
    'بنادول': 'panadol',
    'باندول': 'panadol',
    'باراسيتامول': 'paracetamol',
    'باراستيمول': 'paracetamol',
    'اسيتامينوفين': 'acetaminophen',
    'اكسترا': 'extra',
    'بروفين': 'brufen',
    'ايبوبروفين': 'ibuprofen',
    'ابوبروفين': 'ibuprofen',
    'اسبرين': 'aspirin',
    'اسبيرين': 'aspirin',
    'كتافلام': 'cataflam',
    'كاتفلام': 'cataflam',
    'كاتافلام': 'cataflam',
    'كتفلام': 'cataflam',
    'ديكلوفيناك': 'diclofenac',
    'ديكلوفيناك صوديوم': 'diclofenac',
    'فولتارين': 'voltaren',
    'فولتارن': 'voltaren',
    'ريلاكسون': 'relaxon',
    'كلورزوكسازون': 'chlorzoxazone',
    'مايوريل': 'myoril',
    'ثيوكولشيكوزيد': 'thiocolchicoside',
    'كونكور': 'concor',
    'بيسوبرولول': 'bisoprolol',
    'تينورمين': 'tenormin',
    'فيراباميل': 'verapamil',
    'ايزوبتين': 'isoptin',
    'نيفيلوب': 'nevilob',
    'نيفيلوب بلس': 'nevilob plus',
    'نيبيفولول': 'nebivolol',
    'اسبوسيد': 'aspocid',
    'سيبراليكس': 'cipralex',
    'اسيتالوبرام': 'escitalopram',
    'لازكس': 'lasix',
    'فيوروسيميد': 'furosemide',
    'اماريل': 'amaryl',
    'جليمبيريد': 'glimepiride',
    'مارفان': 'marevan',
    'اوجمنتين': 'augmentin',
    'اموكسيسيلين': 'amoxicillin',
    'اموكسيل': 'amoxil',
    'كلافولانيك': 'clavulanic',
    'سيبروفلوكساسين': 'ciprofloxacin',
    'سيبرو': 'cipro',
    'ازيثرومايسين': 'azithromycin',
    'زيثروماكس': 'zithromax',
    'كلاريثرومايسين': 'clarithromycin',
    'ميترونيدازول': 'metronidazole',
    'فلاجيل': 'flagyl',
    'ميتفورمين': 'metformin',
    'جلوكوفاج': 'glucophage',
    'انسولين': 'insulin',
    'ليسينوبريل': 'lisinopril',
    'لوسارتان': 'losartan',
    'اتينولول': 'atenolol',
    'املوديبين': 'amlodipine',
    'نورفاسك': 'norvasc',
    'اتورفاستاتين': 'atorvastatin',
    'ليبيتور': 'lipitor',
    'سيمفاستاتين': 'simvastatin',
    'وارفارين': 'warfarin',
    'هيبارين': 'heparin',
    'كلوبيدوجريل': 'clopidogrel',
    'بلافيكس': 'plavix',
    'ليفوثيروكسين': 'levothyroxine',
    'اوميبرازول': 'omeprazole',
    'اوميز': 'omez',
    'بانتوبرازول': 'pantoprazole',
    'رانيتيدين': 'ranitidine',
    'سيرترالين': 'sertraline',
    'فلوكستين': 'fluoxetine',
    'بروزاك': 'prozac',
    'ترامادول': 'tramadol',
    'ترامال': 'tramal',
    'كوديين': 'codeine',
    'مورفين': 'morphine',
    'ديجوكسين': 'digoxin',
    'ليثيوم': 'lithium',
    'ميثوتركسات': 'methotrexate',
    'بريدنيزون': 'prednisone',
    'كورتيزون': 'cortisone',
    'ديكساميثازون': 'dexamethasone',
    'كلاريتين': 'claritin',
    'لوراتادين': 'loratadine',
    'سيتريزين': 'cetirizine',
    'زيرتك': 'zyrtec',
    'فيتامين': 'vitamin',
    'كالسيوم': 'calcium',
    'حديد': 'iron',
    'زنك': 'zinc',
    'بوتاسيوم': 'potassium',
  };

  /// Arabic unit spellings → canonical English unit.
  static const Map<String, String> _unitAliases = {
    'ملغ': 'mg',
    'ملجم': 'mg',
    'مجم': 'mg',
    'ملليجرام': 'mg',
    'مليجرام': 'mg',
    'غرام': 'g',
    'جم': 'g',
    'جرام': 'g',
    'مل': 'ml',
    'ملليلتر': 'ml',
    'ميكروجرام': 'mcg',
    'ميكروغرام': 'mcg',
    'ميكروجم': 'mcg',
    'وحدة': 'iu',
    'وحده': 'iu',
    'وحدات': 'iu',
    'قرص': 'tab',
    'اقراص': 'tab',
    'كبسولة': 'cap',
    'كبسوله': 'cap',
    'كبسولات': 'cap',
    'نقطة': 'drop',
    'نقطه': 'drop',
    'نقط': 'drops',
    'ملعقة': 'tsp',
    'ملعقه': 'tsp',
    'mgs': 'mg',
    'milligram': 'mg',
    'milligrams': 'mg',
    'gram': 'g',
    'grams': 'g',
    'mcgs': 'mcg',
    'microgram': 'mcg',
    'micrograms': 'mcg',
    'units': 'iu',
    'unit': 'iu',
    'tablet': 'tab',
    'tablets': 'tab',
    'capsule': 'cap',
    'capsules': 'cap',
  };

  /// Egyptian/MENA brand names that the LLM doesn't reliably know — we
  /// translate them to their active ingredient before asking the AI, then
  /// keep the original brand on the medication record.
  static const Map<String, String> brandToIngredient = {
    'relaxon': 'chlorzoxazone',
    'myoril': 'thiocolchicoside',
    'aspocid': 'aspirin',
    'nevilob': 'nebivolol',
    'nevilob plus': 'nebivolol hydrochlorothiazide',
    'nevilop': 'nebivolol',
    'nevilop plus': 'nebivolol hydrochlorothiazide',
    'cataflam': 'diclofenac potassium',
    'voltaren': 'diclofenac sodium',
    'panadol': 'paracetamol',
    'panadol extra': 'paracetamol caffeine',
    'panadol night': 'paracetamol diphenhydramine',
    'brufen': 'ibuprofen',
    'concor': 'bisoprolol',
    'tenormin': 'atenolol',
    'isoptin': 'verapamil',
    'norvasc': 'amlodipine',
    'lipitor': 'atorvastatin',
    'plavix': 'clopidogrel',
    'tramal': 'tramadol',
    'prozac': 'fluoxetine',
    'cipralex': 'escitalopram',
    'zoloft': 'sertraline',
    'lasix': 'furosemide',
    'glucophage': 'metformin',
    'amaryl': 'glimepiride',
    'marevan': 'warfarin',
    'augmentin': 'amoxicillin clavulanate',
    'amoxil': 'amoxicillin',
    'cipro': 'ciprofloxacin',
    'zithromax': 'azithromycin',
    'flagyl': 'metronidazole',
    'omez': 'omeprazole',
    'claritin': 'loratadine',
    'zyrtec': 'cetirizine',
  };

  /// Returns the active ingredient for a known Egyptian brand, or null if
  /// the input doesn't match any registered brand.
  static String? activeIngredientForBrand(String brand) {
    final key = canonicalName(brand).toLowerCase();
    return brandToIngredient[key];
  }

  /// Normalize a name/brand field. Arabic tokens mapped to English canonical,
  /// diacritics stripped, punctuation removed, whitespace collapsed.
  static String canonicalName(String? value) {
    if (value == null) return '';
    final text = value
        .trim()
        .toLowerCase()
        .replaceAll(_tashkeel, '')
        .replaceAll(_nonAlphaNum, ' ')
        .replaceAll(_whitespace, ' ')
        .trim();
    if (text.isEmpty) return '';

    final tokens = text.split(' ').map((t) {
      final stripped = _stripArabicPrefix(t);
      return _arabicAliases[stripped] ??
          _arabicAliases[t] ??
          _unitAliases[t] ??
          t;
    }).toList();
    return tokens.join(' ').trim();
  }

  /// Normalize a strength: extract numeric + unit, canonicalize unit.
  /// "500 mg" == "500ملغ" == "500 MG".
  static String canonicalStrength(String? value) {
    if (value == null) return '';
    final text = value
        .trim()
        .toLowerCase()
        .replaceAll(_tashkeel, '')
        .replaceAll(_whitespace, ' ')
        .trim();
    if (text.isEmpty) return '';

    final match = _strengthSplit.firstMatch(text);
    if (match == null) {
      return canonicalUnit(text);
    }
    final num = match.group(1)!.replaceAll(',', '.');
    final unitRaw = (match.group(2) ?? '').trim();
    final unit = canonicalUnit(unitRaw);
    return unit.isEmpty ? num : '$num$unit';
  }

  /// Normalize a unit field alone.
  static String canonicalUnit(String? value) {
    if (value == null) return '';
    final text = value
        .trim()
        .toLowerCase()
        .replaceAll(_tashkeel, '')
        .replaceAll(_nonAlphaNum, '')
        .trim();
    if (text.isEmpty) return '';
    return _unitAliases[text] ?? text;
  }

  /// Extract numeric strength in mg equivalent for dose-aware interaction
  /// checks. Returns null if no numeric component or unit not convertible.
  static double? strengthInMg(String? value) {
    if (value == null) return null;
    final text = value
        .trim()
        .toLowerCase()
        .replaceAll(_tashkeel, '')
        .replaceAll(_whitespace, ' ');
    final match = _strengthSplit.firstMatch(text);
    if (match == null) return null;
    final rawNum = match.group(1)!.replaceAll(',', '.');
    final n = double.tryParse(rawNum);
    if (n == null) return null;
    final unit = canonicalUnit(match.group(2) ?? 'mg');
    switch (unit) {
      case 'mg':
        return n;
      case 'g':
        return n * 1000;
      case 'mcg':
        return n / 1000;
      default:
        return null;
    }
  }

  /// Strip common Arabic definite-article prefix "ال".
  static String _stripArabicPrefix(String token) {
    if (token.startsWith('ال') && token.length > 2) {
      return token.substring(2);
    }
    return token;
  }
}
