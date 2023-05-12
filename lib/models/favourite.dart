import 'package:retur/utils/transportmodes.dart';

class Favourite {
  final FavouriteStop from;
  final FavouriteStop to;
  final Set<TransportMode> filters;
  // TODO
  //final Set<Leg> legs;

  Favourite(this.from, this.to, this.filters);

  Map<String, dynamic> toJson() => {
        'from': from.toJson(),
        'to': to.toJson(),
        'filter': filters.map((f) => f.toString()).toList(),
      };

  factory Favourite.fromJson(Map<String, dynamic> json) {
    return Favourite(
      FavouriteStop.fromJson(json['from']),
      FavouriteStop.fromJson(json['to']),
      json['filter'].map((f) => fromString(f)).cast<TransportMode>().toSet(),
    );
  }
}

class FavouriteStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  FavouriteStop(this.id, this.name, this.latitude, this.longitude);

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'latitude': latitude, 'longitude': longitude};

  factory FavouriteStop.fromJson(Map<String, dynamic> json) {
    return FavouriteStop(json['id'] as String, json['name'] as String,
        json['latitude'] as double, json['longitude'] as double);
  }
}

class Leg {
  final TransportMode mode;
  final String publicCode;

  Leg(this.mode, this.publicCode);

  factory Leg.fromJson(Map<String, dynamic> json) {
    return Leg(
      fromString(json['mode']),
      json['publicCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'publicCode': publicCode,
    };
  }
}
