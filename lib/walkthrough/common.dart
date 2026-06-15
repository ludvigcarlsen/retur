part of 'walkthrough.dart';

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
