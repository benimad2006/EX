/// One no-contact run, from a start day until the user reached out (or now).
class NoContactAttempt {
  const NoContactAttempt({
    required this.id,
    required this.startedOn,
    required this.goalDays,
    this.endedOn,
    this.reflection,
  });

  final String id;

  /// Local calendar day the run started.
  final DateTime startedOn;

  /// Local calendar day the user reached out (null = still running).
  final DateTime? endedOn;
  final int goalDays;

  /// Optional "what happened / what I learned" written at restart.
  final String? reflection;

  bool get active => endedOn == null;

  /// Whole days in this run (today counts from 0 on the start day).
  int days(DateTime now) => _calendarDays(startedOn, endedOn ?? now);

  factory NoContactAttempt.fromRow(Map<String, dynamic> r) => NoContactAttempt(
    id: r['id'] as String,
    startedOn: DateTime.parse(r['started_on'] as String),
    endedOn: r['ended_on'] == null
        ? null
        : DateTime.parse(r['ended_on'] as String),
    goalDays: (r['goal_days'] as num?)?.toInt() ?? 30,
    reflection: r['reflection'] as String?,
  );
}

int _calendarDays(DateTime a, DateTime b) => DateTime(
  b.year,
  b.month,
  b.day,
).difference(DateTime(a.year, a.month, a.day)).inDays.clamp(0, 1 << 30);

/// Goals offered in the challenge.
const noContactGoals = [7, 30, 60, 90];

/// Milestones shown on the challenge screen (a subset is reached per goal).
const noContactMilestones = [1, 3, 7, 14, 30, 60, 90];

class NoContactState {
  const NoContactState({required this.attempts});

  /// Newest first.
  final List<NoContactAttempt> attempts;

  NoContactAttempt? get current => attempts.where((a) => a.active).firstOrNull;

  List<NoContactAttempt> get past => [
    for (final a in attempts)
      if (!a.active) a,
  ];

  int currentDays(DateTime now) => current?.days(now) ?? 0;

  /// Every day across every run: the count that never resets (design
  /// direction: progress never resets to nothing).
  int chosenDays(DateTime now) =>
      attempts.fold(0, (sum, a) => sum + a.days(now));

  int bestRun(DateTime now) =>
      attempts.fold(0, (best, a) => a.days(now) > best ? a.days(now) : best);

  /// Milestones reached in the current run.
  List<int> reachedMilestones(DateTime now) => [
    for (final m in noContactMilestones)
      if (currentDays(now) >= m) m,
  ];

  /// The next milestone (or the goal when it comes first).
  int nextTarget(DateTime now) {
    final d = currentDays(now);
    final goal = current?.goalDays ?? 30;
    if (d < goal) {
      final m = noContactMilestones.firstWhere(
        (m) => m > d,
        orElse: () => goal,
      );
      return m < goal ? m : goal;
    }
    return noContactMilestones.firstWhere((m) => m > d, orElse: () => d + 30);
  }
}
