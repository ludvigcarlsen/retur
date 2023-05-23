import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:retur/utils/extensions.dart';
import 'package:retur/utils/transportmodes.dart';

import '../models/filter.dart';
import '../screens/trip.dart';

class TripFilter extends StatelessWidget {
  late final Filter filter;

  TripFilter({super.key, Filter? current}) {
    filter = current ?? Filter.def();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Wrap(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filter your search",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context, null),
                icon: const Icon(Icons.close_outlined),
              ),
            ],
          ),
          ListView(
            shrinkWrap: true,
            children: [
              TransportModeFilter(excludeModes: filter.not.modes),
              const SizedBox(height: 20),
              WalkSpeedCard(
                walkSpeed: filter.walkSpeed,
                onChanged: (value) => filter.walkSpeed = value,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, filter),
                  child: const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text("Confirm"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TransportModeFilter extends StatefulWidget {
  final Set<TransportMode> excludeModes;

  const TransportModeFilter({super.key, required this.excludeModes});

  @override
  State<TransportModeFilter> createState() => _TransportModeFilterState();
}

class _TransportModeFilterState extends State<TransportModeFilter> {
  final Map<TransportMode, int> allTransportModes = {
    TransportMode.bus: 2,
    TransportMode.tram: 2,
    TransportMode.metro: 2,
    TransportMode.rail: 3,
    TransportMode.water: 3
  };

  void _toggleTransportMode(TransportMode mode) {
    setState(() {
      widget.excludeModes.contains(mode)
          ? widget.excludeModes.remove(mode)
          : widget.excludeModes.add(mode);
    });
  }

  String _getModesShowingText() {
    if (widget.excludeModes.isEmpty) {
      return "Showing all transport modes";
    }
    final modes = widget.excludeModes.map((e) => e.name).toList();
    if (modes.length > 1) {
      final lastMode = modes.removeLast();
      return "Not showing ${modes.join(', ')} or $lastMode";
    }
    return "Not showing ${modes[0]}";
  }

  List<Widget> _gridTiles(Map<TransportMode, int> modes) {
    return modes.entries.map((e) {
      return StaggeredGridTile.fit(
        crossAxisCellCount: e.value,
        child: TransportModeCard(
          mode: e.key,
          selected: !widget.excludeModes.contains(e.key),
          onToggle: _toggleTransportMode,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_getModesShowingText()),
        const SizedBox(height: 5),
        StaggeredGrid.count(
          crossAxisCount: 6,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: _gridTiles(allTransportModes),
        ),
      ],
    );
  }
}

class TransportModeCard extends StatefulWidget {
  final TransportMode mode;
  final Function(TransportMode) onToggle;
  bool selected;

  TransportModeCard(
      {super.key,
      required this.mode,
      required this.selected,
      required this.onToggle});

  @override
  State<TransportModeCard> createState() => _TransportModeCardState();
}

class _TransportModeCardState extends State<TransportModeCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.selected = !widget.selected;
          widget.onToggle(widget.mode);
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/${widget.mode.name}.svg',
                    height: 20,
                    width: 20,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  const SizedBox(height: 10.0),
                  Text(widget.mode.displayName.capitalize()),
                ],
              ),
              widget.selected
                  ? const Icon(Icons.check_circle, size: 15)
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class WalkSpeedCard extends StatefulWidget {
  double walkSpeed; // in kph
  final void Function(double) onChanged;

  WalkSpeedCard({super.key, required this.walkSpeed, required this.onChanged});

  @override
  State<WalkSpeedCard> createState() => _WalkSpeedCardState();
}

class _WalkSpeedCardState extends State<WalkSpeedCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text("What is your pace?"),
            Spacer(),
            Text("${double.parse(widget.walkSpeed.toStringAsFixed(1))} km/h"),
          ],
        ),
        SizedBox(height: 5),
        Card(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.bug_report),
                    Expanded(
                      child: Slider(
                        value: widget.walkSpeed,
                        min: 2.4,
                        max: 10.0,
                        onChanged: (value) =>
                            setState(() => widget.walkSpeed = value),
                        onChangeEnd: (value) => widget.onChanged(value),
                      ),
                    ),
                    Icon(Icons.cruelty_free),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Slow"), Text("Fast")],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
