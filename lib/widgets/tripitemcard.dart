import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:retur/models/tripresponse.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:retur/utils/transportmodes.dart';

class TripCard extends StatelessWidget {
  final TripPatterns patterns;

  TripCard({required this.patterns});

  String utcTohhmm(String utc) {
    DateTime dateTime = DateTime.parse(utc);
    String timeZone = DateTime.now().timeZoneOffset.toString();
    return DateFormat('HH:mm', 'en_US').format(dateTime.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15.0),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${utcTohhmm(patterns.startTime!)} - ${utcTohhmm(patterns.endTime!)}",
            ),
            const SizedBox(
              height: 5.0,
            ),
            Row(
              children: [
                for (var leg in patterns.legs!) ...[
                  leg.mode == TransportMode.foot.name
                      ? WalkLegCard(leg: leg)
                      : TransportLegCard(leg: leg)
                ],
                const Spacer(),
                Text("${(patterns.duration! / 60).ceil()} min")
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TransportLegCard extends StatelessWidget {
  final Legs leg;

  TransportLegCard({super.key, required this.leg});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: transportColorMap[leg.mode],
      margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(children: [
          SvgPicture.asset(
            'assets/${leg.mode}.svg',
            height: 20,
            width: 20,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          const SizedBox(width: 5.0),
          Text(
            "${leg.line?.publicCode}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ]),
      ),
    );
  }
}

class WalkLegCard extends StatelessWidget {
  const WalkLegCard({
    super.key,
    required this.leg,
  });

  final Legs leg;

  int toMinutes(int seconds) {
    return (seconds / 60).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: transportColorMap[leg.mode],
      margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/${leg.mode}.svg',
              height: 15,
              width: 15,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            Text(
              "${toMinutes(leg.duration!)}",
              style: const TextStyle(fontSize: 10.0),
            ),
          ],
        ),
      ),
    );
  }
}
