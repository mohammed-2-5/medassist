import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'app_widget_harness.dart';

typedef ResponsiveWidgetBuilder = Widget Function(TestDeviceConfig device);

/// Pumps [builder] for each [devices] entry to verify responsive layouts.
Future<void> pumpWidgetAcrossDevices(
  WidgetTester tester,
  ResponsiveWidgetBuilder builder, {
  List<TestDeviceConfig>? devices,
  List<Override> overrides = const [],
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final configs = devices ?? TestDeviceConfig.defaults;
  for (final device in configs) {
    await pumpAppWidget(
      tester,
      builder(device),
      device: device,
      overrides: overrides,
      themeMode: themeMode,
    );
  }
}

final defaultGoldenDevices = <Device>[
  const Device(
    name: 'phone_portrait',
    size: Size(390, 844),
    devicePixelRatio: 3,
  ),
  const Device(
    name: 'phone_landscape',
    size: Size(844, 390),
    devicePixelRatio: 3,
  ),
  const Device(
    name: 'tablet_portrait',
    size: Size(768, 1024),
    devicePixelRatio: 2,
  ),
  const Device(
    name: 'tablet_landscape',
    size: Size(1024, 768),
    devicePixelRatio: 2,
  ),
];

/// Pumps a device builder and matches against a golden for multiple breakpoints.
Future<void> expectResponsiveGolden(
  WidgetTester tester, {
  required String goldenName,
  required WidgetBuilder widgetBuilder,
  List<Device>? devices,
}) async {
  await loadAppFonts();

  final deviceBuilder = DeviceBuilder()
    ..overrideDevicesForAllScenarios(
      devices: devices ?? defaultGoldenDevices,
    )
    ..addScenario(
      name: goldenName,
      widget: Builder(builder: widgetBuilder),
    );

  await tester.pumpDeviceBuilder(deviceBuilder);
  await screenMatchesGolden(tester, goldenName);
}
