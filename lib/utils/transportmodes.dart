import 'package:flutter/material.dart';

enum TransportMode {
  bus,
  coach,
  tram,
  rail,
  metro,
  water,
  air,
  lift,
  foot,
  unknown
}

final Map<String, Color> transportColorMap = {
  TransportMode.bus.name: const Color.fromARGB(255, 231, 1, 0),
  TransportMode.coach.name: Colors.greenAccent,
  TransportMode.tram.name: const Color.fromARGB(255, 13, 144, 239),
  TransportMode.rail.name: const Color.fromARGB(255, 34, 94, 226),
  TransportMode.metro.name: const Color.fromARGB(255, 237, 112, 8),
  TransportMode.water.name: Colors.purple,
  TransportMode.air.name: Colors.grey,
  TransportMode.lift.name: Colors.white,
  TransportMode.foot.name: const Color.fromARGB(255, 82, 83, 93),
};

TransportMode fromString(String mode) {
  return TransportMode.values.firstWhere((e) => e.name.toString() == mode,
      orElse: () => TransportMode.unknown);
}
