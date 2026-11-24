import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/no_contact.dart';

abstract interface class NoContactRepository {
  Future<NoContactState> load();

  /// Starts a run today (ends any running one first).
  Future<void> start({required int goalDays});
  Future<void> setGoal(int goalDays);

  /// "I reached out": ends the current run with an optional reflection and,
  /// when [restart] is true, starts a new run today with the same goal.
  Future<void> reachedOut({String? reflection, bool restart = true});
}

String _date(DateTime t) =>
    '${t.year.toString().padLeft(4, '0')}-'
    '${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

/// Rows in `no_contact_attempts` (RLS: own rows). The active run's start is
/// mirrored to `profiles.no_contact_since`, which the trial recap reads.
class SupabaseNoContactRepository implements NoContactRepository {
  SupabaseNoContactRepository(this._db);
  final SupabaseClient _db;

  String? get _uid => _db.auth.currentUser?.id;

  @override
  Future<NoContactState> load() async {
    final rows = await _db
        .from('no_contact_attempts')
        .select('id,started_on,ended_on,goal_days,reflection')
        .order('started_on', ascending: false)
        .limit(100);
    return NoContactState(
      attempts: [for (final r in rows) NoContactAttempt.fromRow(r)],
    );
  }

  Future<void> _mirror(String? since) async {
    final uid = _uid;
    if (uid == null) return;
    await _db
        .from('profiles')
        .update({'no_contact_since': since})
        .eq('id', uid);
  }

  Future<void> _endActive({String? reflection}) async {
    await _db
        .from('no_contact_attempts')
        .update({
          'ended_on': _date(DateTime.now()),
          'reflection': ?(reflection?.trim().isEmpty ?? true)
              ? null
              : reflection!.trim(),
        })
        .isFilter('ended_on', null);
  }

  @override
  Future<void> start({required int goalDays}) async {
    await _endActive();
    final today = _date(DateTime.now());
    await _db.from('no_contact_attempts').insert({
      'started_on': today,
      'goal_days': goalDays,
    });
    await _mirror(today);
  }

  @override
  Future<void> setGoal(int goalDays) async {
    await _db
        .from('no_contact_attempts')
        .update({'goal_days': goalDays})
        .isFilter('ended_on', null);
  }

  @override
  Future<void> reachedOut({String? reflection, bool restart = true}) async {
    final goal = (await load()).current?.goalDays ?? 30;
    await _endActive(reflection: reflection);
    if (restart) {
      await start(goalDays: goal);
    } else {
      await _mirror(null);
    }
  }
}

final noContactRepositoryProvider = Provider<NoContactRepository>(
  (ref) => SupabaseNoContactRepository(ref.watch(supabaseClientProvider)),
);

final noContactProvider = FutureProvider.autoDispose<NoContactState>(
  (ref) => ref.watch(noContactRepositoryProvider).load(),
);
