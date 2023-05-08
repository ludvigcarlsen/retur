import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../utils/transportmodes.dart';

class TransportIcon extends StatelessWidget {
  final TransportMode mode;
  double? iconSize;
  String? publicCode;

  TransportIcon(
      {super.key, required this.mode, this.publicCode, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: transportColorMap[mode.name],
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/${mode.name}.svg',
              height: iconSize ?? 20,
              width: iconSize ?? 20,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            publicCode != null
                ? Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Text(
                      "${publicCode}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
