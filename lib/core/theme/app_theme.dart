import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_assist/core/theme/app_text_theme.dart';
import 'package:med_assist/core/theme/color_schemes.dart';
import 'package:med_assist/core/theme/component_themes.dart';

/// Professional Theme System for Med Assist.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = AppColorSchemes.light();
    return buildAppThemeData(
      colorScheme: colorScheme,
      brightness: Brightness.light,
      textTheme: buildAppTextTheme(colorScheme),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = AppColorSchemes.dark();
    return buildAppThemeData(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      textTheme: buildAppTextTheme(colorScheme),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }
}
