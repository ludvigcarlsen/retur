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

  String tripFromPlaceToCoordinates(
      String place, List<double> coords, Set<TransportMode> not) {
    final String notFilter = _getNotfilter(not);

    return """
      {
        trip(
          from: {place: "$place"} 
          to: {coordinates: {latitude: ${coords[1]}, longitude: ${coords[0]}}}
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

  String tripFromCoordinatesToPlace(
      List<double> coords, String place, Set<TransportMode> not) {
    final String notFilter = _getNotfilter(not);

    return """
      {
        trip(
          from: {coordinates: {latitude: ${coords[1]}, longitude: ${coords[0]}}}
          to: {place: "$place"}
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

  String tripFromPlaceToPlace(
      String fromPlace, String toPlace, Set<TransportMode> not) {
    final String notFilter = _getNotfilter(not);

    return """
      {
        trip(
          from: {place: "$fromPlace"}
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

  String tripFromCoordinatesToCoordinates(
      List<double> from, List<double> to, Set<TransportMode> not) {
    final String notFilter = _getNotfilter(not);

    return """
      {
        trip(
          from: {coordinates: {latitude: ${from[1]}, longitude: ${from[0]}}}
          to: {coordinates: {latitude: ${to[1]}, longitude: ${to[0]}}}
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

  String _getNotfilter(Set<TransportMode> exclude) {
    if (exclude.isNotEmpty) {
      final notModes =
          exclude.map((mode) => "{transportMode: ${mode.name}}").join(", ");
      return "{not: {transportModes: [$notModes]}}";
    }
    return "{}";
  }
}
