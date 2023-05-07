import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:retur/utils/transportmodes.dart';

class TripFilter extends StatefulWidget {
  final Set<TransportMode> exclude;

  TripFilter({super.key, required this.exclude});

  @override
  State<TripFilter> createState() => _TripFilterState();
}

class _TripFilterState extends State<TripFilter> {
  final Set<TransportMode> all = {
    TransportMode.bus,
    TransportMode.tram,
    TransportMode.metro
  };

  void _toggleMode(TransportMode mode) {
    setState(() {
      widget.exclude.contains(mode)
          ? widget.exclude.remove(mode)
          : widget.exclude.add(mode);
    });
  }

  String _getModesShowingText() {
    if (widget.exclude.isEmpty) {
      return "Showing all transport modes";
    }
    final modes = widget.exclude.map((e) => e.name).toList();
    if (modes.length > 1) {
      final lastMode = modes.removeLast();
      return "Not showing ${modes.join(', ')} or $lastMode";
    }
    return "Not showing ${modes[0]}";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                "Filter your search",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context, null),
                icon: const Icon(Icons.close_outlined),
              )
            ],
          ),
          const SizedBox(height: 20),
          Text(_getModesShowingText()),
          const SizedBox(height: 15),
          Expanded(
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 3 / 2,
              mainAxisSpacing: 15.0,
              crossAxisSpacing: 15.0,
              children: [
                for (var mode in all)
                  TransportModeCard(
                      mode: mode,
                      selected: !widget.exclude.contains(mode),
                      onToggle: _toggleMode)
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, widget.exclude),
            child: const Padding(
                padding: EdgeInsets.all(15.0), child: Text("Confirm")),
          ),
        ],
      ),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'assets/${widget.mode.name}.svg',
                    height: 20,
                    width: 20,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  const SizedBox(height: 5.0),
                  Text(widget.mode.name.capitalize()),
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
