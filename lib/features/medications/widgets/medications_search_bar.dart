import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/widgets/enhanced_search_bar.dart';
import 'package:med_assist/features/medications/providers/medications_filter_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Premium Search Bar for Medications List
///
/// Features:
/// - Gradient background (Teal → Light Blue)
/// - Cyan-themed border and icons
/// - Adaptive dark/light mode colors
/// - Smooth animations
class MedicationsSearchBar extends ConsumerWidget {
  const MedicationsSearchBar({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.primaryContainer.withOpacity(0.15),
                  colorScheme.secondaryContainer.withOpacity(0.1),
                ]
              : [
                  const Color(0xFFE0F2F1), // Teal 50
                  const Color(0xFFE1F5FE), // Light Blue 50
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Theme(
        data: theme.copyWith(
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: isDark
                    ? colorScheme.outline.withOpacity(0.3)
                    : const Color(0xFF00BCD4).withOpacity(0.3), // Cyan
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: isDark
                    ? colorScheme.outline.withOpacity(0.3)
                    : const Color(0xFF00BCD4).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Color(0xFF00BCD4), // Cyan
                width: 2.5,
              ),
            ),
            prefixIconColor: const Color(0xFF00BCD4),
            suffixIconColor: colorScheme.onSurface.withOpacity(0.6),
            hintStyle: TextStyle(
              color: isDark
                  ? colorScheme.onSurface.withOpacity(0.5)
                  : const Color(0xFF00695C), // Teal 800
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        child: EnhancedSearchBar(
          hintText: l10n.searchMedications,
          controller: controller,
          onChanged: (value) {
            ref.read(medicationFilterProvider.notifier).updateSearchQuery(value.toLowerCase());
          },
          onClear: () {
            ref.read(medicationFilterProvider.notifier).updateSearchQuery('');
          },
        ),
      ),
    );
  }
}
