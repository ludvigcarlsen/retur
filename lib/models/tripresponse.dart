class TripResponse {
  final Data data;

  TripResponse(this.data);

  factory TripResponse.fromJson(Map<String, dynamic> json) {
    return TripResponse(Data.fromJson(json['data']));
  }
}

class Data {
  Trip trip;

  Data(this.trip);

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(Trip.fromJson(json['trip']));
  }
}

class Trip {
  List<TripPattern> tripPatterns;

  Trip(this.tripPatterns);

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(List<TripPattern>.from(
      json['tripPatterns']
          .map((pattern) => TripPattern.fromJson(pattern))
          .toList(),
    ));
  }
}

class TripPattern {
  String expectedStartTime;
  int? duration;
  List<Leg> legs;
  double? distance;
  String expectedEndTime;
  String endTime;
  String startTime;

  TripPattern(this.expectedStartTime, this.duration, this.legs, this.distance,
      this.expectedEndTime, this.endTime, this.startTime);

  factory TripPattern.fromJson(Map<String, dynamic> json) {
    return TripPattern(
        json['expectedStartTime'],
        json['duration'],
        List<Leg>.from(json['legs'].map((leg) => Leg.fromJson(leg)).toList()),
        json['distance'],
        json['expectedEndTime'],
        json['endTime'],
        json['startTime']);

/*     expectedStartTime = json['expectedStartTime'];
    duration = json['duration'];
    if (json['legs'] != null) {
      legs = <Legs>[];
      json['legs'].forEach((v) {
        legs!.add(Legs.fromJson(v));
      });
    }
    distance = json['distance'];
    expectedEndTime = json['expectedEndTime'];
    endTime = json['endTime'];
    startTime = json['startTime'];
  } */
  }
}

class Leg {
  String mode;
  double? distance;
  int? duration;
  Line? line;

  Leg(this.mode, this.distance, this.duration, this.line);

  factory Leg.fromJson(Map<String, dynamic> json) {
    return Leg(json['mode'], json['distance'], json['duration'],
        json['line'] != null ? Line.fromJson(json['line']) : null);
  }
}

class Line {
  String? id;
  String? publicCode;
  String? name;

  Line(this.id, this.publicCode, this.name);

  factory Line.fromJson(Map<String, dynamic> json) {
    return Line(json['id'], json['publicCode'], json['name']);
  }
}
