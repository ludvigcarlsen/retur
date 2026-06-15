import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// Android-only: ask the launcher to pin a Retur widget to the Home Screen
/// (AppWidgetManager.requestPinAppWidget). iOS has no equivalent.
class WidgetPin {
  static const _channel =
      MethodChannel('io.github.ludvigcarlsen.retur/widgets');

  /// Whether the OS (API 26+) and the current launcher support one-tap pinning.
  static Future<bool> isSupported() async {
    if (!Platform.isAndroid) return false;
    return await _channel.invokeMethod<bool>('canPinWidget') ?? false;
  }

  /// Asks the launcher to add a widget (it shows its own confirm dialog).
  /// [which] is 'compact' or 'board'.
  static Future<void> request(String which) =>
      _channel.invokeMethod('pinWidget', {'widget': which});
}
