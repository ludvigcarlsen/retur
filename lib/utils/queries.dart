import 'package:retur/models/tripdata.dart';
import 'package:retur/models/filter.dart';
import 'package:retur/utils/transportmodes.dart';

class Queries {
  final String journeyPlannerV3BaseUrl =
      "https://api.entur.io/journey-planner/v3/graphql";

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'ET-Client-Name': 'ludvigcarlsen-retur'
  };

  static String trip(StopPlace from, StopPlace to, Filter? filter) {
    filter ??= Filter.def();
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
          filters: ${filter.toQueryJson()}
          modes: {accessMode: foot, egressMode: foot}
          walkSpeed: ${filter.walkSpeed / 3.6}
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
