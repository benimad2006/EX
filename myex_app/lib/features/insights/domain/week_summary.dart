import '../../journal/domain/mood.dart';

enum WeekTrend { lighter, heavier, steady, unknown }

/// This week (last 7 days) vs the 7 days before. Pure (unit tested).
class WeekSummary {
  const WeekSummary({
    required this.checkIns,
    required this.trend,
    required this.topFeelings,
  });

  final int checkIns;
  final WeekTrend trend;
  final List<MoodWord> topFeelings;

  /// Average difference smaller than this is "steady".
  static const steadyBand = 0.25;

  factory WeekSummary.of(List<MoodEntry> entries, DateTime now) {
    final today = dayOf(now);
    final weekStart = today.subtract(const Duration(days: 6));
    final prevStart = today.subtract(const Duration(days: 13));
    final thisWeek = [
      for (final e in entries)
        if (!dayOf(e.createdAt).isBefore(weekStart)) e,
    ];
    final lastWeek = [
      for (final e in entries)
        if (!dayOf(e.createdAt).isBefore(prevStart) &&
            dayOf(e.createdAt).isBefore(weekStart))
          e,
    ];
    double avg(List<MoodEntry> l) =>
        l.fold<int>(0, (s, e) => s + e.level) / l.length;
    final trend = thisWeek.isEmpty || lastWeek.isEmpty
        ? WeekTrend.unknown
        : switch (avg(thisWeek) - avg(lastWeek)) {
            final d when d > steadyBand => WeekTrend.lighter,
            final d when d < -steadyBand => WeekTrend.heavier,
            _ => WeekTrend.steady,
          };
    return WeekSummary(
      checkIns: thisWeek.length,
      trend: trend,
      topFeelings: mostFrequentFeelings(thisWeek),
    );
  }
}
