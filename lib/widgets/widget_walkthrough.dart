import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:retur/utils/journey_store.dart';
import 'package:retur/utils/transportmodes.dart';
import 'package:retur/utils/widget_pin.dart';
import 'package:retur/widgets/modal_wrapper.dart';

// Palette — grouped so a future theme can drive these. The "app" group tracks
// Retur's own surfaces; the "iOS mock" group fakes the system UI (device,
// wallpaper, sheets) and is independent of the app theme.
const _accent = Color(0xFF519AFF);
const _surface = Color(0xFF212025); // Retur widget background
const _widgetDivider = Color(0xFF4D4E5B); // dot→pin connector
const _widgetTimePill = Color(0x4052535D); // departure-time chip

const _deviceFrame = Color(0xFF3C3C40); // titanium band
const _deviceEdge = Color(0xFF8E8E93); // bright outer edge
const _wallpaperTop = Color(0xFF66666B);
const _wallpaperBottom = Color(0xFF45454A);
const _sheetBg = Color(0xFF2C2C30); // bottom-sheet material
const _menuBg = Color(0xF0353537); // context-menu material
const _editPill = Color(0xB3D4D4D8); // frosted Edit button
const _editPillLabel = Color(0xFF1C1C1E); // dark label on light material

// Full-device width:height of a modern iPhone (e.g. 16 Pro Max ≈ 77.6/163).
const _kPhoneAspect = 0.478;

/// The iOS add-widget flow only diverges at one step (opening the gallery):
/// ≤17 taps a "+", 18+ taps "Edit" then "Add Widget" from a menu. Everything
/// else is shared, so we pick the flow per OS version and reuse the rest.
enum AddWidgetFlow { iosModern, iosLegacy }

AddWidgetFlow iosFlowForThisDevice() {
  final match = RegExp(r'(\d+)').firstMatch(Platform.operatingSystemVersion);
  final major = match == null ? 0 : int.parse(match.group(1)!);
  return major >= 18 ? AddWidgetFlow.iosModern : AddWidgetFlow.iosLegacy;
}

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

/// Opens the walkthrough as its own page.
Future<void> showWidgetWalkthrough(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text("How to add a widget")),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, c) {
                // as large as fits the available box
                final w = math.min(c.maxWidth, c.maxHeight * _kPhoneAspect);
                return Center(
                  child: SizedBox(
                    width: w,
                    child: WidgetWalkthrough(flow: iosFlowForThisDevice()),
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
            child: const Text("How to add a widget"),
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

/// Looping, minimalist animation showing how to add the Retur widget to the iOS
/// Home Screen. Pure Flutter so it inherits the app theme and the real widget look.
class WidgetWalkthrough extends StatefulWidget {
  const WidgetWalkthrough({super.key, required this.flow});

  final AddWidgetFlow flow;

  @override
  State<WidgetWalkthrough> createState() => _WidgetWalkthroughState();
}

class _WidgetWalkthroughState extends State<WidgetWalkthrough>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late List<_Seg> _segs;
  late Map<String, _Span> _spans;
  late int _total;

  // Phone aspect (h/w) so a move's distance is measured in real on-screen terms.
  static const double _aspect = 1 / _kPhoneAspect;
  // Fingertip speed (fraction-distance per ms) — constant across every move.
  static const double _speed = 0.0007;
  // Floor so very short moves (e.g. Edit → Add Widget) stay readable, not a flick.
  static const int _minMove = 750;

  @override
  void initState() {
    super.initState();
    _buildTimeline();
    _c = AnimationController(
        vsync: this, duration: Duration(milliseconds: _total))
      ..repeat();
  }

  @override
  void didUpdateWidget(WidgetWalkthrough old) {
    super.didUpdateWidget(old);
    if (old.flow != widget.flow) {
      _buildTimeline();
      _c.duration = Duration(milliseconds: _total);
      _c
        ..reset()
        ..repeat();
    }
  }

  // Ordered segments. A `move` lasts distance/speed (so the finger always travels
  // at the same pace); a `dwell` is a fixed pause (hold, tap, sheet animation).
  // The modern flow inserts the Edit-menu beat; everything else is shared.
  void _buildTimeline() {
    final modern = widget.flow == AddWidgetFlow.iosModern;
    const start = Offset(0.5, 0.62);
    const home = Offset(0.5, 0.36);
    const button = Offset(0.14, 0.04);
    // top "Add Widget" item, not popup center
    const menuItem = Offset(0.28, 0.09);
    const appRow = Offset(0.5, 0.535);
    const swipeStart = Offset(0.8, 0.68);
    // 0.58 drag == one carousel stride (1:1)
    const swipeEnd = Offset(0.22, 0.68);
    const addBtn = Offset(0.5, 0.956); // dead-center on the Add Widget button
    final parked = modern ? menuItem : button;

    _segs = [
      _Seg('enter', start, home, true, 0),
      _Seg('hold', home, home, false, 1300),
      _Seg('toButton', home, button, true, 0),
      _Seg('tapButton', button, button, false, 450),
      if (modern) _Seg('menuMove', button, menuItem, true, 0),
      if (modern) _Seg('tapMenu', menuItem, menuItem, false, 450),
      // gallery already presenting; brief settle
      _Seg('sheetUp', parked, parked, false, 250),
      // "Retur" types in (finger hidden)
      _Seg('search', appRow, appRow, false, 1100),
      _Seg('pickApp', appRow, appRow, false, 1000),
      _Seg('sizesGlide', appRow, swipeStart, true, 0),
      _Seg('sizesSwipe', swipeStart, swipeEnd, true, 0),
      _Seg('sizesDwell', swipeEnd, swipeEnd, false, 400),
      _Seg('tapAddMove', swipeEnd, addBtn, true, 0),
      _Seg('tapAdd', addBtn, addBtn, false, 450),
      _Seg('drop', addBtn, addBtn, false, 1100),
      _Seg('done', addBtn, addBtn, false, 1000),
    ];

    _spans = {};
    var at = 0;
    for (final s in _segs) {
      final dur = s.isMove
          ? math.max(_minMove, (_dist(s.from, s.to) / _speed).round())
          : s.dwellMs;
      _spans[s.name] = _Span(at.toDouble(), (at + dur).toDouble());
      at += dur;
    }
    _total = at;
  }

  double _dist(Offset a, Offset b) => math
      .sqrt(math.pow(b.dx - a.dx, 2) + math.pow((b.dy - a.dy) * _aspect, 2));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  bool _has(String name) => _spans.containsKey(name);

  // Eased progress (0..1) through a named phase at the current elapsed time.
  double _p(double ms, String name, {Curve curve = Curves.easeInOut}) {
    final s = _spans[name];
    if (s == null) return 0;
    return _seg(ms, s.start, s.end, curve: curve);
  }

  double _seg(double ms, double start, double end,
      {Curve curve = Curves.easeInOut}) {
    if (ms <= start) return 0;
    if (ms >= end) return 1;
    return curve.transform((ms - start) / (end - start));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final ms = _c.value * _total;
        return AspectRatio(
          aspectRatio: _kPhoneAspect,
          child: LayoutBuilder(
            builder: (context, c) =>
                RepaintBoundary(child: _phone(ms, c.maxWidth, c.maxHeight)),
          ),
        );
      },
    );
  }

  Widget _phone(double ms, double w, double h) {
    final modern = _has('menuMove');
    // the instant the (popup's) Add Widget / the legacy + is tapped
    final galleryOpenAt =
        (modern ? _spans['tapMenu']! : _spans['tapButton']!).start + 60;

    // ---- fingertip: every segment eases the same way; moves run at one speed ---
    var seg = _segs.first;
    for (final s in _segs) {
      if (ms >= _spans[s.name]!.start) {
        seg = s;
      } else {
        break;
      }
    }
    final sp = _spans[seg.name]!;
    final local =
        sp.end > sp.start ? ((ms - sp.start) / (sp.end - sp.start)) : 1.0;
    final fp = Offset.lerp(
        seg.from, seg.to, Curves.easeInOut.transform(local.clamp(0.0, 1.0)))!;

    // hold ring fills during the long-press, then clears as the finger leaves
    final holdEnd = _spans['hold']!.end;
    final hold = ms < holdEnd ? _p(ms, 'hold', curve: Curves.easeOut) : 0.0;

    // a quick ripple pulse at each tap's instant; the result taps later (+350),
    // where the finger fades back in
    double ripple = 0;
    const tapAt = {
      'tapButton': 60,
      'tapMenu': 60,
      'pickApp': 350,
      'tapAdd': 60
    };
    tapAt.forEach((name, off) {
      final s = _spans[name];
      if (s != null) {
        final t0 = s.start + off;
        if (ms >= t0 && ms < t0 + 320) {
          ripple = _seg(ms, t0, t0 + 320, curve: Curves.linear);
        }
      }
    });

    // pointer visibility: fade in at the start, out as the sheet rises, back in
    // over the result, out on drop
    double opacity;
    if (ms < galleryOpenAt + 120) {
      opacity = _seg(ms, 0, 180); // visible while approaching + tapping
    } else if (ms < _spans['pickApp']!.start) {
      opacity = 1 -
          _seg(ms, galleryOpenAt + 120, galleryOpenAt + 380,
              curve: Curves.easeIn); // fade out as the gallery rises
    } else if (ms < _spans['drop']!.start) {
      opacity =
          _seg(ms, _spans['pickApp']!.start, _spans['pickApp']!.start + 250);
    } else {
      opacity = 1 -
          _seg(ms, _spans['drop']!.start, _spans['drop']!.start + 200,
              curve: Curves.easeIn);
    }

    // ---- element states --------------------------------------------------
    final dropStart = _spans['drop']!.start;
    final editStart =
        holdEnd; // pill appears exactly as the long-press completes
    final btnTapAt = _spans['tapButton']!.start + 60; // the instant it's tapped
    // appears on long-press, then collapses into the corner the instant it's
    // tapped; (18+) the popup springs from / back into that same corner
    final btn =
        _seg(ms, editStart, editStart + 280, curve: Curves.easeOutBack) *
            (1 - _seg(ms, btnTapAt, btnTapAt + 180, curve: Curves.easeIn));
    final menuScale = modern
        ? _seg(ms, btnTapAt, btnTapAt + 220, curve: Curves.easeOutBack) *
            (1 -
                _seg(ms, _spans['tapMenu']!.start + 60,
                    _spans['tapMenu']!.start + 240,
                    curve: Curves.easeIn))
        : 0.0;
    // the gallery presents the instant Add Widget is tapped, then dismisses
    // fast (like a real modal) as the widget drops onto the grid
    final sheet =
        (_seg(ms, galleryOpenAt, galleryOpenAt + 350, curve: Curves.easeOut) -
                _seg(ms, dropStart, dropStart + 250, curve: Curves.easeIn))
            .clamp(0.0, 1.0);
    // a brand-new size-picker sheet slides up from the bottom with the exact
    // same motion as the first sheet, the instant the Retur result is tapped
    // (its ripple at +350), and dismisses with it on drop
    final returTapAt = _spans['pickApp']!.start + 350;
    final sizeSlide =
        (_seg(ms, returTapAt, returTapAt + 350, curve: Curves.easeOut) -
                _seg(ms, dropStart, dropStart + 250, curve: Curves.easeIn))
            .clamp(0.0, 1.0);
    // same easing/progress as the finger's swipe → carousel tracks it 1:1
    final swipe = _p(ms, 'sizesSwipe', curve: Curves.easeInOut);
    final dropped =
        _seg(ms, dropStart + 150, dropStart + 650, curve: Curves.easeOutBack);

    // "Retur" types into the search over the first ~0.7s, then the result fades in
    final searchStart = _spans['search']!.start;
    final typed =
        (_seg(ms, searchStart, searchStart + 700, curve: Curves.linear) * 5)
            .round()
            .clamp(0, 5);
    final searchStr = 'Retur'.substring(0, typed);
    final cursorOn = ms >= searchStart && ms < _spans['pickApp']!.start;
    final resultOpacity = _seg(ms, searchStart + 650, _spans['search']!.end,
        curve: Curves.easeOut);

    // Layered frame like a real iPhone / the iOS Simulator: a thin bright
    // outer edge, a dark-gray titanium band, then a black rim around the screen.
    return Container(
      decoration: BoxDecoration(
        color: _deviceFrame,
        borderRadius: BorderRadius.circular(w * 0.145),
        border: Border.all(color: _deviceEdge, width: 1),
      ),
      padding: EdgeInsets.all(w * 0.014),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(w * 0.131),
        ),
        padding: EdgeInsets.all(w * 0.012),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(w * 0.119),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_wallpaperTop, _wallpaperBottom],
              ),
            ),
            // measure the actual screen (inside the frame) so everything is
            // positioned and sized relative to it, not the outer device box
            child: LayoutBuilder(builder: (context, sc) {
              final w = sc.maxWidth;
              final h = sc.maxHeight;
              final pointer = Offset(fp.dx * w, fp.dy * h);
              final r = w * 0.058;
              return Stack(
                children: [
                  // Dynamic Island (iOS 18+) or the wider notch (iOS ≤17)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: modern ? h * 0.016 : 0),
                      child: Container(
                        width: modern ? w * 0.3 : w * 0.5,
                        height: modern ? w * 0.075 : w * 0.06,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: modern
                              ? BorderRadius.circular(w * 0.05)
                              : BorderRadius.vertical(
                                  bottom: Radius.circular(w * 0.045)),
                        ),
                      ),
                    ),
                  ),
                  // home-screen dock: a frosted bar behind the bottom row of icons
                  Positioned(
                    left: w * 0.035,
                    right: w * 0.035,
                    top: h - w * 0.28,
                    height: w * 0.24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(w * 0.085),
                      ),
                    ),
                  ),
                  // page-indicator dots just above the dock (current page brighter)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: h - w * 0.34,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < 3; i++)
                            Container(
                              width: w * 0.014,
                              height: w * 0.014,
                              margin:
                                  EdgeInsets.symmetric(horizontal: w * 0.009),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white
                                    .withValues(alpha: i == 0 ? 0.7 : 0.25),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  for (int i = 0; i < 4; i++)
                    Positioned(
                      left: w *
                          (0.08 + i * 0.2267), // even, side margin == w*0.08
                      top: h -
                          w * 0.24, // near the bottom, bottom margin == side margin
                      child: Container(
                        width: w * 0.16,
                        height: w * 0.16,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(w * 0.04),
                        ),
                      ),
                    ),

                  if (dropped > 0)
                    Positioned(
                      left: w * 0.1,
                      top: h * 0.12,
                      width: w * 0.42, // square 2x2 widget footprint
                      height: w * 0.42,
                      child: Transform.scale(
                          scale: dropped, child: const _ReturMock()),
                    ),

                  // iOS-style Edit pill in the status bar, left of the island
                  Positioned(
                    left: w * 0.06,
                    top: h * 0.016,
                    child: Transform.scale(
                      scale: btn.clamp(0.0, 1.0),
                      alignment:
                          Alignment.topLeft, // collapse toward the corner
                      child: Container(
                        width: w * 0.16,
                        height: w * 0.075,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _editPill,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(modern ? "Edit" : "+",
                            style: const TextStyle(
                                color: _editPillLabel,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none)),
                      ),
                    ),
                  ),

                  if (modern)
                    Positioned(
                      left: w * 0.07,
                      top: h * 0.07,
                      child: Transform.scale(
                        scale: menuScale.clamp(0.0, 1.1),
                        alignment: Alignment
                            .topLeft, // spring from / collapse into the corner
                        child: Opacity(
                            opacity: menuScale.clamp(0.0, 1.0),
                            child: _menuCard(w)),
                      ),
                    ),

                  // the search/gallery modal
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: h * 0.6,
                    child: Transform.translate(
                      offset: Offset(0, (1 - sheet) * h * 0.6),
                      child: _sheet(
                        w,
                        h,
                        child: _searchContent(
                            w, h, searchStr, cursorOn, resultOpacity),
                      ),
                    ),
                  ),

                  // a separate size-picker modal that presents on top when Retur is tapped
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: h * 0.6,
                    child: Transform.translate(
                      offset: Offset(0, (1 - sizeSlide) * h * 0.6),
                      child: _sheet(w, h, child: _sizeContent(w, h, swipe)),
                    ),
                  ),

                  Positioned(
                    left: pointer.dx - r,
                    top: pointer.dy - r,
                    child: Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: CustomPaint(
                        size: Size(r * 2, r * 2),
                        painter: _PointerPainter(
                            hold: hold.clamp(0.0, 1.0),
                            ripple: ripple.clamp(0.0, 1.0)),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _menuCard(double w) {
    Widget item(String label, bool highlight) => Container(
          width: w * 0.42,
          padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: 7),
          // pressed-row highlight is a light gray on iOS, not a tint
          color: highlight ? Colors.white.withValues(alpha: 0.12) : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      decoration: TextDecoration.none)),
              Icon(
                  label == "Add Widget"
                      ? Icons.add_box_outlined
                      : Icons.edit_outlined,
                  color: Colors.white70,
                  size: 13),
            ],
          ),
        );
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: _menuBg,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          item("Add Widget", true),
          Container(height: 0.5, color: Colors.white24),
          item("Edit Pages", false),
        ]),
      ),
    );
  }

  // Shared modal-sheet chrome (rounded top, drag handle, bg) — both the search
  // gallery and the size picker are presented in an identical shell.
  Widget _sheet(double w, double h, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: _sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(w * 0.08)),
      ),
      padding: EdgeInsets.fromLTRB(w * 0.07, h * 0.016, w * 0.07, h * 0.02),
      child: Column(
        children: [
          Container(
            width: w * 0.12,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.white30, borderRadius: BorderRadius.circular(2)),
          ),
          SizedBox(height: h * 0.016),
          Expanded(child: child),
        ],
      ),
    );
  }

  // Gallery modal body: the search field + the "Retur" result row.
  Widget _searchContent(
      double w, double h, String searchStr, bool cursor, double resultOpacity) {
    return Column(
      children: [
        Container(
          height: h * 0.042,
          padding: EdgeInsets.symmetric(horizontal: w * 0.04),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.white54, size: 14),
              const SizedBox(width: 6),
              Text(searchStr,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      decoration: TextDecoration.none)),
              if (cursor)
                Container(
                    width: 1.5,
                    height: h * 0.022,
                    margin: const EdgeInsets.only(left: 1),
                    color: _accent),
            ],
          ),
        ),
        SizedBox(height: h * 0.02),
        Expanded(child: Opacity(opacity: resultOpacity, child: _appRow(w))),
      ],
    );
  }

  // Size-picker modal body: the size carousel + the Add Widget button.
  Widget _sizeContent(double w, double h, double swipe) {
    return Column(
      children: [
        Expanded(child: _sizeCarousel(w, swipe)),
        SizedBox(height: h * 0.012),
        _addWidgetButton(h),
      ],
    );
  }

  Widget _addWidgetButton(double h) {
    return Container(
      width: double.infinity,
      height: h * 0.048,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: _accent, borderRadius: BorderRadius.circular(12)),
      child: const Text("Add Widget",
          style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none)),
    );
  }

  Widget _appRow(double w) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity, // fill the modal width, like an iOS list row
        padding:
            EdgeInsets.symmetric(horizontal: w * 0.03, vertical: w * 0.025),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/icon/retur_dark.png',
                  width: w * 0.1, height: w * 0.1, fit: BoxFit.cover),
            ),
            SizedBox(width: w * 0.03),
            const Text("Retur",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }

  // Centered carousel: the active size is centered, neighbours peek on each side
  // (and don't, at the first/last). `swipe` (0..1) sweeps the active index first→last.
  Widget _sizeCarousel(double w, double swipe) {
    const count = 3;
    final idx =
        swipe; // scroll one position; stride matches the finger's 0.58w drag (1:1)
    return LayoutBuilder(
      builder: (context, c) {
        final cardW = w * 0.55;
        final stride = w * 0.58;
        final offsetX = c.maxWidth / 2 - (idx * stride + cardW / 2);
        return ClipRect(
          child: Stack(
            children: [
              for (int i = 0; i < count; i++)
                Positioned(
                  left: offsetX + i * stride,
                  top: 0,
                  bottom: 0,
                  width: cardW,
                  child: Center(
                    child: Opacity(
                      opacity: (1 - (idx - i).abs()).clamp(0.35, 1.0),
                      child: const _ReturMock(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Span {
  const _Span(this.start, this.end);
  final double start;
  final double end;
}

class _Seg {
  const _Seg(this.name, this.from, this.to, this.isMove, this.dwellMs);
  final String name;
  final Offset from;
  final Offset to;
  final bool isMove; // move (duration ∝ distance) vs dwell (fixed dwellMs)
  final int dwellMs;
}

/// Schematic of the real Retur board widget (dot/pin origin-destination, mode
/// glyphs on line colors), square like the default widget; scales to fit.
class _ReturMock extends StatelessWidget {
  const _ReturMock({this.from, this.to});

  final String? from;
  final String? to;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Container(
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: _surface, borderRadius: BorderRadius.circular(18)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stopsHeader(from, to),
            const SizedBox(height: 10),
            _row('metro', '5', '08:36'),
            const SizedBox(height: 6),
            _row('tram', '11', '08:42'),
            const SizedBox(height: 6),
            _row('bus', '31', '08:48'),
          ],
        ),
      ),
    );
  }

  Widget _row(String mode, String line, String time) {
    return Row(
      children: [
        _legChip(mode, line),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
              color: _widgetTimePill, borderRadius: BorderRadius.circular(5)),
          child: Text(time,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  decoration: TextDecoration.none)),
        ),
      ],
    );
  }
}

/// dot→pin origin/destination header shared by both widget mocks.
Widget _stopsHeader(String? from, String? to) {
  return Row(
    children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/dot.svg', height: 7),
          Container(width: 1.5, height: 10, color: _widgetDivider),
          SvgPicture.asset('assets/pin.svg', height: 10),
        ],
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(from ?? "Jernbanetorget",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none)),
            Text(to ?? "Nationaltheatret",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    decoration: TextDecoration.none)),
          ],
        ),
      ),
    ],
  );
}

/// A leg chip mirroring the real widget's ModeChip: the colored mode badge
/// (white glyph + line code) sitting on the gray pill.
Widget _legChip(String mode, String line) {
  return Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
        color: _widgetTimePill, borderRadius: BorderRadius.circular(5)),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      decoration: BoxDecoration(
          color: TransportMode.getColor(mode),
          borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            TransportMode.transportAssetMap[mode] ?? '',
            height: 10,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          const SizedBox(width: 2),
          Text(line,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none)),
        ],
      ),
    ),
  );
}

/// Schematic of the compact single-departure widget: from→to header, the next
/// departure time, then the mode chip.
class _CompactMock extends StatelessWidget {
  const _CompactMock({this.from, this.to});

  final String? from;
  final String? to;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Container(
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
            color: _surface, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _stopsHeader(from, to),
            const Spacer(),
            const Text("08:36",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none)),
            const Spacer(),
            _legChip('metro', '5'),
          ],
        ),
      ),
    );
  }
}

/// Fingertip: soft dot + fill ring while holding + expanding tap ripple.
class _PointerPainter extends CustomPainter {
  _PointerPainter({required this.hold, required this.ripple});

  final double hold;
  final double ripple;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;

    if (ripple > 0) {
      canvas.drawCircle(
          center,
          r + ripple * r * 1.8,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = Colors.white.withValues(alpha: (1 - ripple) * 0.9));
    }

    canvas.drawCircle(
        center, r, Paint()..color = Colors.white.withValues(alpha: 0.85));
    canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.black.withValues(alpha: 0.15));

    if (hold > 0) {
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: r + 5),
          -math.pi / 2,
          hold * 2 * math.pi,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round
            ..color = _accent);
    }
  }

  @override
  bool shouldRepaint(_PointerPainter old) =>
      old.hold != hold || old.ripple != ripple;
}
