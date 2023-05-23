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

  static Map<String, Color> transportColorMap = {
    bus.name: const Color.fromARGB(255, 231, 1, 0),
    coach.name: Colors.greenAccent,
    tram.name: const Color.fromARGB(255, 13, 144, 239),
    rail.name: const Color.fromARGB(255, 34, 94, 226),
    metro.name: const Color.fromARGB(255, 237, 112, 8),
    water.name: Colors.purple,
    air.name: Colors.grey,
    lift.name: Colors.white,
    foot.name: const Color.fromARGB(255, 82, 83, 93),
  };
}
