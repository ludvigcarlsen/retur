import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:retur/utils/extensions.dart';
import 'package:retur/utils/transportmodes.dart';
import 'package:retur/widgets/snapping_slider.dart';

import '../models/trip_filter.dart';

class TripFilterView extends StatelessWidget {
  late final TripFilter filter;

  TripFilterView({super.key, TripFilter? current}) {
    filter = current ?? TripFilter.def();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        TransportModeFilter(excludeModes: filter.not.transportModes),
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
    // TODO: optimize
    setState(() {
      widget.excludeModes.contains(mode)
          ? widget.excludeModes.remove(mode)
          : widget.excludeModes.add(mode);
    });
  }

  String _join(List<String> names) {
    if (names.length == 1) return names.first;
    final head = names.sublist(0, names.length - 1).join(', ');
    return "$head or ${names.last}";
  }

  String _getModesShowingText() {
    final excluded = allTransportModes.keys
        .where(widget.excludeModes.contains)
        .map((m) => m.name)
        .toList();
    if (excluded.isEmpty) return "Showing all transport modes";

    final selected = allTransportModes.keys
        .where((m) => !widget.excludeModes.contains(m))
        .map((m) => m.name)
        .toList();
    if (selected.isEmpty) return "Not showing any transport modes";

    // once most modes are off, the positive phrasing is shorter and clearer
    return excluded.length > allTransportModes.length / 2
        ? "Only showing ${_join(selected)}"
        : "Not showing ${_join(excluded)}";
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
      // unselected modes get a general disabled (faded) look
      child: Opacity(
        opacity: widget.selected ? 1.0 : 0.4,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
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
            const Text("What is your pace?"),
            const Spacer(),
            Text("${double.parse(widget.walkSpeed.toStringAsFixed(1))} km/h"),
          ],
        ),
        const SizedBox(height: 5),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/rabbit.svg',
                        height: 36,
                        width: 36,
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn)),
                    Expanded(
                      child: SnappingSlider(
                        value: widget.walkSpeed,
                        min: 2.4,
                        max: 10.0,
                        snapAt: 4.8, // recommended / default pace
                        onChanged: (v) => setState(() => widget.walkSpeed = v),
                        onChangeEnd: (v) {
                          // v is already snapped; reflect it and persist
                          setState(() => widget.walkSpeed = v);
                          widget.onChanged(v);
                        },
                      ),
                    ),
                    SvgPicture.asset('assets/turtle.svg',
                        height: 36,
                        width: 36,
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn)),
                  ],
                ),
                const Row(
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
