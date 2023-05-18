import 'package:retur/models/searchresponse.dart';
import 'package:retur/utils/transportmodes.dart';

class TripData {
  final StopPlace from;
  final StopPlace to;
  final Set<TransportMode> excludeModes;

  TripData(this.from, this.to, this.excludeModes);

  Map<String, dynamic> toJson() => {
        'from': from.toJson(),
        'to': to.toJson(),
        'filter': excludeModes.map((f) => f.toJson()).toList(),
      };

  factory TripData.fromJson(Map<String, dynamic> json) {
    return TripData(
        StopPlace.fromJson(json['from']),
        StopPlace.fromJson(json['to']),
        json['filter']
            .map<TransportMode>((e) => TransportMode.fromJson(e))
            .toSet());
    // json['filter'].map((e) => TransportMode.fromJson(e)).toSet());
    //TransportMode.fromJson(data['excludeModes'])
    //Set<String>.from(json['filter'])); s
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
