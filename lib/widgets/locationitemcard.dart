import 'package:flutter/material.dart';
import 'package:retur/models/searchresponse.dart';
import 'package:retur/widgets/leg_card.dart';

import '../utils/location_categories.dart';
import '../utils/transportmodes.dart';

class LocationCard extends StatelessWidget {
  final Feature feature;
  final VoidCallback onTap;

  LocationCard({required this.feature, required this.onTap});

  Widget _locationIdentifiers() {
    if (feature.isStreet()) {
      return const Icon(Icons.home);
    }

    if (feature.isStopPlace()) {
      final categories = feature.properties.category!;
      var legCards = <Widget>[];

      for (var cat in categories.toSet()) {
        final t = toTransportMode[cat];
        if (t != null) {
          legCards.add(const SizedBox(width: 4));
          legCards.add(LegCard(
            padding: 3,
            color: transportColorMap[t.name],
            child: LegCard.transportLeg(t.name, null),
          ));
        }
      }
      return Row(children: legCards);
    }

    return const Icon(Icons.place);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(feature.properties.name),
                      const SizedBox(height: 8),
                      feature.properties.county != null
                          ? Text(
                              feature.properties.county!,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12.0),
                            )
                          : Container(),
                    ],
                  ),
                  _locationIdentifiers(),
                ],
              ),
            ),
            const Divider(thickness: 1)
          ],
        ),
      ),
    );
  }
}
