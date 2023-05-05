class Queries {
  static final Queries _queries = Queries._internal();

  factory Queries() {
    return _queries;
  }

  Queries._internal();

  final String journeyPlannerV3BaseUrl =
      "https://api.entur.io/journey-planner/v3/graphql";

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'ET-Client-Name': 'ludvigcarlsen-retur'
  };

  String tripByPlace(String fromPlace, String toPlace) {
    return """
      {
        trip(from: {place: "$fromPlace"}, to: {place: "$toPlace"}) {
          tripPatterns {
            expectedStartTime
            duration
            legs {
              mode
              distance
              duration
              line {
                id
                publicCode
                name
              }
            }
            distance
            expectedEndTime
            endTime
            startTime
          }
        }
      }"""
        .trim();
  }
}
