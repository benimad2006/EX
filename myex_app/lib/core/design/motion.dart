import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// MOTION — springs, durations, haptics (spec §5 / §13).
// smooth  (response 0.5, damping 1.0)  push/pop, modal, sheet in, background
//                                        scale, tab-bar hide, timeline collapse
// snappy  (response 0.4, damping 0.8)  tab capsule, plan highlight, switch,
//                                        button release, toast, digit roll
// bouncy  (response 0.45, damping 0.55) success only: radio check, purchase
//                                        check, Welcome Lumi
// Reduce Motion: slides become a 200ms crossfade; no bounce, roll or loops.
// =============================================================================

/// SwiftUI-style spring parameters (response, dampingFraction) → Flutter.
SpringDescription springFrom({
  required double response,
  required double dampingFraction,
}) {
  final stiffness = math.pow(2 * math.pi / response, 2).toDouble();
  return SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: stiffness,
    ratio: dampingFraction,
  );
}

/// A [Curve] that follows a spring from 0 to 1 over [duration].
/// Lets springs drive any implicit animation (AnimatedAlign, AnimatedScale…).
class SpringCurve extends Curve {
  SpringCurve(this.spring, this.duration)
    : _sim = SpringSimulation(spring, 0, 1, 0);

  final SpringDescription spring;
  final Duration duration;
  final SpringSimulation _sim;

  @override
  double transformInternal(double t) {
    if (t >= 1) return 1;
    final seconds =
        t * duration.inMicroseconds / Duration.microsecondsPerSecond;
    return _sim.x(seconds);
  }
}

abstract final class MyExSprings {
  static final smooth = springFrom(response: 0.5, dampingFraction: 1.0);
  static final snappy = springFrom(response: 0.4, dampingFraction: 0.8);
  static final bouncy = springFrom(response: 0.45, dampingFraction: 0.55);
}

abstract final class MyExDurations {
  static const smooth = Duration(milliseconds: 500);
  static const snappy = Duration(milliseconds: 450);
  static const bouncy = Duration(milliseconds: 650);
  static const digitRoll = Duration(milliseconds: 600);

  /// Touch-down.
  static const pressIn = Duration(milliseconds: 80);

  /// Release after press (snappy).
  static const pressOut = Duration(milliseconds: 350);

  /// Sheet / modal dismiss.
  static const dismiss = Duration(milliseconds: 300);

  /// Tab crossfade.
  static const tabFade = Duration(milliseconds: 180);

  /// Text swap on plan change.
  static const textSwap = Duration(milliseconds: 120);

  /// Reduce Motion crossfade.
  static const reducedFade = Duration(milliseconds: 200);

  /// Mood chart draw-in (once, on first show).
  static const chartDraw = Duration(milliseconds: 900);

  /// SOS breathing cycle (in + out).
  static const breath = Duration(seconds: 8);
}

abstract final class MyExCurves {
  static final smooth = SpringCurve(MyExSprings.smooth, MyExDurations.smooth);
  static final snappy = SpringCurve(MyExSprings.snappy, MyExDurations.snappy);
  static final bouncy = SpringCurve(MyExSprings.bouncy, MyExDurations.bouncy);

  /// UIKit easeOut (0,0,.58,1): touch-down, tab fade.
  static const easeOut = Cubic(0, 0, 0.58, 1);

  /// UIKit easeIn (.42,0,1,1): dismiss.
  static const easeIn = Cubic(0.42, 0, 1, 1);
}

/// Press scales.
abstract final class MyExPress {
  /// Filled buttons, hero, plan rows.
  static const filled = 0.97;

  /// Glass controls swell instead of shrinking (iOS 26 interactive glass).
  static const glass = 1.06;

  /// Tab items.
  static const tab = 0.92;
}

/// Resolved motion for the current context (honors Reduce Motion).
class MyExMotion {
  const MyExMotion._(this.reduced);

  factory MyExMotion.of(BuildContext context) =>
      MyExMotion._(MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  final bool reduced;

  Duration get smooth =>
      reduced ? MyExDurations.reducedFade : MyExDurations.smooth;
  Curve get smoothCurve => reduced ? Curves.linear : MyExCurves.smooth;

  /// Selection moves (capsule, plan highlight): instant when reduced.
  Duration get snappy => reduced ? Duration.zero : MyExDurations.snappy;
  Curve get snappyCurve => reduced ? Curves.linear : MyExCurves.snappy;

  Duration get bouncy => reduced ? Duration.zero : MyExDurations.bouncy;
  Curve get bouncyCurve => reduced ? Curves.linear : MyExCurves.bouncy;

  Duration get pressIn => reduced ? Duration.zero : MyExDurations.pressIn;
  Duration get pressOut => reduced ? Duration.zero : MyExDurations.pressOut;

  /// Press scale for filled controls (1.0 when reduced).
  double get pressScale => reduced ? 1.0 : MyExPress.filled;
  double get glassPressScale => reduced ? 1.0 : MyExPress.glass;

  /// Ambient loops (breathing, blink, typing bounce) are off when reduced.
  bool get allowLoops => !reduced;

  /// The sheet-behind scale is off when reduced.
  bool get allowPresentingScale => !reduced;
}

/// Haptics (selection on tab/plan/switch changes; double tap on success).
abstract final class MyExHaptics {
  static Future<void> selection() => HapticFeedback.selectionClick();

  /// Purchase success pattern: two taps ~90ms apart.
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.mediumImpact();
  }
}
