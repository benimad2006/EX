import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'motion.dart';
import 'tokens.dart';
import 'typography.dart';

// =============================================================================
// ART — MyEx's illustration kit, drawn in code (no image assets):
// a night sky with twinkling stars, a crescent moon, the "dreamer" figure,
// feature medallions and the poster headline with a blush accent word.
// Every loop stops under Reduce Motion; everything is decorative and excluded
// from semantics unless a label is given.
// =============================================================================

// -----------------------------------------------------------------------------
// Stars
// -----------------------------------------------------------------------------

class _Star {
  const _Star(this.x, this.y, this.r, this.a, this.phase, this.sparkle);
  final double x, y, r, a, phase;
  final bool sparkle;
}

List<_Star> _stars(int seed, int count) {
  final rnd = math.Random(seed);
  return [
    for (var i = 0; i < count; i++)
      _Star(
        rnd.nextDouble(),
        rnd.nextDouble(),
        0.5 + rnd.nextDouble() * 1.3,
        0.25 + rnd.nextDouble() * 0.6,
        rnd.nextDouble() * math.pi * 2,
        rnd.nextDouble() < 0.07,
      ),
  ];
}

/// Scattered stars with a slow twinkle (static under Reduce Motion).
class StarField extends StatefulWidget {
  const StarField({
    super.key,
    this.count = 60,
    this.seed = 7,
    this.color,
    this.twinkle = false,
  });
  final int count;
  final int seed;
  final Color? color;

  /// Slow twinkle loop: hero scenes only (never on backgrounds), and never
  /// under Reduce Motion.
  final bool twinkle;

  @override
  State<StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<StarField>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  late final _list = _stars(widget.seed, widget.count);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.twinkle && MyExMotion.of(context).allowLoops) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _StarPainter(
            _list,
            _c.isAnimating ? _c.value : null,
            widget.color ?? MyExColors.moon,
          ),
        ),
      ),
    ),
  );
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.stars, this.t, this.color);
  final List<_Star> stars;
  final double? t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint();
    for (final s in stars) {
      final tw = t == null
          ? 1.0
          : 0.55 + 0.45 * math.sin(t! * math.pi * 2 + s.phase).abs();
      p.color = color.withValues(alpha: (s.a * tw).clamp(0, 1));
      final c = Offset(s.x * size.width, s.y * size.height);
      if (s.sparkle) {
        _sparkle(canvas, c, s.r * 3.2, p);
      } else {
        canvas.drawCircle(c, s.r, p);
      }
    }
  }

  @override
  bool shouldRepaint(_StarPainter o) => o.t != t || o.color != color;
}

/// Four-point sparkle centred on [c].
void _sparkle(Canvas canvas, Offset c, double r, Paint p) {
  final k = r * 0.22;
  final path = Path()
    ..moveTo(c.dx, c.dy - r)
    ..quadraticBezierTo(c.dx + k, c.dy - k, c.dx + r, c.dy)
    ..quadraticBezierTo(c.dx + k, c.dy + k, c.dx, c.dy + r)
    ..quadraticBezierTo(c.dx - k, c.dy + k, c.dx - r, c.dy)
    ..quadraticBezierTo(c.dx - k, c.dy - k, c.dx, c.dy - r)
    ..close();
  canvas.drawPath(path, p);
}

// -----------------------------------------------------------------------------
// Moon
// -----------------------------------------------------------------------------

/// Cream-to-peach crescent with a soft halo.
class CrescentMoon extends StatelessWidget {
  const CrescentMoon({super.key, this.size = 96});
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: _MoonPainter(MyExColors.moon),
    ),
  );
}

class _MoonPainter extends CustomPainter {
  _MoonPainter(this.moon);
  final Color moon;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width * 0.36;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      r * 1.9,
      Paint()
        ..shader = RadialGradient(
          colors: [moon.withValues(alpha: 0.28), moon.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: c, radius: r * 1.9)),
    );
    final disc = Path()..addOval(Rect.fromCircle(center: c, radius: r));
    final bite = Path()
      ..addOval(
        Rect.fromCircle(
          center: c + Offset(r * 0.48, -r * 0.22),
          radius: r * 0.9,
        ),
      );
    final crescent = Path.combine(PathOperation.difference, disc, bite);
    canvas.drawPath(
      crescent,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [moon, const Color(0xFFF2A68E)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_MoonPainter o) => o.moon != moon;
}

// -----------------------------------------------------------------------------
// The dreamer: a calm profile with flowing hair (paywall, onboarding, welcome)
// -----------------------------------------------------------------------------

/// Stylised figure, eyes closed, hair flowing down to the right. Aspect 3:4.
class DreamerFigure extends StatelessWidget {
  const DreamerFigure({super.key, this.width = 240});
  final double width;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size(width, width * 4 / 3),
      painter: _DreamerPainter(
        hairTop: MyExColors.lavender,
        hairMid: const Color(0xFFFF5C93),
        hairDeep: const Color(0xFF6E2470),
        skinLight: const Color(0xFFD98BB8),
        skinDeep: const Color(0xFF3B1642),
        rim: MyExColors.blush,
      ),
    ),
  );
}

class _DreamerPainter extends CustomPainter {
  _DreamerPainter({
    required this.hairTop,
    required this.hairMid,
    required this.hairDeep,
    required this.skinLight,
    required this.skinDeep,
    required this.rim,
  });

  final Color hairTop, hairMid, hairDeep, skinLight, skinDeep, rim;

  @override
  void paint(Canvas canvas, Size s) {
    Offset p(double x, double y) => Offset(x * s.width, y * s.height);
    void cubic(Path path, Offset a, Offset b, Offset c) =>
        path.cubicTo(a.dx, a.dy, b.dx, b.dy, c.dx, c.dy);

    final rect = Offset.zero & s;

    // Back hair mass.
    final hair = Path()..moveTo(p(0.52, 0.10).dx, p(0.52, 0.10).dy);
    cubic(hair, p(0.72, 0.02), p(0.98, 0.12), p(0.97, 0.36));
    cubic(hair, p(0.96, 0.55), p(1.06, 0.72), p(1.10, 1.02));
    hair.lineTo(p(0.40, 1.02).dx, p(0.40, 1.02).dy);
    cubic(hair, p(0.52, 0.86), p(0.58, 0.70), p(0.55, 0.56));
    cubic(hair, p(0.52, 0.42), p(0.40, 0.30), p(0.44, 0.18));
    cubic(hair, p(0.46, 0.14), p(0.49, 0.11), p(0.52, 0.10));
    hair.close();
    canvas.drawPath(
      hair,
      Paint()
        ..shader = LinearGradient(
          begin: const Alignment(-0.2, -1),
          end: const Alignment(0.6, 1),
          colors: [hairTop, hairMid, hairDeep],
          stops: const [0, 0.55, 1],
        ).createShader(rect),
    );
    _grain(canvas, hair, s, 900, Colors.white.withValues(alpha: 0.10));

    // Face, neck and shoulders (profile facing left, head slightly bowed).
    final body = Path()..moveTo(p(0.46, 0.17).dx, p(0.46, 0.17).dy);
    cubic(body, p(0.40, 0.19), p(0.37, 0.24), p(0.37, 0.28));
    cubic(body, p(0.36, 0.30), p(0.33, 0.33), p(0.315, 0.355));
    cubic(body, p(0.325, 0.365), p(0.335, 0.37), p(0.345, 0.372));
    cubic(body, p(0.34, 0.38), p(0.345, 0.39), p(0.35, 0.395));
    cubic(body, p(0.345, 0.40), p(0.35, 0.41), p(0.355, 0.415));
    cubic(body, p(0.35, 0.43), p(0.36, 0.45), p(0.38, 0.455));
    cubic(body, p(0.42, 0.47), p(0.46, 0.50), p(0.47, 0.56));
    body.lineTo(p(0.49, 0.62).dx, p(0.49, 0.62).dy);
    cubic(body, p(0.46, 0.67), p(0.34, 0.71), p(0.28, 0.80));
    body
      ..lineTo(p(0.20, 1.02).dx, p(0.20, 1.02).dy)
      ..lineTo(p(0.62, 1.02).dx, p(0.62, 1.02).dy);
    cubic(body, p(0.60, 0.80), p(0.56, 0.62), p(0.55, 0.52));
    cubic(body, p(0.54, 0.36), p(0.52, 0.22), p(0.46, 0.17));
    body.close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          end: const Alignment(0.4, 0.2),
          colors: [skinLight, skinDeep],
        ).createShader(rect),
    );
    // Rim light along the profile edge (front half only).
    canvas
      ..save()
      ..clipRect(Rect.fromLTWH(0, 0, s.width * 0.47, s.height * 0.62))
      ..drawPath(
        body,
        Paint()
          ..color = rim.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = s.width * 0.008,
      )
      ..restore();

    // Closed eye.
    final eye = Path()..moveTo(p(0.372, 0.292).dx, p(0.372, 0.292).dy);
    cubic(eye, p(0.385, 0.302), p(0.402, 0.302), p(0.412, 0.292));
    canvas.drawPath(
      eye,
      Paint()
        ..color = skinDeep
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = s.width * 0.009,
    );

    // A strand falling over the shoulder, in front of the body.
    final strand = Path()..moveTo(p(0.50, 0.13).dx, p(0.50, 0.13).dy);
    cubic(strand, p(0.58, 0.30), p(0.60, 0.55), p(0.50, 0.78));
    cubic(strand, p(0.47, 0.86), p(0.48, 0.95), p(0.52, 1.02));
    strand.lineTo(p(0.60, 1.02).dx, p(0.60, 1.02).dy);
    cubic(strand, p(0.58, 0.90), p(0.60, 0.80), p(0.62, 0.72));
    cubic(strand, p(0.68, 0.50), p(0.62, 0.25), p(0.50, 0.13));
    strand.close();
    canvas.drawPath(
      strand,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [hairTop.withValues(alpha: 0.95), hairMid],
        ).createShader(rect),
    );
    _grain(canvas, strand, s, 220, Colors.white.withValues(alpha: 0.12));
  }

  /// Fine grain inside [clip] (the textured, printed look).
  void _grain(Canvas canvas, Path clip, Size s, int n, Color c) {
    final rnd = math.Random(11);
    final paint = Paint()..color = c;
    canvas
      ..save()
      ..clipPath(clip);
    for (var i = 0; i < n; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * s.width, rnd.nextDouble() * s.height),
        0.5 + rnd.nextDouble() * 0.7,
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DreamerPainter o) =>
      o.hairTop != hairTop || o.rim != rim || o.skinLight != skinLight;
}

// -----------------------------------------------------------------------------
// Scene: moon + stars + dreamer, the poster backdrop
// -----------------------------------------------------------------------------

/// The hero scene behind a poster headline: stars, the moon top-left and the
/// dreamer on the right. Text goes over the lower-left area.
class DreamScene extends StatelessWidget {
  const DreamScene({super.key, this.height = 360, this.figure = true});
  final double height;
  final bool figure;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned.fill(
          child: StarField(count: 46, seed: 3, twinkle: true),
        ),
        Positioned(
          left: height * 0.04,
          top: height * 0.04,
          child: CrescentMoon(size: height * 0.32),
        ),
        if (figure)
          Positioned(
            right: -height * 0.06,
            top: height * 0.06,
            // Fade the lower body into the sky so there is no hard edge.
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white, Color(0x00FFFFFF)],
                stops: [0, 0.62, 1],
              ).createShader(r),
              child: DreamerFigure(width: height * 0.62),
            ),
          ),
      ],
    ),
  );
}

// -----------------------------------------------------------------------------
// Medallions
// -----------------------------------------------------------------------------

enum ArtKind { moon, rose, lock, orb, sunrise, shield, book }

/// Round painted icon (the paywall "everything included" row, feature tiles).
class ArtMedallion extends StatelessWidget {
  const ArtMedallion({super.key, required this.kind, this.size = 56});
  final ArtKind kind;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: MyExColors.bgElev,
        border: Border.all(color: MyExColors.sep),
      ),
      child: CustomPaint(
        painter: _MedallionPainter(
          kind,
          moon: MyExColors.moon,
          rose: const Color(0xFFFF5C93),
          blush: MyExColors.blush,
          lavender: MyExColors.lavender,
        ),
      ),
    ),
  );
}

class _MedallionPainter extends CustomPainter {
  _MedallionPainter(
    this.kind, {
    required this.moon,
    required this.rose,
    required this.blush,
    required this.lavender,
  });

  final ArtKind kind;
  final Color moon, rose, blush, lavender;

  @override
  void paint(Canvas canvas, Size s) {
    final c = Offset(s.width / 2, s.height / 2);
    final u = s.width / 56; // design unit
    Paint fill(Color col) => Paint()..color = col;
    switch (kind) {
      case ArtKind.moon:
        final disc = Path()
          ..addOval(Rect.fromCircle(center: c, radius: 15 * u));
        final bite = Path()
          ..addOval(
            Rect.fromCircle(center: c + Offset(7 * u, -4 * u), radius: 13 * u),
          );
        canvas.drawPath(
          Path.combine(PathOperation.difference, disc, bite),
          fill(moon),
        );
        _sparkle(canvas, c + Offset(10 * u, 6 * u), 4 * u, fill(blush));
      case ArtKind.rose:
        for (final (a, col) in [
          (-0.9, lavender),
          (0.9, lavender),
          (-0.45, blush),
          (0.45, blush),
          (0.0, rose),
        ]) {
          final petal = Path()
            ..moveTo(0, 0)
            ..cubicTo(-9 * u, -6 * u, -6 * u, -19 * u, 0, -21 * u)
            ..cubicTo(6 * u, -19 * u, 9 * u, -6 * u, 0, 0)
            ..close();
          canvas
            ..save()
            ..translate(c.dx, c.dy + 10 * u)
            ..rotate(a)
            ..drawPath(petal, fill(col.withValues(alpha: 0.92)))
            ..restore();
        }
      case ArtKind.lock:
        final body = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: c + Offset(0, 4 * u),
            width: 24 * u,
            height: 19 * u,
          ),
          Radius.circular(5 * u),
        );
        canvas
          ..drawArc(
            Rect.fromCenter(
              center: c + Offset(0, -4 * u),
              width: 15 * u,
              height: 16 * u,
            ),
            math.pi,
            math.pi,
            false,
            Paint()
              ..color = moon
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3 * u,
          )
          ..drawRRect(body, fill(moon));
        _heart(canvas, c + Offset(0, 4 * u), 5 * u, fill(rose));
      case ArtKind.orb:
        canvas.drawCircle(
          c,
          15 * u,
          Paint()
            ..shader = MyExColors.miraOrb.createShader(
              Rect.fromCircle(center: c, radius: 15 * u),
            ),
        );
        _sparkle(canvas, c + Offset(-11 * u, -11 * u), 4 * u, fill(moon));
      case ArtKind.sunrise:
        canvas
          ..save()
          ..clipRect(Rect.fromLTWH(0, 0, s.width, c.dy + 4 * u))
          ..drawCircle(
            c + Offset(0, 4 * u),
            12 * u,
            fill(const Color(0xFFFFC36B)),
          )
          ..restore();
        final ray = Paint()
          ..color = const Color(0xFFFFC36B)
          ..strokeWidth = 2.2 * u
          ..strokeCap = StrokeCap.round;
        for (var i = 0; i < 5; i++) {
          final a = math.pi + math.pi * (i + 1) / 6;
          final o = c + Offset(0, 4 * u);
          canvas.drawLine(
            o + Offset(math.cos(a) * 16 * u, math.sin(a) * 16 * u),
            o + Offset(math.cos(a) * 21 * u, math.sin(a) * 21 * u),
            ray,
          );
        }
        canvas.drawLine(
          c + Offset(-17 * u, 5 * u),
          c + Offset(17 * u, 5 * u),
          Paint()
            ..color = blush
            ..strokeWidth = 2.4 * u
            ..strokeCap = StrokeCap.round,
        );
      case ArtKind.shield:
        final sh = Path()
          ..moveTo(c.dx, c.dy - 16 * u)
          ..lineTo(c.dx + 13 * u, c.dy - 11 * u)
          ..quadraticBezierTo(c.dx + 13 * u, c.dy + 9 * u, c.dx, c.dy + 16 * u)
          ..quadraticBezierTo(
            c.dx - 13 * u,
            c.dy + 9 * u,
            c.dx - 13 * u,
            c.dy - 11 * u,
          )
          ..close();
        canvas.drawPath(sh, fill(lavender));
        _heart(canvas, c + Offset(0, 1 * u), 6 * u, fill(moon));
      case ArtKind.book:
        for (final dir in [-1.0, 1.0]) {
          final page = Path()
            ..moveTo(c.dx, c.dy - 9 * u)
            ..quadraticBezierTo(
              c.dx + dir * 8 * u,
              c.dy - 13 * u,
              c.dx + dir * 17 * u,
              c.dy - 10 * u,
            )
            ..lineTo(c.dx + dir * 17 * u, c.dy + 11 * u)
            ..quadraticBezierTo(
              c.dx + dir * 8 * u,
              c.dy + 8 * u,
              c.dx,
              c.dy + 12 * u,
            )
            ..close();
          canvas.drawPath(page, fill(dir < 0 ? moon : blush));
        }
        _heart(canvas, c + Offset(9 * u, 0), 3.5 * u, fill(rose));
    }
  }

  void _heart(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path()
      ..moveTo(c.dx, c.dy + r)
      ..cubicTo(
        c.dx - r * 1.6,
        c.dy - r * 0.2,
        c.dx - r * 0.7,
        c.dy - r * 1.4,
        c.dx,
        c.dy - r * 0.5,
      )
      ..cubicTo(
        c.dx + r * 0.7,
        c.dy - r * 1.4,
        c.dx + r * 1.6,
        c.dy - r * 0.2,
        c.dx,
        c.dy + r,
      )
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_MedallionPainter o) =>
      o.kind != kind || o.moon != moon || o.blush != blush;
}

/// Medallion with a short caption under it (the caption is the a11y label).
class LabeledMedallion extends StatelessWidget {
  const LabeledMedallion({super.key, required this.kind, required this.label});
  final ArtKind kind;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    excludeSemantics: true,
    child: SizedBox(
      width: 72,
      child: Column(
        children: [
          ArtMedallion(kind: kind),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: MyExType.caption1.copyWith(color: MyExColors.ink),
          ),
        ],
      ),
    ),
  );
}

// -----------------------------------------------------------------------------
// Poster headline
// -----------------------------------------------------------------------------

/// Bold stacked serif headline; the last [accentWords] words are blush.
class PosterHeadline extends StatelessWidget {
  const PosterHeadline(
    this.text, {
    super.key,
    this.accentWords = 1,
    this.size,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final int accentWords;
  final double? size;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final words = text.trim().split(RegExp(r'\s+'));
    final split = (words.length - accentWords).clamp(0, words.length);
    final head = words.take(split).join(' ');
    final tail = words.skip(split).join(' ');
    final base = size == null
        ? MyExType.poster
        : MyExType.poster.copyWith(fontSize: size, height: (size! + 2) / size!);
    return Semantics(
      header: true,
      label: text,
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          children: [
            if (head.isNotEmpty) TextSpan(text: '$head '),
            TextSpan(
              text: tail,
              style: TextStyle(color: MyExColors.blush),
            ),
          ],
        ),
        style: base,
        textAlign: textAlign,
      ),
    );
  }
}
