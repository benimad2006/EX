import 'package:flutter/foundation.dart';

import '../features/coach/domain/chat_message.dart';
import '../features/coach/domain/chat_origin.dart';
import '../features/draft_jail/domain/draft.dart';
import '../features/journal/domain/journal_entry.dart';
import '../features/journal/domain/mood.dart';
import '../features/monetization/domain/paywall_offer.dart';
import '../features/monetization/domain/premium_state.dart';
import '../features/no_contact/domain/no_contact.dart';

/// DEMO MODE ONLY. In-memory stand-in for Supabase + RevenueCat state so the
/// whole app can be tried on a phone without any keys. Nothing persists
/// across launches except what the app itself keeps in SharedPreferences.
enum DemoTier { free, trial, monthly, annual }

class DemoStore extends ChangeNotifier {
  // ---- Entitlement ----
  DemoTier tier = DemoTier.free;
  bool willRenew = true;
  bool billingIssue = false;
  DateTime? expiresAt;
  bool hadTrial = false;
  bool hadIntro = false;
  bool bonusCreditedThisMonth = false;
  bool exitOfferShown = false;
  bool winbackShown = false;
  bool winbackEligible = false;
  PaywallVariant variant = PaywallVariant.timeline;

  // ---- Coins + limits (one demo "usage day") ----
  int coins = 20;
  int messagesUsed = 0;
  int messageCredits = 0;
  int draftsUsed = 0;
  final Set<int> unlockedDays = {};
  final Set<String> spentKeys = {};

  // ---- Product data ----
  final Map<int, (DateTime, List<String>)> planCompletions = {};
  final List<LockedDraft> drafts = [];
  final Map<String, ChatOrigin> conversations = {};
  final Map<String, List<ChatMessage>> messages = {};
  int talks = 0;

  // ---- Wellbeing (journal, mood, no contact) ----
  /// Newest first.
  final List<NoContactAttempt> attempts = [];
  final List<MoodEntry> moods = [];
  final List<JournalEntry> journal = [];
  int _ids = 0;
  String nextId(String prefix) => '$prefix-${++_ids}';

  DateTime? get noContactSince =>
      attempts.where((a) => a.active).firstOrNull?.startedOn;

  static const freeMessages = 3;
  static const freeDrafts = 1;
  static const bonusCoins = 50;

  bool get isPremium => tier != DemoTier.free && !_expired;
  bool get _expired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  PremiumState get premium {
    if (!isPremium) return const PremiumState.free();
    return PremiumState(
      isActive: true,
      isTrial: tier == DemoTier.trial,
      willRenew: willRenew,
      expiresAt: expiresAt,
      billingIssue: billingIssue,
      productId: switch (tier) {
        DemoTier.monthly => 'myex_premium_monthly',
        _ => 'myex_premium_annual',
      },
    );
  }

  /// Next 09:00 local (the daily reset).
  DateTime get resetsAt {
    final n = DateTime.now();
    final today9 = DateTime(n.year, n.month, n.day, 9);
    return n.isBefore(today9) ? today9 : today9.add(const Duration(days: 1));
  }

  void setTier(DemoTier t) {
    tier = t;
    willRenew = true;
    final now = DateTime.now();
    expiresAt = switch (t) {
      DemoTier.free => null,
      DemoTier.trial => now.add(const Duration(days: 7)),
      DemoTier.monthly => DateTime(now.year, now.month + 1, now.day, now.hour),
      DemoTier.annual => DateTime(now.year + 1, now.month, now.day, now.hour),
    };
    if (t == DemoTier.trial) hadTrial = true;
    if (t != DemoTier.free && !bonusCreditedThisMonth) {
      coins += bonusCoins;
      bonusCreditedThisMonth = true;
    }
    notifyListeners();
  }

  void toggleWillRenew() {
    willRenew = !willRenew;
    notifyListeners();
  }

  void toggleBillingIssue() {
    billingIssue = !billingIssue;
    notifyListeners();
  }

  void addCoins(int n) {
    coins += n;
    notifyListeners();
  }

  /// Simulates Premium lapsing ~10 days ago → eligible for win-back.
  void simulateLapse() {
    tier = DemoTier.free;
    expiresAt = null;
    winbackEligible = true;
    winbackShown = false;
    notifyListeners();
  }

  /// "Tomorrow": the daily limits reset and the next plan day can open.
  /// Implemented by moving every timestamp one day into the past.
  void nextDay() {
    const d = Duration(days: 1);
    for (final k in planCompletions.keys.toList()) {
      final (at, e) = planCompletions[k]!;
      planCompletions[k] = (at.subtract(d), e);
    }
    for (var i = 0; i < drafts.length; i++) {
      final x = drafts[i];
      drafts[i] = LockedDraft(
        id: x.id,
        body: x.body,
        origin: x.origin,
        createdAt: x.createdAt.subtract(d),
        lockedUntil: x.lockedUntil.subtract(d),
        releasedAt: x.releasedAt,
      );
    }
    for (var i = 0; i < attempts.length; i++) {
      final a = attempts[i];
      attempts[i] = NoContactAttempt(
        id: a.id,
        startedOn: a.startedOn.subtract(d),
        endedOn: a.endedOn?.subtract(d),
        goalDays: a.goalDays,
        reflection: a.reflection,
      );
    }
    for (var i = 0; i < moods.length; i++) {
      final m = moods[i];
      moods[i] = MoodEntry(
        id: m.id,
        level: m.level,
        feelings: m.feelings,
        note: m.note,
        createdAt: m.createdAt.subtract(d),
      );
    }
    for (var i = 0; i < journal.length; i++) {
      final j = journal[i];
      journal[i] = JournalEntry(
        id: j.id,
        kind: j.kind,
        prompt: j.prompt,
        body: j.body,
        moodLevel: j.moodLevel,
        createdAt: j.createdAt.subtract(d),
        updatedAt: j.updatedAt.subtract(d),
      );
    }
    if (expiresAt != null && tier != DemoTier.free) {
      expiresAt = expiresAt!.subtract(d);
    }
    messagesUsed = 0;
    draftsUsed = 0;
    notifyListeners();
  }

  void reset() {
    tier = DemoTier.free;
    willRenew = true;
    billingIssue = false;
    expiresAt = null;
    hadTrial = false;
    hadIntro = false;
    bonusCreditedThisMonth = false;
    exitOfferShown = false;
    winbackShown = false;
    winbackEligible = false;
    coins = 20;
    messagesUsed = 0;
    messageCredits = 0;
    draftsUsed = 0;
    unlockedDays.clear();
    spentKeys.clear();
    planCompletions.clear();
    drafts.clear();
    conversations.clear();
    messages.clear();
    attempts.clear();
    moods.clear();
    journal.clear();
    talks = 0;
    notifyListeners();
  }

  /// Demo menu "Fill sample weeks": two weeks of check-ins, a few journal
  /// entries and a no-contact history with one restart, so Home, Journal,
  /// Insights and No contact can be seen with real-looking data.
  void fillSample({required bool turkish}) {
    final now = DateTime.now();
    DateTime ago(int d, [int h = 21]) =>
        DateTime(now.year, now.month, now.day, h).subtract(Duration(days: d));
    attempts
      ..clear()
      ..addAll([
        NoContactAttempt(id: nextId('nc'), startedOn: ago(9), goalDays: 30),
        NoContactAttempt(
          id: nextId('nc'),
          startedOn: ago(16),
          endedOn: ago(10),
          goalDays: 30,
          reflection: turkish
              ? 'Doğum günüydü, dayanamadım. Bir dahaki sefere önce Mira’ya yazacağım.'
              : 'It was their birthday and I caved. Next time I’ll write to Mira first.',
        ),
      ]);
    const levels = [2, 1, 2, 2, 3, 2, 3, 3, 2, 3, 4, 3, 4, 4];
    const feelings = [
      [MoodWord.heartbroken, MoodWord.lonely],
      [MoodWord.heartbroken, MoodWord.anxious],
      [MoodWord.lonely, MoodWord.tired],
      [MoodWord.angry, MoodWord.confused],
      [MoodWord.tired, MoodWord.numb],
      [MoodWord.anxious, MoodWord.lonely],
      [MoodWord.calm],
      [MoodWord.hopeful, MoodWord.tired],
      [MoodWord.lonely],
      [MoodWord.calm, MoodWord.relieved],
      [MoodWord.hopeful, MoodWord.proud],
      [MoodWord.confused, MoodWord.calm],
      [MoodWord.hopeful, MoodWord.grateful],
      [MoodWord.calm, MoodWord.proud],
    ];
    moods
      ..clear()
      ..addAll(
        [
          for (var i = 0; i < levels.length; i++)
            if (i !=
                5) // one gap: healing isn't a straight line, nor is logging
              MoodEntry(
                id: nextId('mood'),
                level: levels[i],
                feelings: feelings[i],
                createdAt: ago(levels.length - i),
              ),
        ].reversed,
      );
    final texts = turkish
        ? [
            (
              JournalKind.letter,
              'Göndermeyeceğim mektup',
              'Sana kızgın değilim artık. Sadece yorgunum. Bunu yazmak bile iyi geldi.',
            ),
            (
              JournalKind.list,
              'Özlemeyeceğim üç şey',
              '1. Son dakika iptaller\n2. Telefonuna bakışın\n3. Her şeyin benim suçum olması',
            ),
            (
              JournalKind.gratitude,
              null,
              'Bugün kardeşim aradı ve bir saat konuştuk. Yalnız değilim.',
            ),
            (
              JournalKind.reflection,
              'Bugün seni en çok ne zorladı?',
              'Akşam yemeği saati. Hâlâ iki tabak çıkaracakmışım gibi geliyor.',
            ),
          ]
        : [
            (
              JournalKind.letter,
              'A letter you won’t send',
              'I’m not angry anymore. Just tired. Writing this helped more than sending it would have.',
            ),
            (
              JournalKind.list,
              'Three things you won’t miss',
              '1. Last-minute cancellations\n2. Checking their phone at dinner\n3. Always being the one to apologise',
            ),
            (
              JournalKind.gratitude,
              null,
              'My sister called and we talked for an hour. I’m not alone in this.',
            ),
            (
              JournalKind.reflection,
              'What was hardest today?',
              'Dinnertime. It still feels like I should set two plates.',
            ),
          ];
    journal
      ..clear()
      ..addAll([
        for (var i = 0; i < texts.length; i++)
          JournalEntry(
            id: nextId('j'),
            kind: texts[i].$1,
            prompt: texts[i].$2,
            body: texts[i].$3,
            moodLevel: levels[levels.length - 1 - i * 3],
            createdAt: ago(i * 3 + 1, 22),
            updatedAt: ago(i * 3 + 1, 22),
          ),
      ]);
    notifyListeners();
  }

  void changed() => notifyListeners();
}
