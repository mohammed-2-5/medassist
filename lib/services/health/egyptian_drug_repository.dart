import 'dart:async';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/utils/drug_name_normalizer.dart';

/// Local catalog of Egyptian-market drugs. Backed by the raw-SQL
/// `egyptian_drugs` table. Source CSV is bundled at
/// assets/data/egypt_drugs.csv and imported once on first launch.
///
/// Used by the AI service to translate brand names to active ingredients
/// before any AI call (LLMs don't reliably know Egyptian brands), and by
/// the interaction checker to enrich brand → ingredient lookups.
class EgyptianDrugRepository {
  EgyptianDrugRepository(this._db);

  final AppDatabase _db;

  static const String _csvAsset = 'assets/data/egypt_drugs.csv';

  /// Imports the bundled CSV into the local DB if not already done. Safe to
  /// call on every launch — bails out if the table already has rows. Runs
  /// asynchronously; errors are logged and swallowed so an import failure
  /// never breaks app startup.
  Future<void> ensureImported() async {
    try {
      final existing = await _db
          .customSelect('SELECT COUNT(*) AS c FROM egyptian_drugs')
          .getSingle();
      final count = existing.read<int>('c');
      if (count > 0) {
        debugPrint('EgyptianDrugRepository: already imported ($count rows)');
        return;
      }

      debugPrint('EgyptianDrugRepository: starting CSV import...');
      final stopwatch = Stopwatch()..start();

      final raw = await rootBundle.loadString(_csvAsset);
      final rows = const CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(raw);

      if (rows.length < 2) {
        debugPrint('EgyptianDrugRepository: CSV empty or malformed');
        return;
      }

      final header = rows.first.map((c) => c.toString().toLowerCase()).toList();
      final iIngredient = header.indexOf('activeingredient');
      final iCompany = header.indexOf('company');
      final iForm = header.indexOf('form');
      final iGroup = header.indexOf('group');
      final iPharma = header.indexOf('pharmacology');
      final iRoute = header.indexOf('route');
      final iTrade = header.indexOf('tradename');

      if (iTrade < 0) {
        debugPrint('EgyptianDrugRepository: tradename column missing');
        return;
      }

      const batchSize = 500;
      var inserted = 0;
      for (var i = 1; i < rows.length; i += batchSize) {
        final end = (i + batchSize > rows.length) ? rows.length : i + batchSize;
        final batch = rows.sublist(i, end);
        await _db.batch((b) {
          for (final row in batch) {
            final trade = _safe(row, iTrade);
            if (trade.isEmpty) continue;
            final ingredient = _safe(row, iIngredient);
            b.customStatement(
              'INSERT INTO egyptian_drugs '
              '(trade_name, normalized_trade_name, active_ingredient, '
              'normalized_ingredient, drug_category, form, route, '
              'manufacturer, pharmacology) '
              'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
              [
                trade,
                DrugNameNormalizer.canonicalName(trade),
                ingredient.isEmpty ? null : ingredient,
                ingredient.isEmpty
                    ? null
                    : DrugNameNormalizer.canonicalName(ingredient),
                _safe(row, iGroup).isEmpty ? null : _safe(row, iGroup),
                _safe(row, iForm).isEmpty ? null : _safe(row, iForm),
                _safe(row, iRoute).isEmpty ? null : _safe(row, iRoute),
                _safe(row, iCompany).isEmpty ? null : _safe(row, iCompany),
                _safe(row, iPharma).isEmpty ? null : _safe(row, iPharma),
              ],
            );
            inserted++;
          }
        });
      }

      stopwatch.stop();
      debugPrint(
        'EgyptianDrugRepository: imported $inserted rows in '
        '${stopwatch.elapsedMilliseconds}ms',
      );
    } on Object catch (e, st) {
      debugPrint('EgyptianDrugRepository: import failed: $e\n$st');
    }
  }

  String _safe(List<dynamic> row, int idx) {
    if (idx < 0 || idx >= row.length) return '';
    return row[idx].toString().trim();
  }

  /// Look up a drug by brand name. Tries normalized exact match, then
  /// substring match (handles "Cataflam 50mg" vs "cataflam"). Returns the
  /// first row scoring best (shortest tradename → most likely the brand
  /// itself rather than a specific SKU).
  Future<EgyptianDrugRecord?> findByBrand(String name) async {
    final normalized = DrugNameNormalizer.canonicalName(name);
    if (normalized.isEmpty) return null;

    // 1. Exact match on normalized trade name.
    final exact = await _db
        .customSelect(
          'SELECT * FROM egyptian_drugs '
          'WHERE normalized_trade_name = ? '
          'ORDER BY LENGTH(trade_name) ASC LIMIT 1',
          variables: [Variable.withString(normalized)],
        )
        .get();
    if (exact.isNotEmpty) return _rowToRecord(exact.first);

    // 2. Substring (the user's input is contained in the row, e.g. "panadol"
    //    matches "panadol extra 500mg").
    final like = await _db
        .customSelect(
          'SELECT * FROM egyptian_drugs '
          'WHERE normalized_trade_name LIKE ? '
          'ORDER BY LENGTH(trade_name) ASC LIMIT 1',
          variables: [Variable.withString('%$normalized%')],
        )
        .get();
    if (like.isNotEmpty) return _rowToRecord(like.first);

    // 3. Reverse — the row name is contained in the user's input, e.g. user
    //    typed "Concor Plus 5mg" but only "concor" exists alone.
    final firstWord = normalized.split(' ').first;
    if (firstWord.isNotEmpty && firstWord != normalized) {
      final partial = await _db
          .customSelect(
            'SELECT * FROM egyptian_drugs '
            'WHERE normalized_trade_name = ? OR normalized_trade_name LIKE ? '
            'ORDER BY LENGTH(trade_name) ASC LIMIT 1',
            variables: [
              Variable.withString(firstWord),
              Variable.withString('$firstWord %'),
            ],
          )
          .get();
      if (partial.isNotEmpty) return _rowToRecord(partial.first);
    }

    return null;
  }

  /// All distinct brand names for a given active ingredient. Useful for
  /// "alternative brands" suggestions.
  Future<List<String>> brandsForIngredient(String ingredient) async {
    final normalized = DrugNameNormalizer.canonicalName(ingredient);
    if (normalized.isEmpty) return const [];
    final rows = await _db
        .customSelect(
          'SELECT DISTINCT trade_name FROM egyptian_drugs '
          'WHERE normalized_ingredient = ? OR normalized_ingredient LIKE ? '
          'LIMIT 20',
          variables: [
            Variable.withString(normalized),
            Variable.withString('%$normalized%'),
          ],
        )
        .get();
    return rows.map((r) => r.read<String>('trade_name')).toList();
  }

  EgyptianDrugRecord _rowToRecord(QueryRow row) {
    return EgyptianDrugRecord(
      tradeName: row.read<String>('trade_name'),
      activeIngredient: row.readNullable<String>('active_ingredient'),
      drugCategory: row.readNullable<String>('drug_category'),
      form: row.readNullable<String>('form'),
      route: row.readNullable<String>('route'),
      manufacturer: row.readNullable<String>('manufacturer'),
      pharmacology: row.readNullable<String>('pharmacology'),
    );
  }
}

class EgyptianDrugRecord {
  const EgyptianDrugRecord({
    required this.tradeName,
    this.activeIngredient,
    this.drugCategory,
    this.form,
    this.route,
    this.manufacturer,
    this.pharmacology,
  });

  final String tradeName;
  final String? activeIngredient;
  final String? drugCategory;
  final String? form;
  final String? route;
  final String? manufacturer;
  final String? pharmacology;

  /// The first ingredient when there are multiple combined with `+`. Useful
  /// to match against single-ingredient interaction tables.
  String? get primaryIngredient {
    if (activeIngredient == null || activeIngredient!.isEmpty) return null;
    return activeIngredient!.split('+').first.trim();
  }
}
