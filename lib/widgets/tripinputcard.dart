import 'package:flutter/material.dart';

import '../screens/search.dart';

class TripInputCard extends StatelessWidget {
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final String? fromName;
  final String? toName;

  TripInputCard({
    super.key,
    required this.onFromTap,
    required this.onToTap,
    this.fromName,
    this.toName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          LocationCard(
            tag: "From",
            name: fromName,
            onTap: onFromTap,
          ),
          const SizedBox(height: 5.0),
          LocationCard(
            tag: "To",
            name: toName,
            onTap: onToTap,
          ),
        ],
      ),
    );
  }
}

class LocationCard extends StatefulWidget {
  final String tag;
  final String? name;
  final VoidCallback onTap;

  const LocationCard(
      {super.key, this.tag = "", required this.name, required this.onTap});

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(37, 15, 15, 15),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  widget.tag,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 10,
                child: Text(widget.name ?? ""),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
