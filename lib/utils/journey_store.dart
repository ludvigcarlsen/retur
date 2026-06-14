import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:retur/models/journey.dart';

/// Owns the Flutter-side list of saved journeys and mirrors the active one to
/// the 'trip' key the native widgets read. Multiple journeys are a Flutter
/// concept; the widget still only ever sees a single active trip.
class JourneyStore {
  static const _journeysKey = 'journeys';
  static const _activeKey = 'activeId';
  static const _routineKey = 'routineEnabled';
  static const _defaultKey = 'defaultId';
  static const _widgetKey = 'trip'; // read by the iOS/Android widgets

  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  /// Loads the saved journeys, migrating a pre-existing single trip into the
  /// list on first run.
  static Future<List<Journey>> load() async {
    final raw = await HomeWidget.getWidgetData<String>(_journeysKey);
    if (raw != null) {
      return (jsonDecode(raw) as List)
          .map((e) => Journey.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final legacy = await HomeWidget.getWidgetData<String>(_widgetKey);
    if (legacy != null) {
      final t = Journey.fromJson(jsonDecode(legacy));
      final seeded = Journey(t.from, t.to,
          filter: t.filter, settings: t.settings, id: t.id ?? newId());
      await save([seeded]);
      await setActiveId(seeded.id!);
      return [seeded];
    }

    return [];
  }

  static Future<void> save(List<Journey> journeys) =>
      HomeWidget.saveWidgetData<String>(
          _journeysKey, jsonEncode(journeys.map((j) => j.toJson()).toList()));

  static Future<String?> activeId() =>
      HomeWidget.getWidgetData<String>(_activeKey);

  static Future<void> setActiveId(String id) =>
      HomeWidget.saveWidgetData<String>(_activeKey, id);

  /// Marks [j] as active: mirrors it to the widget key and refreshes the widget.
  static Future<void> activate(Journey j) async {
    await HomeWidget.saveWidgetData<String>(_widgetKey, jsonEncode(j));
    if (j.id != null) await setActiveId(j.id!);
    await HomeWidget.updateWidget(
        name: "TripWidgetProvider",
        iOSName: "TripWidget",
        androidName: "TripWidget");
    await HomeWidget.updateWidget(
        name: "TripBoardWidgetProvider",
        iOSName: "TripBoardWidget",
        androidName: "TripBoardWidget");
  }

  static Future<bool> routineEnabled() async =>
      (await HomeWidget.getWidgetData<bool>(_routineKey)) ?? false;

  static Future<void> setRoutineEnabled(bool value) =>
      HomeWidget.saveWidgetData<bool>(_routineKey, value);

  static Future<String?> defaultId() =>
      HomeWidget.getWidgetData<String>(_defaultKey);

  static Future<void> setDefaultId(String id) =>
      HomeWidget.saveWidgetData<String>(_defaultKey, id);
}
