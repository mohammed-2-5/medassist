import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Common device configs used when pumping widgets in tests.
class TestDeviceConfig {
  const TestDeviceConfig({
    required this.name,
    required this.size,
    this.devicePixelRatio = 3,
  });

  final String name;
  final Size size;
  final double devicePixelRatio;

  static const phonePortrait = TestDeviceConfig(
    name: 'phonePortrait',
    size: Size(390, 844),
  );

  static const phoneLandscape = TestDeviceConfig(
    name: 'phoneLandscape',
    size: Size(844, 390),
  );

  static const tabletPortrait = TestDeviceConfig(
    name: 'tabletPortrait',
    size: Size(768, 1024),
    devicePixelRatio: 2,
  );

  static const tabletLandscape = TestDeviceConfig(
    name: 'tabletLandscape',
    size: Size(1024, 768),
    devicePixelRatio: 2,
  );

  static const defaults = <TestDeviceConfig>[
    phonePortrait,
    phoneLandscape,
    tabletPortrait,
    tabletLandscape,
  ];
}

/// Wraps [child] with the production MaterialApp + ProviderScope stack used in the app.
Widget buildTestAppShell({
  required Widget child,
  ThemeMode themeMode = ThemeMode.light,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
  NavigatorObserver? navigatorObserver,
  bool enableDevicePreview = false,
}) {
  return ProviderScope(
    overrides: overrides,
    child: DevicePreview(
      enabled: enableDevicePreview,
      builder: (context) => MaterialApp(
        builder: DevicePreview.appBuilder,
        useInheritedMediaQuery: true,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        themeMode: themeMode,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF5C6BC0),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF5C6BC0),
          brightness: Brightness.dark,
        ),
        navigatorObservers: [
          ?navigatorObserver,
        ],
        home: child,
      ),
    ),
  );
}

/// Pumps [child] wrapped in the standard ProviderScope + MaterialApp with the requested device size.
Future<void> pumpAppWidget(
  WidgetTester tester,
  Widget child, {
  TestDeviceConfig device = TestDeviceConfig.phonePortrait,
  ThemeMode themeMode = ThemeMode.light,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
  NavigatorObserver? navigatorObserver,
  bool enableDevicePreview = false,
}) async {
  final binding = tester.binding;
  binding.window.physicalSizeTestValue = device.size;
  binding.window.devicePixelRatioTestValue = device.devicePixelRatio;

  addTearDown(() {
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  await tester.pumpWidget(
    buildTestAppShell(
      child: child,
      overrides: overrides,
      themeMode: themeMode,
      locale: locale,
      navigatorObserver: navigatorObserver,
      enableDevicePreview: enableDevicePreview,
    ),
  );
  await tester.pumpAndSettle();
}
