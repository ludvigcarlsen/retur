import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LegCard extends StatelessWidget {
  final Color? color;
  final double padding;
  final double? height;
  final Widget child;

  const LegCard(
      {super.key,
      required this.child,
      this.color,
      this.padding = 3,
      this.height});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
      color: color,
      child: Padding(
          padding: EdgeInsets.all(padding),
          child: SizedBox(height: height, child: child)),
    );
  }

  static Widget walkLeg(int? seconds) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/foot.svg',
              height: 12,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            Text(
              seconds == null ? "" : "${(seconds / 60).ceil()}",
              style: const TextStyle(fontSize: 10, height: 1),
            ),
          ],
        ),
      ),
    );
  }

  static Widget transportLeg(String transportmode, String? publicCode) {
    return Row(
      children: [
        FittedBox(
          child: SvgPicture.asset(
            'assets/$transportmode.svg',
            height: 18,
            width: 18,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        publicCode != null
            ? Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(publicCode,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)))
            : Container(),
      ],
    );
  }

  static Widget overflowLeg(int count) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Text(
          "+$count",
          style: const TextStyle(
              color: Color.fromARGB(255, 123, 174, 245),
              fontWeight: FontWeight.bold,
              fontSize: 10),
        ),
      ),
    );
  }
}
