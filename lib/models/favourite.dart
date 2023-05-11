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
        'filters': filters.map((f) => f.toString()).toList(),
      };

  factory Favourite.fromJson(Map<String, dynamic> json) {
    return Favourite(
      FavouriteStop.fromJson(json['from']),
      FavouriteStop.fromJson(json['to']),
      json['filters'].map((f) => fromString(f)).cast<TransportMode>().toSet(),
    );
  }
}

class FavouriteStop {
  final String id;
  final String name;
  final List<double> coordinates;

  FavouriteStop(this.id, this.name, this.coordinates);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'coordinates': coordinates,
      };

  factory FavouriteStop.fromJson(Map<String, dynamic> json) {
    final coordinatesJson = json['coordinates'] as List<dynamic>?;
    final coordinates = coordinatesJson?.cast<double>().toList();

    return FavouriteStop(
      json['id'] as String,
      json['name'] as String,
      coordinates!,
    );
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
