import 'package:retur/models/searchresponse.dart';
import 'package:retur/utils/transportmodes.dart';

import 'filter.dart';

class TripData {
  final StopPlace from;
  final StopPlace to;
  final Filter filter;

  TripData(this.from, this.to, this.filter);

  Map<String, dynamic> toJson() =>
      {'from': from.toJson(), 'to': to.toJson(), 'filter': filter.toJson()};

  factory TripData.fromJson(Map<String, dynamic> json) {
    return TripData(
      StopPlace.fromJson(json['from']),
      StopPlace.fromJson(json['to']),
      Filter.fromJson(json['filter']),
    );
  }
}

class StopPlace {
  final String? id;
  final String? name;
  final double latitude;
  final double longitude;

  StopPlace(this.id, this.name, this.latitude, this.longitude);

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'latitude': latitude, 'longitude': longitude};

  factory StopPlace.fromJson(Map<String, dynamic> json) {
    return StopPlace(json['id'] as String?, json['name'] as String,
        json['latitude'] as double, json['longitude'] as double);
  }

  factory StopPlace.fromFeature(Feature feature) {
    return StopPlace(feature.properties.id, feature.properties.name,
        feature.geometry.coordinates![1], feature.geometry.coordinates![0]);
  }
}
