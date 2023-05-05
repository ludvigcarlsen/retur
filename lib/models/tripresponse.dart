class TripResponse {
  Data? data;

  TripResponse({this.data});

  TripResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  Trip? trip;

  Data({this.trip});

  Data.fromJson(Map<String, dynamic> json) {
    trip = json['trip'] != null ? Trip.fromJson(json['trip']) : null;
  }
}

class Trip {
  List<TripPatterns>? tripPatterns;

  Trip({this.tripPatterns});

  Trip.fromJson(Map<String, dynamic> json) {
    if (json['tripPatterns'] != null) {
      tripPatterns = <TripPatterns>[];
      json['tripPatterns'].forEach((v) {
        tripPatterns!.add(TripPatterns.fromJson(v));
      });
    }
  }
}

class TripPatterns {
  String? expectedStartTime;
  int? duration;
  List<Legs>? legs;
  double? distance;
  String? expectedEndTime;
  String? endTime;
  String? startTime;

  TripPatterns(
      {this.expectedStartTime,
      this.duration,
      this.legs,
      this.distance,
      this.expectedEndTime,
      this.endTime,
      this.startTime});

  TripPatterns.fromJson(Map<String, dynamic> json) {
    expectedStartTime = json['expectedStartTime'];
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
  }
}

class Legs {
  String? mode;
  double? distance;
  int? duration;
  Line? line;

  Legs({this.mode, this.distance, this.line});

  Legs.fromJson(Map<String, dynamic> json) {
    mode = json['mode'];
    distance = json['distance'];
    duration = json['duration'];
    line = json['line'] != null ? Line.fromJson(json['line']) : null;
  }
}

class Line {
  String? id;
  String? publicCode;
  String? name;

  Line({this.id, this.publicCode, this.name});

  Line.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    publicCode = json['publicCode'];
    name = json['name'];
  }
}
