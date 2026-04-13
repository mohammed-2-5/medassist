import 'package:flutter/material.dart';

/// One entry in the analytics period selector: the underlying value
/// (0 = Today, 1 = Week, 2 = Month, 3 = Year), its localized label, and
/// the icon rendered inside the pill.
class AnalyticsPeriodOption {
  const AnalyticsPeriodOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  final int value;
  final String label;
  final IconData icon;
}
