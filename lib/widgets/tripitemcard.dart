import 'package:flutter/material.dart';
import 'package:retur/models/tripresponse.dart';
import 'package:intl/intl.dart';
import 'package:retur/utils/transportmodes.dart';

import 'leg_card.dart';

class TripCard extends StatelessWidget {
  final TripPattern patterns;
  final double legCardHeight = 23;
  final int legCardThreshold = 4;

  TripCard({required this.patterns});

  String utcTohhmm(String utc) {
    DateTime dateTime = DateTime.parse(utc);
    return DateFormat('HH:mm', 'en_US').format(dateTime.toLocal());
  }

  String formatSeconds(int? seconds) {
    if (seconds == null) return "";
    Duration duration = Duration(seconds: seconds);
    int minutes = duration.inMinutes;

    return minutes < 60
        ? "$minutes min"
        : "${minutes ~/ 60} h ${minutes % 60} min";
  }

  List<Widget> _buildLegCardList() {
    var children = <Widget>[];

    for (var i = 0; i < patterns.legs.length; i++) {
      if (i == legCardThreshold && i != patterns.legs.length - 1) {
        children.add(LegCard(
            height: legCardHeight,
            padding: 6,
            color: const Color.fromARGB(80, 123, 174, 245),
            child: LegCard.overflowLeg(patterns.legs.length - i)));
        break;
      }

      var leg = patterns.legs[i];
      Widget child = leg.mode == TransportMode.foot.name
          ? LegCard.walkLeg(leg.duration)
          : LegCard.transportLeg(leg.mode, leg.line?.publicCode);

      children.add(LegCard(
        height: legCardHeight,
        padding: 6,
        color: TransportMode.getColor(leg.mode),
        child: child,
      ));
      children.add(const SizedBox(width: 4));
    }
    children.add(const Spacer());
    children.add(Text(
      formatSeconds(patterns.duration),
      style: TextStyle(color: Colors.white.withOpacity(0.7)),
    ));
    return children;
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
              "${utcTohhmm(patterns.startTime)} - ${utcTohhmm(patterns.endTime)}",
            ),
            const SizedBox(height: 10),
            Row(children: _buildLegCardList()),
          ],
        ),
      ),
    );
  }
}
