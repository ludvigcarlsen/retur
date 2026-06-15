part of 'walkthrough.dart';

/// Android add-widget walkthrough (stock Pixel flow): long-press → Widgets menu
/// → widget picker (search "Retur") → drag the preview onto the home screen.
class AndroidWalkthrough extends StatefulWidget {
  const AndroidWalkthrough({super.key});

  @override
  State<AndroidWalkthrough> createState() => _AndroidWalkthroughState();
}

class _AndroidWalkthroughState extends State<AndroidWalkthrough>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late List<_Seg> _segs;
  late Map<String, _Span> _spans;
  late int _total;

  static const double _aspect = 1 / _kPhoneAspect;
  static const double _speed = 0.0007;
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
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _buildTimeline() {
    const start = Offset(0.5, 0.6);
    const home = Offset(0.5, 0.42);
    const widgetsBtn = Offset(0.5, 0.88); // "Widgets" in the long-press menu
    const returRow = Offset(0.5, 0.42); // Retur row / search in the picker
    const preview = Offset(0.5, 0.62); // the expanded widget preview
    const dropTarget = Offset(0.34, 0.32); // where it lands on the grid

    _segs = [
      _Seg('enter', start, home, true, 0),
      _Seg('hold', home, home, false, 1300),
      _Seg('toWidgets', home, widgetsBtn, true, 0),
      _Seg('tapWidgets', widgetsBtn, widgetsBtn, false, 450),
      _Seg('pickerUp', returRow, returRow, false, 300),
      _Seg('search', returRow, returRow, false, 1100),
      _Seg('pickApp', returRow, returRow, false, 900),
      _Seg('toPreview', returRow, preview, true, 0),
      _Seg('grab', preview, preview, false, 600),
      _Seg('drag', preview, dropTarget, true, 0),
      _Seg('drop', dropTarget, dropTarget, false, 700),
      _Seg('done', dropTarget, dropTarget, false, 1000),
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

  double _seg(double ms, double start, double end,
      {Curve curve = Curves.easeInOut}) {
    if (ms <= start) return 0;
    if (ms >= end) return 1;
    return curve.transform((ms - start) / (end - start));
  }

  double _p(double ms, String name, {Curve curve = Curves.easeInOut}) {
    final s = _spans[name];
    if (s == null) return 0;
    return _seg(ms, s.start, s.end, curve: curve);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final ms = _c.value * _total;
        return AspectRatio(
          aspectRatio: _kPhoneAspect,
          child:
              RepaintBoundary(child: _phoneFrame((w, h) => _screen(ms, w, h))),
        );
      },
    );
  }

  Widget _screen(double ms, double w, double h) {
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
    final pointer = Offset(fp.dx * w, fp.dy * h);
    final r = w * 0.058;

    final holdEnd = _spans['hold']!.end;
    final hold = ms < holdEnd ? _p(ms, 'hold', curve: Curves.easeOut) : 0.0;

    double ripple = 0;
    const tapAt = {'tapWidgets': 60, 'pickApp': 350};
    tapAt.forEach((name, off) {
      final s = _spans[name]!;
      final t0 = s.start + off;
      if (ms >= t0 && ms < t0 + 320) {
        ripple = _seg(ms, t0, t0 + 320, curve: Curves.linear);
      }
    });

    final tapWidgetsAt = _spans['tapWidgets']!.start + 60;
    // the long-press "Widgets" menu springs up, then dismisses when tapped
    final menu = (_seg(ms, holdEnd, holdEnd + 280, curve: Curves.easeOut) -
            _seg(ms, tapWidgetsAt, tapWidgetsAt + 220, curve: Curves.easeIn))
        .clamp(0.0, 1.0);

    final grabStart = _spans['grab']!.start;
    // picker presents on tap, dismisses when the user grabs the preview
    final picker =
        (_seg(ms, tapWidgetsAt, tapWidgetsAt + 350, curve: Curves.easeOut) -
                _seg(ms, grabStart, grabStart + 250, curve: Curves.easeIn))
            .clamp(0.0, 1.0);

    final searchStart = _spans['search']!.start;
    final typed =
        (_seg(ms, searchStart, searchStart + 700, curve: Curves.linear) * 5)
            .round()
            .clamp(0, 5);
    final searchStr = 'Retur'.substring(0, typed);
    final cursorOn = ms >= searchStart && ms < _spans['pickApp']!.start;

    final pickStart = _spans['pickApp']!.start;
    final expanded =
        _seg(ms, pickStart + 350, pickStart + 650, curve: Curves.easeOut);

    final dropStart = _spans['drop']!.start;
    final dragging = ms >= grabStart && ms < dropStart;
    final dropped =
        _seg(ms, dropStart, dropStart + 400, curve: Curves.easeOutBack);
    final widgetSize = w * 0.42;

    final doneStart = _spans['done']!.start;
    double opacity;
    if (ms < tapWidgetsAt + 120) {
      opacity = _seg(ms, 0, 180);
    } else if (ms < pickStart) {
      opacity = 1 -
          _seg(ms, tapWidgetsAt + 120, tapWidgetsAt + 380,
              curve: Curves.easeIn);
    } else if (ms < doneStart) {
      opacity = _seg(ms, pickStart, pickStart + 250);
    } else {
      opacity = 1 - _seg(ms, doneStart, doneStart + 200, curve: Curves.easeIn);
    }

    return Stack(
      children: [
        _statusBar(w),
        ..._dock(w, h),
        _searchPill(w, h),
        if (dropped > 0)
          Positioned(
            left: 0.34 * w - widgetSize / 2,
            top: 0.32 * h - widgetSize / 2,
            width: widgetSize,
            height: widgetSize,
            child: Transform.scale(scale: dropped, child: const _ReturMock()),
          ),
        if (menu > 0) _widgetsMenu(w, h, menu),
        if (picker > 0)
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(0, (1 - picker) * h),
              child: _picker(w, h, searchStr, cursorOn, expanded),
            ),
          ),
        if (dragging)
          Positioned(
            left: pointer.dx - widgetSize / 2,
            top: pointer.dy - widgetSize / 2,
            width: widgetSize,
            height: widgetSize,
            child: const Opacity(opacity: 0.9, child: _ReturMock()),
          ),
        Positioned(
          left: pointer.dx - r,
          top: pointer.dy - r,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: CustomPaint(
              size: Size(r * 2, r * 2),
              painter: _PointerPainter(
                  hold: hold.clamp(0.0, 1.0), ripple: ripple.clamp(0.0, 1.0)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBar(double w) {
    return Positioned(
      top: w * 0.03,
      left: w * 0.07,
      right: w * 0.07,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("9:41",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: w * 0.032,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none)),
          Row(
            children: [
              for (int i = 0; i < 3; i++)
                Padding(
                  padding: EdgeInsets.only(left: w * 0.012),
                  child: Container(
                    width: w * 0.022,
                    height: w * 0.022,
                    decoration: const BoxDecoration(
                        color: Colors.white70, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _dock(double w, double h) {
    return [
      for (int i = 0; i < 4; i++)
        Positioned(
          left: w * (0.08 + i * 0.2267),
          top: h - w * 0.42,
          child: Container(
            width: w * 0.16,
            height: w * 0.16,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
          ),
        ),
    ];
  }

  Widget _searchPill(double w, double h) {
    return Positioned(
      left: w * 0.08,
      right: w * 0.08,
      top: h - w * 0.2,
      height: w * 0.12,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(w * 0.06),
        ),
      ),
    );
  }

  Widget _widgetsMenu(double w, double h, double t) {
    Widget button(IconData icon, String label) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: w * 0.13,
              height: w * 0.13,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(w * 0.035),
              ),
              child: Icon(icon, color: Colors.white, size: w * 0.06),
            ),
            SizedBox(height: w * 0.02),
            Text(label,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: w * 0.026,
                    decoration: TextDecoration.none)),
          ],
        );
    return Positioned(
      left: w * 0.05,
      right: w * 0.05,
      bottom: w * 0.06,
      child: Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * w * 0.3),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: w * 0.05),
            decoration: BoxDecoration(
              color: _sheetBg,
              borderRadius: BorderRadius.circular(w * 0.07),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                button(Icons.wallpaper, "Wallpaper"),
                button(Icons.widgets, "Widgets"),
                button(Icons.tune, "Home settings"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _picker(
      double w, double h, String searchStr, bool cursor, double expanded) {
    return Container(
      color: _sheetBg,
      padding: EdgeInsets.fromLTRB(w * 0.05, w * 0.05, w * 0.05, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // search field
          Container(
            height: w * 0.12,
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(w * 0.06),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.white54, size: w * 0.05),
                SizedBox(width: w * 0.02),
                Text(searchStr.isEmpty ? "Search widgets" : searchStr,
                    style: TextStyle(
                        color:
                            searchStr.isEmpty ? Colors.white38 : Colors.white,
                        fontSize: w * 0.038,
                        decoration: TextDecoration.none)),
                if (cursor)
                  Container(
                      width: 1.5,
                      height: w * 0.05,
                      margin: const EdgeInsets.only(left: 1),
                      color: _accent),
              ],
            ),
          ),
          SizedBox(height: w * 0.05),
          // Retur app row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(w * 0.025),
                child: Image.asset('assets/icon/retur_dark.png',
                    width: w * 0.1, height: w * 0.1, fit: BoxFit.cover),
              ),
              SizedBox(width: w * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Retur",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: w * 0.04,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none)),
                  Text("1 widget",
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: w * 0.03,
                          decoration: TextDecoration.none)),
                ],
              ),
            ],
          ),
          // the widget preview unfolds when the row is tapped
          ClipRect(
            child: Align(
              alignment: Alignment.topLeft,
              heightFactor: expanded,
              child: Padding(
                padding: EdgeInsets.only(top: w * 0.05),
                child: Row(
                  children: [
                    SizedBox(
                        width: w * 0.42,
                        height: w * 0.42,
                        child: const _ReturMock()),
                    SizedBox(width: w * 0.04),
                    Text("4 × 2",
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: w * 0.032,
                            decoration: TextDecoration.none)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
