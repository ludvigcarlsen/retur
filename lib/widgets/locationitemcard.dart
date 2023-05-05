import 'package:flutter/material.dart';
import 'package:retur/models/searchresponse.dart';

class LocationCard extends StatelessWidget {
  final Feature feature;

  LocationCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(feature.properties.name),
            const SizedBox(height: 5.0),
            feature.properties.county != null
                ? Text(
                    feature.properties.county!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
