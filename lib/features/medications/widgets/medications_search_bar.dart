import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/widgets/enhanced_search_bar.dart';
import 'package:med_assist/features/medications/providers/medications_filter_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Premium Search Bar for Medications List
///
/// Features:
/// - Gradient background
/// - Theme-colored border and icons
/// - Adaptive dark/light mode colors
/// - Smooth animations
/// - 500ms debounce on search input
class MedicationsSearchBar extends ConsumerStatefulWidget {
  const MedicationsSearchBar({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  ConsumerState<MedicationsSearchBar> createState() =>
      _MedicationsSearchBarState();
}

class _MedicationsSearchBarState extends ConsumerState<MedicationsSearchBar> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref
          .read(medicationFilterProvider.notifier)
          .updateSearchQuery(value.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: EnhancedSearchBar(
        hintText: l10n.searchMedications,
        controller: widget.controller,
        onChanged: _onSearchChanged,
        onClear: () {
          _debounce?.cancel();
          ref.read(medicationFilterProvider.notifier).updateSearchQuery('');
        },
      ),
    );
  }
}
