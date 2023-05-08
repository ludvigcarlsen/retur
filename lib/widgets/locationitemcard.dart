import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:retur/models/searchresponse.dart';
import 'package:retur/widgets/transporticon.dart';

import '../utils/location_categories.dart';
import '../utils/transportmodes.dart';

class LocationCard extends StatelessWidget {
  final Feature feature;
  final VoidCallback onTap;

  LocationCard({required this.feature, required this.onTap});

  Widget _test() {
    if (feature.isStreet()) {
      return const Icon(Icons.home);
    }

    if (feature.isStopPlace()) {
      return Row(
        children: [
          for (var cat in feature.properties.category!.toSet()) ...[
            Container(
              margin: EdgeInsets.only(left: 5.0),
              child: toTransportMode[cat] != null
                  ? TransportIcon(
                      mode: toTransportMode[cat]!,
                      iconSize: 15,
                    )
                  : Text(cat),
            )
          ],
        ],
      );
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
              margin: EdgeInsets.symmetric(vertical: 10),
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
                  _test(),
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
