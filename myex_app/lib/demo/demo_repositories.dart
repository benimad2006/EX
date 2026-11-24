import 'dart:async';

import '../features/coach/data/coach_repository.dart';
import '../features/coach/domain/chat_message.dart';
import '../features/coach/domain/chat_origin.dart';
import '../features/draft_jail/data/draft_repository.dart';
import '../features/draft_jail/domain/draft.dart';
import '../features/journal/data/journal_repository.dart';
import '../features/journal/domain/journal_entry.dart';
import '../features/journal/domain/mood.dart';
import '../features/lifecycle/data/lifecycle_repository.dart';
import '../features/lifecycle/domain/reminder_plan.dart';
import '../features/monetization/data/wallet_repository.dart';
import '../features/monetization/domain/coin_pack.dart';
import '../features/monetization/domain/limits.dart';
import '../features/monetization/domain/monetization_ids.dart';
import '../features/no_contact/data/no_contact_repository.dart';
import '../features/no_contact/domain/no_contact.dart';
import '../features/onboarding/data/onboarding_repository.dart';
import '../features/onboarding/domain/onboarding_answers.dart';
import '../features/plan/data/plan_repository.dart';
import '../features/plan/domain/plan_models.dart';
import '../features/subscription/data/subscription_repository.dart';
import '../features/subscription/domain/cancel_survey.dart';
import 'demo_plan_catalog.dart';
import 'demo_store.dart';

// DEMO MODE ONLY. Fakes that mirror the server rules (limits, SOS bypass,
// plan gate, 24h draft lock) against the in-memory DemoStore.

const _catalog = {
  MonetizationIds.itemMsgs20: (cost: 10, qty: 20),
  MonetizationIds.itemPlanDay: (cost: 15, qty: 1),
  MonetizationIds.itemAnalysis: (cost: 30, qty: 1),
};

class DemoWalletRepository implements WalletRepository {
  DemoWalletRepository(this.store);
  final DemoStore store;

  @override
  Stream<int> balanceStream({
    Duration pollEvery = const Duration(seconds: 30),
  }) {
    late final StreamController<int> c;
    void emit() => c.add(store.coins);
    c = StreamController<int>(
      onListen: () {
        emit();
        store.addListener(emit);
      },
      onCancel: () async {
        store.removeListener(emit);
        await c.close();
      },
    );
    return c.stream;
  }

  @override
  Future<int> fetchBalance() async => store.coins;

  @override
  Future<SpendResult> spend({
    required String item,
    required String ref,
    required String idempotencyKey,
  }) async {
    final c = _catalog[item];
    if (c == null) return const SpendRejected('unknown item');
    if (store.spentKeys.contains(idempotencyKey)) {
      return SpendOk(balance: store.coins, replayed: true);
    }
    if (item == MonetizationIds.itemPlanDay) {
      if (store.isPremium) return const SpendPremiumHasAccess();
      final day = int.tryParse(ref) ?? 0;
      if (store.unlockedDays.contains(day)) return const SpendAlreadyUnlocked();
    }
    if (store.coins < c.cost) {
      return SpendInsufficient(balance: store.coins, cost: c.cost);
    }
    store.coins -= c.cost;
    store.spentKeys.add(idempotencyKey);
    if (item == MonetizationIds.itemMsgs20) store.messageCredits += c.qty;
    if (item == MonetizationIds.itemPlanDay) {
      store.unlockedDays.add(int.tryParse(ref) ?? 0);
    }
    store.changed();
    return SpendOk(balance: store.coins);
  }

  @override
  Future<LimitsState> fetchLimits() async => LimitsState(
    premium: store.isPremium,
    freeMessagesLeft: (DemoStore.freeMessages - store.messagesUsed).clamp(
      0,
      DemoStore.freeMessages,
    ),
    messageCredits: store.messageCredits,
    draftsLeft: (DemoStore.freeDrafts - store.draftsUsed).clamp(
      0,
      DemoStore.freeDrafts,
    ),
    resetsAt: store.resetsAt,
  );

  @override
  Future<Map<String, CoinCatalogItem>> fetchCatalog() async => {
    for (final e in _catalog.entries)
      e.key: CoinCatalogItem(
        item: e.key,
        cost: e.value.cost,
        grantQty: e.value.qty,
      ),
  };

  @override
  Future<Map<String, ({int coins, int bonus})>> fetchCoinPacks() async => {
    MonetizationIds.coins30: (coins: 30, bonus: 0),
    MonetizationIds.coins80: (coins: 80, bonus: 10),
    MonetizationIds.coins200: (coins: 200, bonus: 40),
  };

  @override
  Future<bool> markExitOfferShown() async {
    if (store.exitOfferShown) return false;
    store.exitOfferShown = true;
    return true;
  }

  @override
  Future<bool> premiumBonusCreditedThisMonth() async =>
      store.bonusCreditedThisMonth;

  @override
  Future<void> setRemindTrial(bool value) async {}

  @override
  Future<void> syncPurchases() async {}
}

class DemoCoachRepository implements CoachRepository {
  DemoCoachRepository(this.store, {required this.language});
  final DemoStore store;
  final String Function() language;
  var _n = 0;
  var _reply = 0;

  static const _typing = Duration(milliseconds: 1400);

  static const _en = [
    'That makes sense. Missing someone isn’t a reason to go back. What would help most in the next ten minutes?',
    'Let’s take three slow breaths first, then decide together.',
    'You’re doing the hard part right now. What did you feel first when it happened?',
    'A story is a highlight, not a whole life. What do you know about how it really felt?',
    'Writing it in Draft Jail can take the edge off. It stays unsent for 24 hours.',
  ];
  static const _tr = [
    'Çok anlaşılır. Birini özlemek geri dönmek için bir sebep değil. Önümüzdeki on dakikada sana en çok ne iyi gelir?',
    'Önce üç yavaş nefes alalım, sonra birlikte karar verelim.',
    'Şu an zor olan kısmı yapıyorsun. Olduğunda ilk ne hissettin?',
    'Bir hikâye sadece bir an, bütün bir hayat değil. Gerçekte nasıl hissettirdiğini biliyorsun.',
    'Taslak Hapsi’ne yazmak rahatlatabilir. 24 saat gönderilmeden kalır.',
  ];
  static const _sosEn = [
    'I’m here. Let’s slow down together: breathe in for four, hold, and out for six.',
    'You don’t have to decide anything right now. Name five things you can see around you.',
    'If you might hurt yourself, please call emergency services or a helpline now. You deserve real help.',
  ];
  static const _sosTr = [
    'Buradayım. Birlikte yavaşlayalım: dört sayıda nefes al, tut, altı sayıda ver.',
    'Şu an hiçbir şeye karar vermek zorunda değilsin. Etrafında görebildiğin beş şeyi say.',
    'Kendine zarar verebileceğini düşünüyorsan lütfen hemen acil servisi ya da bir yardım hattını ara.',
  ];

  @override
  Future<String> createConversation(ChatOrigin origin) async {
    final id = 'demo-conv-${_n++}';
    store.conversations[id] = origin;
    store.messages[id] = [];
    return id;
  }

  @override
  Future<List<ChatMessage>> loadMessages(
    String conversationId, {
    int limit = 50,
  }) async => List.of(store.messages[conversationId] ?? const []);

  @override
  Future<ChatMessage> send({
    required String conversationId,
    required String text,
  }) async {
    // Origin comes from the stored conversation, never from the caller.
    final origin = store.conversations[conversationId] ?? ChatOrigin.normal;
    if (origin == ChatOrigin.normal && !store.isPremium) {
      if (store.messagesUsed < DemoStore.freeMessages) {
        store.messagesUsed++;
      } else if (store.messageCredits > 0) {
        store.messageCredits--;
      } else {
        throw MessageLimitReached(resetsAt: store.resetsAt);
      }
    }
    await Future<void>.delayed(_typing);
    final tr = language() == 'tr';
    final pool = origin == ChatOrigin.sos
        ? (tr ? _sosTr : _sosEn)
        : (tr ? _tr : _en);
    final reply = ChatMessage(
      role: ChatRole.assistant,
      content: pool[_reply++ % pool.length],
    );
    store.messages[conversationId]
      ?..add(ChatMessage(role: ChatRole.user, content: text))
      ..add(reply);
    store.talks++;
    store.changed();
    return reply;
  }
}

class DemoPlanRepository implements PlanRepository {
  DemoPlanRepository(this.store, {required this.language});
  final DemoStore store;
  final String Function() language;

  PlanDayStatus _status(int day) => PlanSchedule.status(
    day: day,
    completions: {
      for (final e in store.planCompletions.entries) e.key: e.value.$1,
    },
    unlocked: store.unlockedDays,
    premium: store.isPremium,
    now: DateTime.now(),
  );

  @override
  Future<List<PlanDayTeaser>> fetchTeasers(String lang) async => [
    for (final d in demoPlanDays)
      PlanDayTeaser.fromRow({
        'day': d.$1,
        'stage': d.$2,
        'minutes': d.$3,
        'title_en': d.$4,
        'title_tr': d.$5,
        'promise_en': d.$6,
        'promise_tr': d.$7,
      }, lang),
  ];

  @override
  Future<Map<int, DateTime>> fetchCompletions() async => {
    for (final e in store.planCompletions.entries) e.key: e.value.$1,
  };

  @override
  Future<Set<int>> fetchUnlockedDays() async => Set.of(store.unlockedDays);

  @override
  Future<PlanDayDetail> getDay(int day) async {
    final d = demoPlanDays.firstWhere((x) => x.$1 == day);
    final status = _status(day);
    final tr = language() == 'tr';
    return PlanDayDetail(
      day: day,
      minutes: d.$3,
      title: tr ? d.$5 : d.$4,
      promise: tr ? d.$7 : d.$6,
      status: status,
      // Locked content never reaches the client, demo included.
      prompt: status == PlanDayStatus.locked ? null : (tr ? d.$9 : d.$8),
      entries: store.planCompletions[day]?.$2,
    );
  }

  @override
  Future<({bool ok, String? reason, DateTime? nextOpensAt})> complete(
    int day,
    List<String> entries,
  ) async {
    final s = _status(day);
    if (s != PlanDayStatus.open) {
      return (ok: false, reason: s.name, nextOpensAt: null);
    }
    store.planCompletions[day] = (DateTime.now(), List.of(entries));
    store.changed();
    return (ok: true, reason: null, nextOpensAt: store.resetsAt);
  }
}

class DemoDraftRepository implements DraftRepository {
  DemoDraftRepository(this.store);
  final DemoStore store;
  var _n = 0;

  @override
  Future<List<LockedDraft>> list() async => List.of(store.drafts.reversed);

  @override
  Future<LockOutcome> lock(String body, ChatOrigin origin) async {
    // SOS never limits (HARD RULE 1); normal: 1/day free, Premium unlimited.
    if (origin == ChatOrigin.normal && !store.isPremium) {
      if (store.draftsUsed >= DemoStore.freeDrafts) {
        return DraftLimitReached(resetsAt: store.resetsAt);
      }
      store.draftsUsed++;
    }
    final now = DateTime.now();
    final d = LockedDraft(
      id: 'demo-draft-${_n++}',
      body: body,
      origin: origin,
      createdAt: now,
      lockedUntil: now.add(draftLockDuration),
    );
    store.drafts.add(d);
    store.changed();
    return DraftLocked(id: d.id, lockedUntil: d.lockedUntil);
  }

  @override
  Future<LockOutcome> lockOnboarding(String body) async {
    final now = DateTime.now();
    final d = LockedDraft(
      id: 'demo-draft-${_n++}',
      body: body,
      origin: ChatOrigin.normal,
      createdAt: now,
      lockedUntil: now.add(draftLockDuration),
    );
    store.drafts.add(d);
    store.changed();
    return DraftLocked(id: d.id, lockedUntil: d.lockedUntil);
  }

  @override
  Future<bool> release(String id) async {
    final i = store.drafts.indexWhere((d) => d.id == id);
    if (i < 0 || store.drafts[i].isLocked(DateTime.now())) return false;
    final d = store.drafts[i];
    store.drafts[i] = LockedDraft(
      id: d.id,
      body: d.body,
      origin: d.origin,
      createdAt: d.createdAt,
      lockedUntil: d.lockedUntil,
      releasedAt: DateTime.now(),
    );
    store.changed();
    return true;
  }

  @override
  Future<void> delete(String id) async {
    store.drafts.removeWhere((d) => d.id == id);
    store.changed();
  }
}

class DemoLifecycleRepository implements LifecycleRepository {
  DemoLifecycleRepository(this.store);
  final DemoStore store;

  @override
  Future<ValueRecap> recap() async => ValueRecap(
    talks: store.talks,
    draftsNotSent: store.drafts.length,
    daysDone: store.planCompletions.length,
    streakDays: store.noContactSince == null
        ? 0
        : DateTime.now().difference(store.noContactSince!).inDays,
  );

  @override
  Future<bool> winbackEligible() async =>
      store.winbackEligible && !store.winbackShown && !store.isPremium;

  @override
  Future<bool> markWinbackShown() async {
    if (store.winbackShown) return false;
    store.winbackShown = true;
    return true;
  }

  @override
  Future<void> setTrialReminderLocalAt(DateTime? at) async {}
}

class DemoOnboardingRepository implements OnboardingRepository {
  @override
  Future<void> save(OnboardingAnswers a, {required bool completed}) async {}
  @override
  Future<OnboardingAnswers?> fetch() async => null;
}

class DemoCancelLog implements CancelSurveyLog {
  @override
  Future<void> record({
    required CancelReason reason,
    String? offerShown,
    bool offerAccepted = false,
    String? note,
  }) async {}
}

class DemoJournalRepository implements JournalRepository {
  DemoJournalRepository(this.store);
  final DemoStore store;

  @override
  Future<List<JournalEntry>> entries() async {
    final l = List.of(store.journal)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return l;
  }

  @override
  Future<JournalEntry> save(JournalEntry e) async {
    final saved = e.copyWith(updatedAt: DateTime.now());
    final i = store.journal.indexWhere((x) => x.id == e.id);
    if (i == -1) {
      store.journal.add(saved);
    } else {
      store.journal[i] = saved;
    }
    store.changed();
    return saved;
  }

  @override
  Future<void> delete(String id) async {
    store.journal.removeWhere((x) => x.id == id);
    store.changed();
  }

  @override
  Future<List<MoodEntry>> moods({int days = 60}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final l = [
      for (final m in store.moods)
        if (m.createdAt.isAfter(since)) m,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return l;
  }

  @override
  Future<MoodEntry> addMood({
    required int level,
    required List<MoodWord> feelings,
    String? note,
  }) async {
    final m = MoodEntry(
      id: store.nextId('mood'),
      level: level,
      feelings: feelings,
      note: (note?.trim().isEmpty ?? true) ? null : note!.trim(),
      createdAt: DateTime.now(),
    );
    store.moods.add(m);
    store.changed();
    return m;
  }
}

class DemoNoContactRepository implements NoContactRepository {
  DemoNoContactRepository(this.store);
  final DemoStore store;

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  Future<NoContactState> load() async =>
      NoContactState(attempts: List.of(store.attempts));

  void _endActive({String? reflection}) {
    final i = store.attempts.indexWhere((a) => a.active);
    if (i == -1) return;
    final a = store.attempts[i];
    store.attempts[i] = NoContactAttempt(
      id: a.id,
      startedOn: a.startedOn,
      endedOn: _today,
      goalDays: a.goalDays,
      reflection: (reflection?.trim().isEmpty ?? true)
          ? null
          : reflection!.trim(),
    );
  }

  @override
  Future<void> start({required int goalDays}) async {
    _endActive();
    store.attempts.insert(
      0,
      NoContactAttempt(
        id: store.nextId('nc'),
        startedOn: _today,
        goalDays: goalDays,
      ),
    );
    store.changed();
  }

  @override
  Future<void> setGoal(int goalDays) async {
    final i = store.attempts.indexWhere((a) => a.active);
    if (i == -1) return;
    final a = store.attempts[i];
    store.attempts[i] = NoContactAttempt(
      id: a.id,
      startedOn: a.startedOn,
      goalDays: goalDays,
    );
    store.changed();
  }

  @override
  Future<void> reachedOut({String? reflection, bool restart = true}) async {
    final goal = store.attempts.where((a) => a.active).firstOrNull?.goalDays;
    _endActive(reflection: reflection);
    if (restart) await start(goalDays: goal ?? 30);
    store.changed();
  }
}
