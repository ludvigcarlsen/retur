import 'package:flutter/material.dart';

enum TransportMode {
  bus("bus"),
  coach("coach"),
  tram("tram"),
  rail("train"),
  metro("metro"),
  water("ferry"),
  air("airplane"),
  lift("lift"),
  foot("foot"),
  unknown("unknown");

  const TransportMode(this.displayName);
  final String displayName;

  Map<String, dynamic> toJson() {
    return {'transportMode': name};
  }

  static TransportMode fromJson(String s) => values.byName(s);

  static Color getColor(String mode) {
    return transportColorMap[mode] ?? const Color.fromARGB(255, 148, 148, 148);
  }

  static Map<String, Color> transportColorMap = {
    bus.name: const Color.fromARGB(255, 230, 0, 0),
    tram.name: const Color.fromARGB(255, 11, 145, 239),
    rail.name: const Color.fromARGB(255, 0, 48, 135),
    metro.name: const Color.fromARGB(255, 236, 112, 12),
    water.name: const Color.fromARGB(255, 104, 44, 136),
    foot.name: const Color.fromARGB(255, 82, 83, 93),
  };

  static Map<String, String> transportAssetMap = {
    bus.name: "assets/bus.svg",
    coach.name: "assets/bus.svg",
    tram.name: "assets/tram.svg",
    rail.name: "assets/rail.svg",
    metro.name: "assets/metro.svg",
    water.name: "assets/water.svg",
    air.name: "assets/air.svg",
    foot.name: "assets/foot.svg"
  };
}
