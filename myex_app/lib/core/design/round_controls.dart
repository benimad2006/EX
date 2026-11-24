import 'package:flutter/material.dart';

import 'tokens.dart';

// =============================================================================
// ROUND CONTROLS + SHEET OUTLINE — the back / close discs and the sheet edge
// from the nodo app (shared/widgets/app_back_button.dart, menu_drawer.dart
// _CloseButton, app_radio_select_sheet.dart), redrawn in MyEx's palette:
// a dark disc with a thin directional "glass edge" rim and a thin glyph.
// =============================================================================

/// The thin rim of nodo's back button: a stroke whose opacity follows the
/// light around the circle (bright top-left and bottom-right, almost nothing
/// top-right and bottom-left). Light: [MyExColors.controlEdge].
class GlassEdgePainter extends CustomPainter {
  const GlassEdgePainter({required this.color, this.width = 0.6});

  final Color color;
  final double width;

  /// The light measured on nodo's back button, every 45°, clockwise from the
  /// right, with the right repeated last.
  static const light = [0.28, 0.42, 0.28, 0.03, 0.32, 0.56, 0.32, 0.03, 0.28];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(width / 2);
    final steps = light.length - 1;
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..shader = SweepGradient(
          stops: [for (var i = 0; i <= steps; i++) i / steps],
          colors: [for (final a in light) color.withValues(alpha: a)],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(GlassEdgePainter old) =>
      old.color != color || old.width != width;
}

enum RoundGlyph { back, close }

/// Thin glyph drawn to match nodo's chevron / ✕ (1.5pt round strokes).
class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.glyph, this.color, this.rtl);
  final RoundGlyph glyph;
  final Color color;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    Offset at(double x, double y) =>
        Offset((rtl ? 1 - x : x) * s.width, y * s.height);
    switch (glyph) {
      case RoundGlyph.back:
        canvas.drawPath(
          Path()
            ..moveTo(at(0.555, 0.375).dx, at(0.555, 0.375).dy)
            ..lineTo(at(0.43, 0.5).dx, at(0.43, 0.5).dy)
            ..lineTo(at(0.555, 0.625).dx, at(0.555, 0.625).dy),
          p,
        );
      case RoundGlyph.close:
        canvas
          ..drawLine(at(0.405, 0.405), at(0.595, 0.595), p)
          ..drawLine(at(0.595, 0.405), at(0.405, 0.595), p);
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter o) =>
      o.glyph != glyph || o.color != color || o.rtl != rtl;
}

/// nodo's round control: back = flat dark disc + glass edge; close = sweep
/// rim around a soft gradient disc. [child] replaces the drawn glyph (other
/// nav icons wear the same disc).
class RoundControl extends StatelessWidget {
  const RoundControl({
    super.key,
    this.glyph,
    this.child,
    this.size = MyExSizes.roundControl,
  });

  final RoundGlyph? glyph;
  final Widget? child;
  final double size;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final glyphLayer = glyph == null
        ? Center(child: child)
        : CustomPaint(
            size: Size.square(size),
            painter: _GlyphPainter(glyph!, MyExColors.controlGlyph, rtl),
          );
    if (glyph == RoundGlyph.close) {
      final edge = MyExColors.controlEdge;
      return Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(0.75),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [
              edge.withValues(alpha: 0),
              edge.withValues(alpha: .35),
              edge.withValues(alpha: 0),
              edge.withValues(alpha: .45),
              edge.withValues(alpha: 0),
            ],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [MyExColors.controlFill, MyExColors.controlFill2],
            ),
          ),
          child: glyphLayer,
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: MyExColors.controlFill,
      ),
      foregroundDecoration: _EdgeDecoration(MyExColors.controlEdge),
      child: glyphLayer,
    );
  }
}

class _EdgeDecoration extends Decoration {
  const _EdgeDecoration(this.color);
  final Color color;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _EdgeBox(color);
}

class _EdgeBox extends BoxPainter {
  _EdgeBox(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) return;
    canvas
      ..save()
      ..translate(offset.dx, offset.dy);
    GlassEdgePainter(color: color).paint(canvas, size);
    canvas.restore();
  }
}

/// nodo's sheet outline: the rounded top edge only, pinned while content
/// scrolls.
class SheetTopBorder extends CustomPainter {
  const SheetTopBorder({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final r = radius.clamp(0.0, size.width / 2);
    final arc = Radius.circular(r - 0.5);
    final path = Path()
      ..moveTo(0.5, r)
      ..arcToPoint(Offset(r, 0.5), radius: arc)
      ..lineTo(size.width - r, 0.5)
      ..arcToPoint(Offset(size.width - 0.5, r), radius: arc);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(SheetTopBorder old) =>
      old.color != color || old.radius != radius;
}
