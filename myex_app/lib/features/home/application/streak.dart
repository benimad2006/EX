import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../no_contact/data/no_contact_repository.dart';

/// No-contact start day of the running attempt, null if not started.
/// Derived from the no-contact challenge (lib/features/no_contact/).
final noContactSinceProvider = FutureProvider.autoDispose<DateTime?>(
  (ref) async => (await ref.watch(noContactProvider.future)).current?.startedOn,
);

/// Whole days since [since] (local calendar days).
int streakDays(DateTime since, DateTime now) => DateTime(
  now.year,
  now.month,
  now.day,
).difference(DateTime(since.year, since.month, since.day)).inDays;

/// Next milestone for the hero progress bar.
const streakMilestones = [7, 14, 30, 60, 90, 180, 365];

int nextStreakMilestone(int days) =>
    streakMilestones.firstWhere((m) => m > days, orElse: () => days + 30);

/// Starts the streak today with the default 30-day goal.
final startStreakProvider = Provider<Future<void> Function({int goalDays})>(
  (ref) => ({int goalDays = 30}) async {
    await ref.read(noContactRepositoryProvider).start(goalDays: goalDays);
    ref.invalidate(noContactProvider);
  },
);
