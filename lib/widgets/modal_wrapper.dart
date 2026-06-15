import 'package:flutter/material.dart';

class ModalWrapper extends StatelessWidget {
  final Widget child;
  const ModalWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // SafeArea owns the bottom gesture inset (showModalBottomSheet's useSafeArea
    // skips the bottom). It also strips that inset from descendants' MediaQuery,
    // so scrollables inside don't re-add it. The Padding is just the base inset.
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // iOS-style grab handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
