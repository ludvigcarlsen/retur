import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:retur/utils/extensions.dart';
import 'package:retur/utils/transportmodes.dart';

class TripFilter extends StatefulWidget {
  final Set<TransportMode> excludeModes;

  TripFilter({super.key, required this.excludeModes});

  @override
  State<TripFilter> createState() => _TripFilterState();
}

class _TripFilterState extends State<TripFilter> {
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
    return ListView(
      shrinkWrap: true,
      children: [
        Text(_getModesShowingText()),
        const SizedBox(height: 15),
        StaggeredGrid.count(
          crossAxisCount: 6,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: _gridTiles(allTransportModes),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, widget.excludeModes),
          child: const Padding(
              padding: EdgeInsets.all(15.0), child: Text("Confirm")),
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
