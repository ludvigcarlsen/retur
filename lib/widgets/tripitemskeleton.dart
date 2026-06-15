import 'package:flutter/material.dart';
import 'package:retur/theme.dart';

class TripCardSkeleton extends StatelessWidget {
  const TripCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final barColor = AppColors.of(context).skeleton;

    Widget bar(double width, double height) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: barColor,
        ),
      );
    }

    return Container(
      height: 92,
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          bar(80, 20),
          const SizedBox(height: 10),
          bar(double.infinity, 23),
        ],
      ),
    );
  }
}
