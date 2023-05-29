class TripSettings {
  bool isDynamicTrip;
  bool includeFirstWalk;

  TripSettings(this.isDynamicTrip, this.includeFirstWalk);

  TripSettings.def()
      : isDynamicTrip = true,
        includeFirstWalk = false;

  Map<String, dynamic> toJson() {
    return {
      'isDynamicTrip': isDynamicTrip,
      'includeFirstWalk': includeFirstWalk
    };
  }

  factory TripSettings.fromJson(Map<String, dynamic> json) {
    return TripSettings(json['isDynamicTrip'], json['includeFirstWalk']);
  }

  factory TripSettings.from(TripSettings settings) {
    return TripSettings(settings.isDynamicTrip, settings.includeFirstWalk);
  }
}
