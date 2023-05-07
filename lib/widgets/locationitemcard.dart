import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:retur/models/searchresponse.dart';

class LocationCard extends StatelessWidget {
  final Feature feature;
  final VoidCallback onTap;

  LocationCard({required this.feature, required this.onTap});

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
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(feature.properties.name),
                        SizedBox(height: 8),
                        feature.properties.county != null
                            ? Text(
                                feature.properties.county!,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12.0),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/house.svg',
                    height: 20,
                    width: 20,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
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
