import 'package:flutter/material.dart';

enum TransportMode { bus, coach, tram, rail, metro, water, air, lift, foot }

Map<String, Color> transportColorMap = {
  TransportMode.bus.name: const Color.fromARGB(255, 231, 1, 0),
  TransportMode.coach.name: Colors.white,
  TransportMode.tram.name: const Color.fromARGB(255, 13, 144, 239),
  TransportMode.rail.name: Colors.white,
  TransportMode.metro.name: const Color.fromARGB(255, 237, 112, 8),
  TransportMode.water.name: Colors.white,
  TransportMode.air.name: Colors.white,
  TransportMode.lift.name: Colors.white,
  TransportMode.foot.name: const Color.fromARGB(255, 82, 83, 93),
};
