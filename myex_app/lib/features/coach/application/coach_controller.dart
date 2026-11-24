import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../monetization/domain/limits.dart';
import '../data/coach_repository.dart';
import '../domain/chat_message.dart';
import '../domain/chat_origin.dart';

final coachRepositoryProvider = Provider<CoachRepository>(
  (ref) => CoachRepository(ref.watch(supabaseClientProvider)),
);

enum CoachSendResult { sent, limitReached, failed }

@immutable
class CoachState {
  const CoachState({
    this.conversationId,
    this.messages = const [],
    this.sending = false,
    this.limitResetsAt,
  });

  final String? conversationId;
  final List<ChatMessage> messages;
  final bool sending;
  final DateTime? limitResetsAt;

  CoachState copyWith({
    String? conversationId,
    List<ChatMessage>? messages,
    bool? sending,
    DateTime? limitResetsAt,
  }) => CoachState(
    conversationId: conversationId ?? this.conversationId,
    messages: messages ?? this.messages,
    sending: sending ?? this.sending,
    limitResetsAt: limitResetsAt ?? this.limitResetsAt,
  );
}

class CoachController extends Notifier<CoachState> {
  CoachController(this.origin);

  final ChatOrigin origin;

  static const _kNormalConversation = 'coach.conversation.normal';

  CoachRepository get _repo => ref.read(coachRepositoryProvider);

  @override
  CoachState build() {
    // SOS: always a fresh conversation per SOS session (crisis-safe prompt).
    if (origin == ChatOrigin.normal) {
      final id = ref
          .read(sharedPreferencesProvider)
          .getString(_kNormalConversation);
      if (id != null) {
        _load(id);
        return CoachState(conversationId: id);
      }
    }
    return const CoachState();
  }

  Future<void> _load(String id) async {
    try {
      final msgs = await _repo.loadMessages(id);
      if (ref.mounted) state = state.copyWith(messages: msgs);
    } catch (e) {
      debugPrint('load messages failed: $e');
    }
  }

  Future<String> _ensureConversation() async {
    final existing = state.conversationId;
    if (existing != null) return existing;
    final id = await _repo.createConversation(origin);
    if (origin == ChatOrigin.normal) {
      await ref
          .read(sharedPreferencesProvider)
          .setString(_kNormalConversation, id);
    }
    if (ref.mounted) state = state.copyWith(conversationId: id);
    return id;
  }

  /// Starts a fresh conversation (normal chat only). Earlier messages stay on
  /// the server; this device just stops showing them.
  Future<void> startNew() async {
    if (origin == ChatOrigin.normal) {
      await ref.read(sharedPreferencesProvider).remove(_kNormalConversation);
    }
    if (ref.mounted) state = const CoachState();
  }

  /// Sends [text]. The caller keeps the composer text until [CoachSendResult.sent]
  /// so an unsent message is never lost.
  Future<CoachSendResult> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.sending) return CoachSendResult.failed;
    final before = state.messages;
    state = state.copyWith(
      sending: true,
      messages: [
        ...before,
        ChatMessage(role: ChatRole.user, content: trimmed),
      ],
    );
    try {
      final id = await _ensureConversation();
      final reply = await _repo.send(conversationId: id, text: trimmed);
      if (!ref.mounted) return CoachSendResult.sent;
      state = state.copyWith(
        sending: false,
        messages: [...state.messages, reply],
      );
      return CoachSendResult.sent;
    } on MessageLimitReached catch (e) {
      if (ref.mounted) {
        state = CoachState(
          conversationId: state.conversationId,
          messages: before,
          limitResetsAt: e.resetsAt,
        );
      }
      return CoachSendResult.limitReached;
    } catch (e) {
      debugPrint('mira-chat failed: $e');
      if (ref.mounted) state = state.copyWith(sending: false, messages: before);
      return CoachSendResult.failed;
    }
  }
}

final coachControllerProvider = NotifierProvider.autoDispose
    .family<CoachController, CoachState, ChatOrigin>(CoachController.new);
