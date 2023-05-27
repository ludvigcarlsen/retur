import 'package:flutter/material.dart';

class TripCardSkeleton extends StatelessWidget {
  const TripCardSkeleton({super.key});

  Widget skeleton(double width, double height, double radius) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: Color.fromARGB(255, 64, 65, 73),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromARGB(255, 55, 55, 63),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          skeleton(80, 20, 5),
          const SizedBox(height: 10),
          skeleton(double.infinity, 23, 5)
        ],
      ),
    );
  }
}
