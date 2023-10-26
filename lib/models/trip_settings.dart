class TripSettings {
  bool isDynamicTrip;
  bool includeFirstWalk;

  TripSettings(this.isDynamicTrip, this.includeFirstWalk);

  TripSettings.def()
      : isDynamicTrip = false,
        includeFirstWalk = false;

  Map<String, dynamic> toJson() {
    return {
      'isDynamicTrip': isDynamicTrip,
      'includeFirstWalk': includeFirstWalk
    };
  }

  bool equals(TripSettings other) {
    return isDynamicTrip == other.isDynamicTrip &&
        includeFirstWalk == other.includeFirstWalk;
  }

  factory TripSettings.fromJson(Map<String, dynamic> json) {
    return TripSettings(json['isDynamicTrip'], json['includeFirstWalk']);
  }

  factory TripSettings.from(TripSettings settings) {
    return TripSettings(settings.isDynamicTrip, settings.includeFirstWalk);
  }
}
