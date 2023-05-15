import 'package:retur/models/favourite.dart';
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

  String trip(StopPlace from, StopPlace to, Set<TransportMode> filter) {
    final String notFilter = _getNotfilter(filter);

    return """
      {
        trip(
          from: {
            place: "${from.id}", 
            coordinates: {latitude: ${from.latitude}, longitude: ${from.longitude}},
            name: "${from.name}"}
          to: {
            place: "${to.id}", 
            coordinates: {latitude: ${to.latitude}, longitude: ${to.longitude}},
            name: "${to.name}"}
          filters: $notFilter
          modes: {accessMode: foot, egressMode: foot}
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
