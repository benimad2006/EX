import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/design/design.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/util/context_x.dart';
import '../../checkins/nightly_checkin_service.dart';
import '../../draft_jail/data/draft_repository.dart';
import '../../draft_jail/domain/draft.dart';
import '../application/onboarding_controller.dart';
import 'onboarding_labels.dart';

/// Onboarding quiz (research R1 + founder spec). Every answer feeds Plan
/// ready, the paywall and Day 1. SOS is one tap away on every step (R8).
enum OnboardingStep {
  language,
  name,
  what,
  when,
  details,
  contact,
  hardest,
  mira,
  feelings,
  focus,
  attachment,
  unsent,
  checkin,
  building,
}

/// Day 1 length shown while building (matches plan_days.minutes for day 1).
const onboardingDay1Minutes = 5;

/// Shared prefs key: the onboarding/Welcome notification pre-prompt was shown.
const notifPrePromptedKey = 'notif.prePrompted';

String _hourLabel(BuildContext context, int hour) =>
    context.timeOfDay(DateTime(2026, 1, 1, hour));

class OnboardingQuizScreen extends ConsumerStatefulWidget {
  const OnboardingQuizScreen({super.key});

  @override
  ConsumerState<OnboardingQuizScreen> createState() =>
      _OnboardingQuizScreenState();
}

class _OnboardingQuizScreenState extends ConsumerState<OnboardingQuizScreen> {
  OnboardingStep _step = OnboardingStep.language;
  bool _forward = true;
  bool _busy = false;
  // Created in initState (not lazily): a lazy initializer reading `ref`
  // would run in dispose() if the step was never shown.
  late final TextEditingController _yourName;
  late final TextEditingController _exName;
  final _unsent = TextEditingController();

  static const _maxGoals = 3;
  static const _defaultMood = 5;

  static final _questions = [
    for (final s in OnboardingStep.values)
      if (s != OnboardingStep.building) s,
  ];

  @override
  void initState() {
    super.initState();
    final a = ref.read(onboardingProvider);
    _yourName = TextEditingController(text: a.yourName);
    _exName = TextEditingController(text: a.exName);
    _trackStep();
  }

  @override
  void dispose() {
    _yourName.dispose();
    _exName.dispose();
    _unsent.dispose();
    super.dispose();
  }

  OnboardingAnswers get _a => ref.read(onboardingProvider);
  void _set(OnboardingAnswers a) =>
      ref.read(onboardingProvider.notifier).update(a);

  void _trackStep() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      ref.read(analyticsProvider).onboardingStepViewed(step: _step.name);
    }
  });

  bool _valid(OnboardingAnswers a) => switch (_step) {
    OnboardingStep.language => a.language != null,
    OnboardingStep.what => a.whatHappened != null,
    OnboardingStep.when => a.endedWhen != null,
    OnboardingStep.contact => a.contact != null,
    OnboardingStep.hardest => a.hardestTimes.isNotEmpty,
    OnboardingStep.focus => a.goals.isNotEmpty,
    OnboardingStep.attachment =>
      a.attachmentAnswers.length == AttachmentQuiz.questionCount &&
          !a.attachmentAnswers.contains(-1),
    // Optional or self-defaulting steps.
    _ => true,
  };

  void _next() {
    if (_step == OnboardingStep.name) {
      _set(_a.copyWith(yourName: _yourName.text));
    }
    if (_step == OnboardingStep.details) {
      _set(_a.copyWith(exName: _exName.text));
    }
    if (_step == OnboardingStep.feelings && _a.mood == null) {
      _set(_a.copyWith(mood: _defaultMood));
    }
    setState(() {
      _forward = true;
      _step = OnboardingStep.values[_step.index + 1];
    });
    _trackStep();
  }

  void _back() {
    if (_step.index == 0 || _step == OnboardingStep.building) return;
    setState(() {
      _forward = false;
      _step = OnboardingStep.values[_step.index - 1];
    });
  }

  /// R10: save the unsent message to Draft Jail (never sent).
  Future<void> _saveUnsent() async {
    final body = _unsent.text.trim();
    if (body.isEmpty || _busy) return;
    setState(() => _busy = true);
    final l = context.l10n;
    try {
      final r = await ref.read(draftRepositoryProvider).lockOnboarding(body);
      if (!mounted) return;
      if (r is DraftLocked) {
        showMyExToast(context, l.onbUnsentSaved, success: true);
      }
    } catch (_) {
      // Never blocks onboarding: the text simply isn't saved.
    }
    if (!mounted) return;
    setState(() => _busy = false);
    _next();
  }

  /// R9: notification pre-prompt tied to the hardest time.
  Future<void> _allowCheckins() async {
    if (_busy) return;
    setState(() => _busy = true);
    final hour = _a.suggestedCheckinHour;
    final ok = await ref
        .read(nightlyCheckinProvider)
        .enable(atHour: hour)
        .catchError((Object _) => false);
    await ref
        .read(sharedPreferencesProvider)
        .setBool(notifPrePromptedKey, true);
    ref
        .read(analyticsProvider)
        .notifPreprompt(result: ok ? 'allowed' : 'denied', hour: hour);
    if (!mounted) return;
    final l = context.l10n;
    showMyExToast(
      context,
      ok ? l.onbCheckinOn(_hourLabel(context, hour)) : l.welcomeNotifDenied,
      success: ok,
    );
    setState(() => _busy = false);
    _next();
  }

  Future<void> _skipCheckins() async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool(notifPrePromptedKey, true);
    ref.read(analyticsProvider).notifPreprompt(result: 'not_now');
    _next();
  }

  Widget _bottom(BuildContext context, OnboardingAnswers a) {
    final l = context.l10n;
    return switch (_step) {
      OnboardingStep.building => const SizedBox.shrink(),
      OnboardingStep.unsent => Column(
        children: [
          ListenableBuilder(
            listenable: _unsent,
            builder: (context, _) => PrimaryButton(
              key: const Key('onb-continue'),
              label: l.onbUnsentSave,
              busy: _busy,
              onPressed: _unsent.text.trim().isEmpty ? null : _saveUnsent,
            ),
          ),
          TextLinkButton(
            key: const Key('onb-skip'),
            label: l.onbSkip,
            tone: TextLinkTone.muted,
            onPressed: _next,
          ),
        ],
      ),
      OnboardingStep.checkin => Column(
        children: [
          PrimaryButton(
            key: const Key('onb-continue'),
            label: l.onbCheckinAllow,
            busy: _busy,
            onPressed: _allowCheckins,
          ),
          TextLinkButton(
            key: const Key('onb-skip'),
            label: l.commonNotNow,
            tone: TextLinkTone.muted,
            onPressed: _busy ? null : _skipCheckins,
          ),
        ],
      ),
      _ => Column(
        children: [
          PrimaryButton(
            key: const Key('onb-continue'),
            label: l.onbContinue,
            onPressed: _valid(a) ? _next : null,
          ),
          if (_step == OnboardingStep.name || _step == OnboardingStep.details)
            TextLinkButton(
              key: const Key('onb-skip'),
              label: l.onbSkip,
              tone: TextLinkTone.muted,
              onPressed: _next,
            ),
        ],
      ),
    };
  }

  Widget _body(BuildContext context, OnboardingAnswers a) {
    final l = context.l10n;
    return switch (_step) {
      OnboardingStep.language => _LanguageStep(a: a, onSet: _set),
      OnboardingStep.name => _TextStep(
        title: l.onbNameTitle,
        sub: l.onbNameSub,
        fieldKey: const Key('onb-your-name'),
        label: l.onbYourName,
        controller: _yourName,
        words: true,
      ),
      OnboardingStep.what => _SingleChoice<WhatHappened>(
        title: l.onbWhatTitle,
        sub: l.onbWhatSub,
        options: WhatHappened.offered,
        label: l.whatHappenedLabel,
        selected: a.whatHappened,
        onPick: (v) => _set(_a.copyWith(whatHappened: v)),
      ),
      OnboardingStep.when => _SingleChoice<EndedWhen>(
        title: l.onbWhenTitle,
        options: EndedWhen.values,
        label: l.endedWhenLabel,
        selected: a.endedWhen,
        onPick: (v) => _set(_a.copyWith(endedWhen: v)),
      ),
      OnboardingStep.details => _DetailsStep(
        a: a,
        exName: _exName,
        onLength: (v) => _set(_a.copyWith(length: v)),
      ),
      OnboardingStep.contact => _SingleChoice<ContactLevel>(
        title: l.onbContactTitle,
        options: ContactLevel.values,
        label: l.contactLabel,
        selected: a.contact,
        onPick: (v) => _set(_a.copyWith(contact: v)),
      ),
      OnboardingStep.hardest => _MultiChoice<HardestTime>(
        title: l.onbHardestTitle,
        sub: l.onbHardestSub,
        options: HardestTime.values,
        label: l.hardestLabel,
        selected: a.hardestTimes,
        onToggle: (v) {
          final next = List<HardestTime>.of(_a.hardestTimes);
          if (!next.remove(v)) next.add(v);
          _set(_a.copyWith(hardestTimes: next));
        },
      ),
      OnboardingStep.mira => const _MiraStep(),
      OnboardingStep.feelings => _FeelingsStep(
        a: a,
        onSet: _set,
        current: () => _a,
      ),
      OnboardingStep.focus => _MultiChoice<Goal>(
        title: l.onbGoalsTitle,
        sub: l.onbGoalsSub,
        options: Goal.values,
        label: l.goalLabel,
        selected: a.goals,
        onToggle: (g) {
          final next = List<Goal>.of(_a.goals);
          if (!next.remove(g)) {
            if (next.length >= _maxGoals) return;
            next.add(g);
          }
          _set(_a.copyWith(goals: next));
        },
      ),
      OnboardingStep.attachment => _AttachmentStep(
        a: a,
        onSet: _set,
        current: () => _a,
      ),
      OnboardingStep.unsent => _TextStep(
        title: l.onbUnsentTitle,
        sub: l.onbUnsentSub,
        fieldKey: const Key('onb-unsent'),
        label: l.draftFieldLabel,
        hint: l.onbUnsentHint,
        controller: _unsent,
        multiline: true,
      ),
      OnboardingStep.checkin => _CheckinStep(
        hour: a.suggestedCheckinHour,
        onHour: (h) => _set(_a.copyWith(checkinHour: h)),
      ),
      OnboardingStep.building => const _BuildingStep(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final a = ref.watch(onboardingProvider);
    final m = MyExMotion.of(context);
    final building = _step == OnboardingStep.building;
    final qIndex = _questions.indexOf(_step);

    return PopScope(
      canPop: _step.index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        body: ScreenBackground(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: m.smooth,
                      switchInCurve: m.smoothCurve,
                      transitionBuilder: (child, anim) {
                        if (m.reduced) {
                          return FadeTransition(opacity: anim, child: child);
                        }
                        final incoming = child.key == ValueKey(_step);
                        final dx = (incoming == _forward) ? 1.0 : -0.3;
                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween(
                              begin: Offset(dx * 0.2, 0),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(_step),
                        child: _body(context, a),
                      ),
                    ),
                  ),
                  if (!building)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        MyExSpacing.margin,
                        MyExSpacing.s3,
                        MyExSpacing.margin,
                        MediaQuery.paddingOf(context).bottom + MyExSpacing.s4,
                      ),
                      child: _bottom(context, a),
                    ),
                ],
              ),
              NavBar(
                leading: _step.index == 0 || building
                    ? null
                    : GlassIconButton(
                        icon: MyExIcons.back,
                        semanticLabel: l.commonBack,
                        onPressed: _back,
                      ),
                center: building
                    ? const SizedBox.shrink()
                    : Semantics(
                        label: l.onbStep(qIndex + 1, _questions.length),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: (qIndex + 1) / _questions.length),
                          duration: m.smooth,
                          curve: m.smoothCurve,
                          builder: (context, v, _) => ProgressBar(value: v),
                        ),
                      ),
                // R8: SOS reachable from every onboarding screen, free.
                trailing: TextLinkButton(
                  key: const Key('onb-help'),
                  label: l.onbHelpNow,
                  small: true,
                  semibold: true,
                  onPressed: () => context.push(Routes.sosFrom('onboarding')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared layout for a question: title, subtitle, content.
class _Question extends StatelessWidget {
  const _Question({required this.title, this.sub, required this.children});
  final String title;
  final String? sub;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        MyExSpacing.margin,
        top + MyExSizes.navBarHeight + MyExSpacing.s4,
        MyExSpacing.margin,
        MyExSpacing.s6,
      ),
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: MyExType.display.copyWith(fontSize: 32, height: 36 / 32),
          ),
        ),
        if (sub != null) ...[
          const Gap(MyExSpacing.s1),
          Text(sub!, style: MyExType.subheadline),
        ],
        const Gap(MyExSpacing.section),
        ...children,
      ],
    );
  }
}

class _SingleChoice<T> extends StatelessWidget {
  const _SingleChoice({
    required this.title,
    required this.options,
    required this.label,
    required this.selected,
    required this.onPick,
    this.sub,
  });
  final String title;
  final String? sub;
  final List<T> options;
  final String Function(T) label;
  final T? selected;
  final ValueChanged<T> onPick;

  @override
  Widget build(BuildContext context) => _Question(
    title: title,
    sub: sub,
    children: [
      InsetGroup(
        children: [
          for (final o in options)
            SelectRow(
              title: label(o),
              selected: selected == o,
              onTap: () => onPick(o),
            ),
        ],
      ),
    ],
  );
}

class _MultiChoice<T> extends StatelessWidget {
  const _MultiChoice({
    required this.title,
    required this.options,
    required this.label,
    required this.selected,
    required this.onToggle,
    this.sub,
  });
  final String title;
  final String? sub;
  final List<T> options;
  final String Function(T) label;
  final List<T> selected;
  final ValueChanged<T> onToggle;

  @override
  Widget build(BuildContext context) => _Question(
    title: title,
    sub: sub,
    children: [
      InsetGroup(
        children: [
          for (final o in options)
            SelectRow(
              multi: true,
              title: label(o),
              selected: selected.contains(o),
              onTap: () => onToggle(o),
            ),
        ],
      ),
    ],
  );
}

class _TextStep extends StatelessWidget {
  const _TextStep({
    required this.title,
    required this.sub,
    required this.fieldKey,
    required this.label,
    required this.controller,
    this.hint,
    this.words = false,
    this.multiline = false,
  });
  final String title;
  final String sub;
  final Key fieldKey;
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool words;
  final bool multiline;

  static const _maxName = 40;
  static const _maxText = 4000;

  @override
  Widget build(BuildContext context) => _Question(
    title: title,
    sub: sub,
    children: [
      InsetTextField(
        key: fieldKey,
        label: label,
        hint: hint,
        controller: controller,
        maxLength: multiline ? _maxText : _maxName,
        minLines: multiline ? 5 : 1,
        maxLines: multiline ? 10 : 1,
        textCapitalization: words
            ? TextCapitalization.words
            : TextCapitalization.sentences,
      ),
    ],
  );
}

class _LanguageStep extends ConsumerWidget {
  const _LanguageStep({required this.a, required this.onSet});
  final OnboardingAnswers a;
  final ValueChanged<OnboardingAnswers> onSet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    void pick(String code) {
      onSet(a.copyWith(language: code));
      ref.read(appLocaleProvider.notifier).set(code);
    }

    return _Question(
      title: l.onbLanguageTitle,
      sub: l.onbLanguageSub,
      children: [
        InsetGroup(
          children: [
            SelectRow(
              title: l.onbLanguageEn,
              selected: a.language == 'en',
              onTap: () => pick('en'),
            ),
            SelectRow(
              title: l.onbLanguageTr,
              selected: a.language == 'tr',
              onTap: () => pick('tr'),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    required this.a,
    required this.exName,
    required this.onLength,
  });
  final OnboardingAnswers a;
  final TextEditingController exName;
  final ValueChanged<RelationshipLength> onLength;

  static const _maxName = 40;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return _Question(
      title: l.onbDetailsTitle,
      sub: l.onbDetailsSub,
      children: [
        InsetTextField(
          label: l.onbExName,
          hint: l.onbExNameHint,
          controller: exName,
          maxLength: _maxName,
          textCapitalization: TextCapitalization.words,
        ),
        SectionHeader(l.onbLength),
        InsetGroup(
          children: [
            for (final v in RelationshipLength.values)
              SelectRow(
                title: l.lengthLabel(v),
                selected: a.length == v,
                onTap: () => onLength(v),
              ),
          ],
        ),
      ],
    );
  }
}

/// Value interstitial: pre-sells Mira without a claim; SOS stays free.
class _MiraStep extends StatelessWidget {
  const _MiraStep();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SafeArea(
      child: Padding(
        padding: kScreenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(child: StarField(count: 24, seed: 5)),
                  MiraOrb(size: MyExSizes.mascotOrb),
                ],
              ),
            ),
            const Gap(MyExSpacing.s6),
            Text(
              l.onbMiraTitle,
              style: MyExType.display,
              textAlign: TextAlign.center,
            ),
            const Gap(MyExSpacing.s2),
            Text(
              l.onbMiraBody,
              style: MyExType.body.copyWith(color: MyExColors.ink2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeelingsStep extends StatelessWidget {
  const _FeelingsStep({
    required this.a,
    required this.onSet,
    required this.current,
  });
  final OnboardingAnswers a;
  final ValueChanged<OnboardingAnswers> onSet;

  /// Latest answers at tap time (avoids stale closures on rapid taps).
  final OnboardingAnswers Function() current;

  static const _maxMood = 10;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final mood = a.mood ?? _OnboardingQuizScreenState._defaultMood;
    return _Question(
      title: l.onbFeelingsTitle,
      children: [
        SolidCard(
          child: Column(
            children: [
              Text(
                '$mood',
                style: MyExType.numeral(MyExType.numeralMood),
                semanticsLabel: l.onbMoodSemantics(mood),
              ),
              const Gap(MyExSpacing.s2),
              MyExSlider(
                key: const Key('onb-mood'),
                value: mood.toDouble(),
                min: 0,
                max: _maxMood.toDouble(),
                divisions: _maxMood,
                semanticLabel: l.onbMoodSemantics(mood),
                onChanged: (v) => onSet(current().copyWith(mood: v.round())),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l.onbMoodLow, style: MyExType.footnote),
                  Text(l.onbMoodHigh, style: MyExType.footnote),
                ],
              ),
            ],
          ),
        ),
        SectionHeader(l.onbFeelingsSub),
        InsetGroup(
          children: [
            for (final f in Feeling.values)
              SelectRow(
                multi: true,
                title: l.feelingLabel(f),
                selected: a.feelings.contains(f),
                onTap: () {
                  final cur = current();
                  final next = List<Feeling>.of(cur.feelings);
                  if (!next.remove(f)) next.add(f);
                  onSet(cur.copyWith(mood: cur.mood ?? mood, feelings: next));
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _AttachmentStep extends StatelessWidget {
  const _AttachmentStep({
    required this.a,
    required this.onSet,
    required this.current,
  });
  final OnboardingAnswers a;
  final ValueChanged<OnboardingAnswers> onSet;
  final OnboardingAnswers Function() current;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final answers = a.attachmentAnswers.length == AttachmentQuiz.questionCount
        ? a.attachmentAnswers
        : List<int>.filled(AttachmentQuiz.questionCount, -1);
    final qs = l.attachmentQuestions;
    return _Question(
      title: l.onbAttachTitle,
      sub: l.onbAttachSub,
      children: [
        for (var i = 0; i < qs.length; i++) ...[
          if (i > 0) const Gap(MyExSpacing.s4),
          Text(qs[i], style: MyExType.headline),
          const Gap(MyExSpacing.s2),
          MyExSegmented<int>(
            key: Key('onb-attach-$i'),
            value: answers[i] < 0 ? null : answers[i],
            segments: {1: l.ansAgree, 0: l.ansNotReally},
            onChanged: (v) {
              final cur = current();
              final next =
                  cur.attachmentAnswers.length == AttachmentQuiz.questionCount
                  ? List<int>.of(cur.attachmentAnswers)
                  : List<int>.filled(AttachmentQuiz.questionCount, -1);
              next[i] = v;
              onSet(cur.copyWith(attachmentAnswers: next));
            },
          ),
        ],
      ],
    );
  }
}

/// R9: check-in pre-prompt with the time pre-filled from the hardest time.
class _CheckinStep extends StatelessWidget {
  const _CheckinStep({required this.hour, required this.onHour});
  final int hour;
  final ValueChanged<int> onHour;

  Future<void> _pick(BuildContext context) async {
    final l = context.l10n;
    var picked = hour;
    await showGlassSheet<void>(
      context: context,
      semanticLabel: l.onbCheckinChange,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: MyExSizes.datePickerHeight,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              minuteInterval: 30,
              initialDateTime: DateTime(2026, 1, 1, hour),
              onDateTimeChanged: (d) => picked = d.hour,
            ),
          ),
          PrimaryButton(
            label: l.onbDone,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
    onHour(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final time = _hourLabel(context, hour);
    return _Question(
      title: l.onbCheckinTitle,
      sub: l.onbCheckinSub(time),
      children: [
        InsetGroup(
          children: [
            ListRow(
              key: const Key('onb-checkin-time'),
              leading: const IconSquare(icon: MyExIcons.bell),
              title: l.onbCheckinChange,
              value: time,
              onTap: () => _pick(context),
            ),
          ],
        ),
      ],
    );
  }
}

/// R2: "Building your plan" (~4 s). Each line ticks through the user's real
/// answers. No percentages, no fake "analyzing" numbers.
class _BuildingStep extends ConsumerStatefulWidget {
  const _BuildingStep();

  @override
  ConsumerState<_BuildingStep> createState() => _BuildingStepState();
}

class _BuildingStepState extends ConsumerState<_BuildingStep> {
  int _done = 0;
  Timer? _timer;
  Future<void>? _save;

  static const _first = Duration(milliseconds: 500);
  static const _tick = Duration(milliseconds: 900);

  @override
  void initState() {
    super.initState();
    final a = ref.read(onboardingProvider);
    ref
        .read(analyticsProvider)
        .onboardingCompleted(
          breakupType: a.whatHappened?.wire,
          attachmentStyle: a.attachmentStyle?.name,
          focus: a.focus?.name,
        );
    _save = ref.read(onboardingProvider.notifier).finishQuiz();
    _timer = Timer(_first, _advance);
  }

  void _advance() {
    if (!mounted) return;
    final total = _lines(context).length;
    setState(() => _done++);
    MyExHaptics.selection();
    if (_done < total) {
      _timer = Timer(_tick, _advance);
    } else {
      _timer = Timer(_tick, () async {
        await _save;
        if (mounted) context.go(Routes.planReady);
      });
    }
  }

  List<String> _lines(BuildContext context) {
    final l = context.l10n;
    final a = ref.read(onboardingProvider);
    return [
      if (a.goals.isNotEmpty)
        l.onbBuildFocus(a.goals.take(2).map(l.focusLabel).join(', ')),
      if (a.hardest != null) l.onbBuildHardest(l.hardestLabel(a.hardest!)),
      l.onbBuildTrack(l.trackLabel(a.contact)),
      l.onbBuildDay1(onboardingDay1Minutes),
    ];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lines = _lines(context);
    return SafeArea(
      child: Padding(
        padding: kScreenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                l.onbBuildingTitle,
                style: MyExType.display,
                textAlign: TextAlign.center,
              ),
            ),
            const Gap(MyExSpacing.section),
            InsetGroup(
              children: [
                for (var i = 0; i < lines.length; i++)
                  ListRow(
                    title: lines[i],
                    chevron: false,
                    titleColor: i < _done ? MyExColors.ink : MyExColors.ink2,
                    trailing: i < _done
                        ? Icon(
                            MyExIcons.check,
                            color: MyExColors.success,
                            size: MyExSizes.iconMd,
                          )
                        : SizedBox.square(
                            dimension: MyExSizes.icon,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: MyExColors.ink3,
                            ),
                          ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
