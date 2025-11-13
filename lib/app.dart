import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/constants/app_constants.dart';
import 'package:med_assist/core/router/app_router.dart';
import 'package:med_assist/core/theme/app_theme.dart';
import 'package:med_assist/features/settings/providers/settings_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the settings provider to get the current theme mode and language
    final settings = ref.watch(settingsProvider);

    // Get locale from language code
    final locale = Locale(settings.languageCode);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Localization delegates
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Supported locales
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],

      // Current locale from settings
      locale: locale,

      // Use professionally designed themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Theme mode from user settings
      themeMode: settings.themeMode,

      // Navigation
      routerConfig: AppRouter.router,
    );
  }
}
