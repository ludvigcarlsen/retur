import 'package:retur/utils/transportmodes.dart';

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

  String tripByPlace(String fromPlace, String toPlace, Set<TransportMode> not) {
    final String notFilter;

    if (not.isNotEmpty) {
      final notModes =
          not.map((mode) => "{transportMode: ${mode.name}}").join(", ");
      notFilter = "{not: {transportModes: [$notModes]}}";
    } else {
      notFilter = "{}";
    }

    return """
      {
        trip(
          from: {place: "$fromPlace"}, 
          to: {place: "$toPlace"}
          filters: $notFilter
          ) {
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
