import 'package:retur/utils/transportmodes.dart';

enum LocationCategory {
  onstreetBus,
  metroStation,
  onstreetTram,
  railStation,
  street,
  vegadresse,
  GroupOfStopPlaces,
  poi,
  ferryStop,
  airport,
  busStation
}

final Map<String, TransportMode> toTransportMode = {
  LocationCategory.onstreetBus.name: TransportMode.bus,
  LocationCategory.metroStation.name: TransportMode.metro,
  LocationCategory.onstreetTram.name: TransportMode.tram,
  LocationCategory.railStation.name: TransportMode.rail,
  LocationCategory.ferryStop.name: TransportMode.water,
  LocationCategory.airport.name: TransportMode.air,
  LocationCategory.busStation.name: TransportMode.bus
};
