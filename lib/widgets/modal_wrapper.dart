import 'package:flutter/material.dart';

class ModalWrapper extends StatelessWidget {
  final Widget child;
  final String title;
  const ModalWrapper({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Wrap(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context, null),
                icon: const Icon(Icons.close_outlined),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}
