import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../domain/journal_entry.dart';
import '../domain/mood.dart';

/// Journal + mood check-ins. Private by design: RLS limits every row to its
/// owner, and analytics never sees text (CLAUDE.md).
abstract interface class JournalRepository {
  Future<List<JournalEntry>> entries();

  /// Insert or update (client-generated id).
  Future<JournalEntry> save(JournalEntry entry);
  Future<void> delete(String id);

  /// Check-ins from the last [days] days, newest first.
  Future<List<MoodEntry>> moods({int days = 60});
  Future<MoodEntry> addMood({
    required int level,
    required List<MoodWord> feelings,
    String? note,
  });
}

class SupabaseJournalRepository implements JournalRepository {
  SupabaseJournalRepository(this._db);
  final SupabaseClient _db;

  @override
  Future<List<JournalEntry>> entries() async {
    final rows = await _db
        .from('journal_entries')
        .select('id,kind,prompt,body,mood_level,created_at,updated_at')
        .order('created_at', ascending: false)
        .limit(200);
    return [for (final r in rows) JournalEntry.fromRow(r)];
  }

  @override
  Future<JournalEntry> save(JournalEntry e) async {
    final row = await _db
        .from('journal_entries')
        .upsert({
          'id': e.id,
          'kind': e.kind.name,
          'prompt': e.prompt,
          'body': e.body,
          'mood_level': e.moodLevel,
          'created_at': e.createdAt.toUtc().toIso8601String(),
        })
        .select('id,kind,prompt,body,mood_level,created_at,updated_at')
        .single();
    return JournalEntry.fromRow(row);
  }

  @override
  Future<void> delete(String id) async {
    await _db.from('journal_entries').delete().eq('id', id);
  }

  @override
  Future<List<MoodEntry>> moods({int days = 60}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final rows = await _db
        .from('mood_entries')
        .select('id,level,feelings,note,created_at')
        .gte('created_at', since.toUtc().toIso8601String())
        .order('created_at', ascending: false);
    return [for (final r in rows) MoodEntry.fromRow(r)];
  }

  @override
  Future<MoodEntry> addMood({
    required int level,
    required List<MoodWord> feelings,
    String? note,
  }) async {
    final row = await _db
        .from('mood_entries')
        .insert({
          'id': const Uuid().v4(),
          'level': level,
          'feelings': [for (final f in feelings) f.name],
          'note': (note?.trim().isEmpty ?? true) ? null : note!.trim(),
        })
        .select('id,level,feelings,note,created_at')
        .single();
    return MoodEntry.fromRow(row);
  }
}

final journalRepositoryProvider = Provider<JournalRepository>(
  (ref) => SupabaseJournalRepository(ref.watch(supabaseClientProvider)),
);

final journalEntriesProvider = FutureProvider.autoDispose<List<JournalEntry>>(
  (ref) => ref.watch(journalRepositoryProvider).entries(),
);

final moodEntriesProvider = FutureProvider.autoDispose<List<MoodEntry>>(
  (ref) => ref.watch(journalRepositoryProvider).moods(),
);
