import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LegCard extends StatelessWidget {
  final Color? color;
  final Widget child;
  final double height;

  const LegCard({super.key, required this.child, this.color, this.height = 23});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
      color: color,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Container(height: height, child: child),
      ),
    );
  }

  static Widget walkLeg(int? seconds) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/foot.svg',
              height: 15,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            Text(
              seconds == null ? "" : "${(seconds / 60).floor()}",
              style: const TextStyle(fontSize: 10, height: 1),
            ),
          ],
        ),
      ),
    );
  }

  static Widget transportLeg(String transportmode, String? publicCode) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/$transportmode.svg',
            height: 18,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          publicCode != null
              ? Padding(
                  padding: EdgeInsets.only(left: 2),
                  child: Text(
                    "$publicCode",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  static Widget overflowLeg(int count) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(5),
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
