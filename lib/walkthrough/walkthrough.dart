import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:retur/utils/journey_store.dart';
import 'package:retur/utils/transportmodes.dart';
import 'package:retur/utils/widget_pin.dart';
import 'package:retur/widgets/modal_wrapper.dart';

part 'common.dart';
part 'ios.dart';

/// Lets the user pick a widget layout (Compact / Board) and add it. On Android
/// with a supporting launcher each layout pins directly; on iOS (and older /
/// unsupported Android) the previews are reference + a link to the walkthrough.
Future<void> showAddWidgetSheet(BuildContext context) async {
  final canPin = await WidgetPin.isSupported();
  final active = await JourneyStore.activeJourney();
  if (!context.mounted) return;
  showModalBottomSheet(
    isScrollControlled: true,
    useSafeArea: true,
    context: context,
    builder: (_) => ModalWrapper(
      child: _AddWidgetChooser(
          canPin: canPin, from: active?.from.name, to: active?.to.name),
    ),
  );
}

/// Opens the add-widget guide: the animated iOS walkthrough, or a short
/// text-steps list on Android (where pinning isn't supported — a rare, very
/// launcher-fragmented case, so plain steps beat a misleading bespoke animation).
Future<void> showWidgetWalkthrough(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text("How to add a widget")),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Platform.isAndroid
                ? _androidSteps(context)
                : LayoutBuilder(
                    builder: (context, c) {
                      // as large as fits the available box
                      final w =
                          math.min(c.maxWidth, c.maxHeight * _kPhoneAspect);
                      return Center(
                        child: SizedBox(
                          width: w,
                          child:
                              WidgetWalkthrough(flow: iosFlowForThisDevice()),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    ),
  );
}

Widget _androidSteps(BuildContext context) {
  final accent =
      Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve(
            {},
          ) ??
          Theme.of(context).colorScheme.primary;
  const steps = [
    "Long-press your Home Screen",
    "Tap Widgets",
    "Find Retur",
    "Drag a widget to your Home Screen",
  ];
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < steps.length; i++)
        Padding(
          padding: EdgeInsets.only(bottom: i < steps.length - 1 ? 22 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.2),
                    shape: BoxShape.circle),
                child: Text("${i + 1}",
                    style:
                        TextStyle(color: accent, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(steps[i],
                      style: const TextStyle(fontSize: 14, height: 1.3)),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

/// Sheet body. On Android (supporting launcher) it's an iOS-gallery-style
/// carousel of the layouts with a big Add button; otherwise the walkthrough link.
class _AddWidgetChooser extends StatefulWidget {
  const _AddWidgetChooser({required this.canPin, this.from, this.to});

  final bool canPin;
  final String? from;
  final String? to;

  @override
  State<_AddWidgetChooser> createState() => _AddWidgetChooserState();
}

class _AddWidgetChooserState extends State<_AddWidgetChooser> {
  // peeking viewport so the next/previous layout shows at the edges
  final _controller = PageController(viewportFraction: 0.74);
  int _page = 0;

  static const _labels = ["Compact", "Board"];
  static const _which = ["compact", "board"];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _mock(int i) => i == 0
      ? _CompactMock(from: widget.from, to: widget.to)
      : _ReturMock(from: widget.from, to: widget.to);

  @override
  Widget build(BuildContext context) {
    final accent =
        Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve(
              {},
            ) ??
            Theme.of(context).colorScheme.primary;
    return widget.canPin ? _carousel(context) : _guide(context, accent);
  }

  Widget _carousel(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          // PageView needs a bounded height; this lets the sheet size to content
          height: MediaQuery.sizeOf(context).height * 0.42,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: _labels.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Expanded(child: Center(child: _mock(i))),
                      const SizedBox(height: 10),
                      Text(_labels[i],
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        ElevatedButton(
          onPressed: () => WidgetPin.request(_which[_page]),
          child: const Padding(
            padding: EdgeInsets.all(15),
            child: Text("Add widget"),
          ),
        ),
      ],
    );
  }

  // iOS / unsupported: can't pre-select, so point to the walkthrough.
  Widget _guide(BuildContext context, Color accent) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Add a widget",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          const Text(
            "Close the app to add your journey as a widget on your Home Screen",
            style: TextStyle(height: 1.4),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => showWidgetWalkthrough(context),
            style: TextButton.styleFrom(
              foregroundColor: accent,
              padding: const EdgeInsets.all(0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerLeft,
            ),
            child: const Text("How to add a widget?"),
          ),
          Text(
            "You can always view this later in Settings",
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
