import 'package:flutter/material.dart';

/// Hand-rolled (raw pointer events) to avoid the Material slider's drag lag.
class SnappingSlider extends StatelessWidget {
  const SnappingSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.snapAt,
    required this.onChanged,
    this.onChangeEnd,
    this.snapRange = 0.2,
  });

  final double value;
  final double min;
  final double max;
  final double snapAt;
  final double snapRange;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  static const _thumbRadius = 11.0;
  static const _height = 40.0;

  double _valueAt(double dx, double width) {
    final usable = width - _thumbRadius * 2;
    final t = ((dx - _thumbRadius) / usable).clamp(0.0, 1.0);
    return min + t * (max - min);
  }

  double _snap(double v) => (v - snapAt).abs() < snapRange ? snapAt : v;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final trackGray = Color.alphaBlend(scheme.onSurface.withValues(alpha: 0.2),
        scheme.surfaceContainerHighest);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) =>
              onChanged(_snap(_valueAt(e.localPosition.dx, width))),
          onPointerMove: (e) =>
              onChanged(_snap(_valueAt(e.localPosition.dx, width))),
          onPointerUp: (_) => onChangeEnd?.call(_snap(value)),
          child: CustomPaint(
            size: Size(width, _height),
            painter: _SliderPainter(
              fraction: ((value - min) / (max - min)).clamp(0.0, 1.0),
              snapFraction: (snapAt - min) / (max - min),
              thumbRadius: _thumbRadius,
              active:
                  Color.lerp(scheme.secondaryContainer, scheme.primary, 0.3)!,
              thumb: scheme.primary,
              inactive: trackGray,
              marker: trackGray,
            ),
          ),
        );
      },
    );
  }
}

class _SliderPainter extends CustomPainter {
  _SliderPainter({
    required this.fraction,
    required this.snapFraction,
    required this.thumbRadius,
    required this.active,
    required this.thumb,
    required this.inactive,
    required this.marker,
  });

  final double fraction;
  final double snapFraction;
  final double thumbRadius;
  final Color active;
  final Color thumb;
  final Color inactive;
  final Color marker;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final left = thumbRadius;
    final right = size.width - thumbRadius;
    final usable = right - left;
    final thumbX = left + fraction * usable;
    final markerX = left + snapFraction * usable;

    const trackHeight = 4.0;
    final radius = Radius.circular(trackHeight / 2);
    final top = cy - trackHeight / 2;
    final bottom = cy + trackHeight / 2;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(markerX, cy), width: 2, height: 16),
      Paint()..color = marker,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(left, top, right, bottom, radius),
      Paint()..color = inactive,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(left, top, thumbX, bottom, radius),
      Paint()..color = active,
    );
    canvas.drawCircle(Offset(thumbX, cy), thumbRadius, Paint()..color = thumb);
  }

  @override
  bool shouldRepaint(_SliderPainter old) =>
      old.fraction != fraction ||
      old.snapFraction != snapFraction ||
      old.active != active ||
      old.thumb != thumb ||
      old.inactive != inactive ||
      old.marker != marker;
}
