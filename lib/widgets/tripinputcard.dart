import 'package:flutter/material.dart';

import '../screens/search.dart';

class TripInputCard extends StatelessWidget {
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final VoidCallback onTripSelected;
  String? fromName;
  String? toName;

  TripInputCard({
    super.key,
    required this.onFromTap,
    required this.onToTap,
    required this.onTripSelected,
    this.fromName,
    this.toName,
  }) {
    if (fromName != null && toName != null) {
      print("sdkfj");
      onTripSelected();
    }
  }

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
          SizedBox(
            height: 5.0,
          ),
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
  String? name;
  final VoidCallback onTap;

  LocationCard(
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
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  widget.tag,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 7,
                child: Text(widget.name ?? ""),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
