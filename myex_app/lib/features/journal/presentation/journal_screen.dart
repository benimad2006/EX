import 'package:flutter/cupertino.dart' show CupertinoSearchTextField;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design/design.dart';
import '../../../core/router/app_router.dart';
import '../../../core/util/context_x.dart';
import '../data/journal_repository.dart';
import '../domain/journal_entry.dart';
import '../domain/mood.dart';
import 'journal_labels.dart';

enum _Tab { entries, calendar, prompts }

/// Journal tab: Entries (tonight's prompt, search, list), Calendar (the
/// emotional landscape: each day tinted by mood, tap a day for what you felt
/// and wrote) and Prompts (guided journals). Private by default.
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key, this.initialTab});

  /// "entries" (default), "calendar" or "prompts" (deep link `?tab=`).
  final String? initialTab;

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _search = TextEditingController();
  late _Tab _tab =
      _Tab.values.where((t) => t.name == widget.initialTab).firstOrNull ??
      _Tab.entries;
  JournalKind? _kind;
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime _day = dayOf(DateTime.now());

  @override
  void didUpdateWidget(JournalScreen old) {
    super.didUpdateWidget(old);
    // The tab shell keeps this screen alive; follow a new `?tab=` link.
    final t = _Tab.values.where((t) => t.name == widget.initialTab).firstOrNull;
    if (t != null && widget.initialTab != old.initialTab) _tab = t;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _write({JournalKind? kind, String? prompt}) =>
      context.push(Routes.journalEntry(kind: kind?.name, prompt: prompt));

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final async = ref.watch(journalEntriesProvider);
    final all = async.value ?? const <JournalEntry>[];
    final moods = ref.watch(moodEntriesProvider).value ?? const <MoodEntry>[];

    return ScreenBackground(
      child: LargeTitleScrollView(
        title: l.journalTitle,
        trailing: GlassIconButton(
          key: const Key('journal-new'),
          icon: MyExIcons.edit,
          semanticLabel: l.journalNew,
          onPressed: _write,
        ),
        onRefresh: () async => ref
          ..invalidate(journalEntriesProvider)
          ..invalidate(moodEntriesProvider),
        children: [
          PillTabs<_Tab>(
            value: _tab,
            tabs: {
              _Tab.entries: l.journalTabEntries,
              _Tab.calendar: l.journalTabCalendar,
              _Tab.prompts: l.journalTabPrompts,
            },
            onChanged: (t) => setState(() => _tab = t),
          ),
          ...switch (_tab) {
            _Tab.entries => _entries(context, async, all),
            _Tab.calendar => _calendar(context, all, moods),
            _Tab.prompts => _prompts(context),
          },
          Footnote(l.journalPrivate, icon: MyExIcons.lock),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- Entries

  List<Widget> _entries(
    BuildContext context,
    AsyncValue<List<JournalEntry>> async,
    List<JournalEntry> all,
  ) {
    final l = context.l10n;
    final (pKind, pText) = l.promptOfTheDay(DateTime.now());
    final shown = filterJournal(all, query: _search.text, kind: _kind);
    return [
      _PromptCard(
        kindLabel: l.journalKind(pKind),
        prompt: pText,
        onWrite: () => _write(kind: pKind, prompt: pText),
      ),
      if (async.isLoading && all.isEmpty)
        const SkeletonBox(height: MyExSizes.skeletonList)
      else if (all.isEmpty)
        EmptyState(
          title: l.journalEmptyTitle,
          body: l.journalEmptyBody,
          actionLabel: l.journalEmptyCta,
          onAction: _write,
        )
      else ...[
        CupertinoSearchTextField(
          controller: _search,
          placeholder: l.journalSearch,
          style: MyExType.body,
          placeholderStyle: MyExType.body.copyWith(color: MyExColors.ink2),
          backgroundColor: MyExColors.fill,
          itemColor: MyExColors.ink2,
          onChanged: (_) => setState(() {}),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              WordChip(
                label: l.journalFilterAll,
                selected: _kind == null,
                onTap: () => setState(() => _kind = null),
              ),
              for (final k in JournalKind.values) ...[
                const Gap(MyExSpacing.s2),
                WordChip(
                  label: l.journalKind(k),
                  selected: _kind == k,
                  onTap: () => setState(() => _kind = _kind == k ? null : k),
                ),
              ],
            ],
          ),
        ),
        if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.all(MyExSpacing.s6),
            child: Text(
              l.journalNoResults(_search.text.trim()),
              textAlign: TextAlign.center,
              style: MyExType.subheadline,
            ),
          )
        else
          ..._byMonth(context, shown),
      ],
    ];
  }

  List<Widget> _byMonth(BuildContext context, List<JournalEntry> entries) {
    final fmt = DateFormat.yMMMM(context.localeName);
    final groups = <String, List<JournalEntry>>{};
    for (final e in entries) {
      groups.putIfAbsent(fmt.format(e.createdAt), () => []).add(e);
    }
    return [
      for (final g in groups.entries)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(g.key),
            InsetGroup(
              children: [for (final e in g.value) _EntryRow(entry: e)],
            ),
          ],
        ),
    ];
  }

  // --------------------------------------------------------------- Calendar

  List<Widget> _calendar(
    BuildContext context,
    List<JournalEntry> all,
    List<MoodEntry> moods,
  ) {
    final l = context.l10n;
    final now = DateTime.now();
    final today = dayOf(now);
    final byDay = moodByDay(moods);
    final written = {for (final e in all) dayOf(e.createdAt)};
    final monthFmt = DateFormat.yMMMM(context.localeName);
    final dayFmt = DateFormat.MMMMd(context.localeName);
    final letter = DateFormat('EEEEE', context.localeName);
    final isCurrentMonth =
        _month.year == today.year && _month.month == today.month;
    return [
      SolidCard(
        padding: const EdgeInsets.fromLTRB(
          MyExSpacing.s4,
          MyExSpacing.s4,
          MyExSpacing.s4,
          MyExSpacing.s3,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.journalLandscape, style: MyExType.headline),
                      Text(monthFmt.format(_month), style: MyExType.footnote),
                    ],
                  ),
                ),
                _MonthArrow(
                  icon: MyExIcons.back,
                  label: monthFmt.format(
                    DateTime(_month.year, _month.month - 1),
                  ),
                  onTap: () => setState(
                    () => _month = DateTime(_month.year, _month.month - 1),
                  ),
                ),
                const Gap(MyExSpacing.s2),
                _MonthArrow(
                  icon: MyExIcons.forward,
                  label: monthFmt.format(
                    DateTime(_month.year, _month.month + 1),
                  ),
                  onTap: isCurrentMonth
                      ? null
                      : () => setState(
                          () =>
                              _month = DateTime(_month.year, _month.month + 1),
                        ),
                ),
              ],
            ),
            const Gap(MyExSpacing.s4),
            MoodCalendar(
              month: _month,
              moods: byDay,
              written: written,
              selected: _day,
              today: today,
              weekdayLetters: [
                for (var i = 0; i < 7; i++)
                  letter.format(DateTime(2024, 1, 1 + i)), // 2024-01-01: Monday
              ],
              onSelect: (d) => setState(() => _day = d),
              semanticsFor: (d, mood, wrote) => l.journalCalendarDay(
                dayFmt.format(d),
                [
                  mood == null
                      ? l.journalCalendarNothing
                      : l.moodWord(mood.round()),
                  if (wrote) l.journalCalendarWrote,
                ].join(', '),
              ),
            ),
          ],
        ),
      ),
      _DayCard(
        day: _day,
        isToday: _day == today,
        mood: byDay[_day],
        feelings: {
          for (final m in moods)
            if (dayOf(m.createdAt) == _day) ...m.feelings,
        }.toList(),
        entries: entriesOn(all, _day),
        onWrite: _write,
      ),
    ];
  }

  // ---------------------------------------------------------------- Prompts

  List<Widget> _prompts(BuildContext context) {
    final l = context.l10n;
    final items = [
      (JournalKind.reflection, ArtKind.moon, l.journalCollReflection),
      (JournalKind.letter, ArtKind.book, l.journalCollLetter),
      (JournalKind.gratitude, ArtKind.sunrise, l.journalCollGratitude),
      (JournalKind.list, ArtKind.rose, l.journalCollList),
    ];
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.journalCollections, style: MyExType.title3),
          const Gap(MyExSpacing.s1),
          Text(l.journalCollectionsSub, style: MyExType.subheadline),
        ],
      ),
      for (final (kind, art, sub) in items)
        _CollectionCard(
          key: Key('journal-coll-${kind.name}'),
          art: art,
          title: l.journalKind(kind),
          subtitle: sub,
          count: l.journalPromptsCount(l.prompts(kind).length),
          onTap: () => _pickPrompt(kind),
        ),
    ];
  }

  Future<void> _pickPrompt(JournalKind kind) {
    final l = context.l10n;
    return showGlassSheet<void>(
      context: context,
      semanticLabel: l.journalKind(kind),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.journalKind(kind),
            style: MyExType.sheetTitle,
            textAlign: TextAlign.center,
          ),
          const Gap(MyExSpacing.s4),
          InsetGroup(
            children: [
              for (final p in l.prompts(kind))
                ListRow(
                  title: p,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _write(kind: kind, prompt: p);
                  },
                ),
              ListRow(
                leading: Icon(
                  MyExIcons.edit,
                  size: MyExSizes.icon,
                  color: MyExColors.accentInk,
                ),
                title: l.journalFreeWrite,
                titleColor: MyExColors.accentInk,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _write(kind: kind);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final e = entry;
    return ListRow(
      key: Key('journal-row-${e.id}'),
      leading: SizedBox(
        width: MyExSizes.iconSquare,
        child: Center(child: MoodDot(level: e.moodLevel?.toDouble(), size: 12)),
      ),
      title: e.headline,
      subtitle: '${l.journalKind(e.kind)} · ${context.shortDate(e.createdAt)}',
      onTap: () => context.push(Routes.journalEntry(id: e.id)),
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onTap != null,
    label: label,
    excludeSemantics: true,
    child: Pressable(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.35 : 1,
        child: RoundControl(
          size: 36,
          child: Icon(icon, size: MyExSizes.icon, color: MyExColors.ink),
        ),
      ),
    ),
  );
}

/// The selected day: date, mood, what you felt, and what you wrote.
class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.isToday,
    required this.mood,
    required this.feelings,
    required this.entries,
    required this.onWrite,
  });

  final DateTime day;
  final bool isToday;
  final double? mood;
  final List<MoodWord> feelings;
  final List<JournalEntry> entries;
  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final title = DateFormat.MMMMEEEEd(context.localeName).format(day);
    final m = mood;
    return SolidCard(
      key: const Key('journal-day-card'),
      padding: const EdgeInsets.all(MyExSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: MyExType.display.copyWith(
                    fontSize: 24,
                    height: 28 / 24,
                  ),
                ),
              ),
              if (m != null) MoodDot(level: m, size: 22),
            ],
          ),
          const Gap(MyExSpacing.s3),
          Text(l.journalDayFelt, style: MyExType.footnote),
          const Gap(MyExSpacing.s2),
          if (m == null && feelings.isEmpty)
            Text(l.journalDayNoMood, style: MyExType.subheadline)
          else
            Wrap(
              spacing: MyExSpacing.s2,
              runSpacing: MyExSpacing.s2,
              children: [
                if (m != null) _Tag(l.moodWord(m.round()), level: m.round()),
                for (final f in feelings)
                  _Tag(l.feeling(f), level: feelingTint(f)),
              ],
            ),
          const Gap(MyExSpacing.s4),
          if (entries.isEmpty) ...[
            Text(l.journalDayEmpty, style: MyExType.subheadline),
            if (isToday)
              TextLinkButton(
                label: l.journalDayWrite,
                small: true,
                semibold: true,
                onPressed: onWrite,
              ),
          ] else
            for (final e in entries) ...[
              Pressable(
                onTap: () => context.push(Routes.journalEntry(id: e.id)),
                pressedScale: 0.98,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(MyExSpacing.s3 + 2),
                  decoration: BoxDecoration(
                    color: MyExColors.fill,
                    borderRadius: BorderRadius.circular(MyExRadii.m),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.prompt ?? l.journalKind(e.kind),
                        style: MyExType.headline,
                      ),
                      const Gap(MyExSpacing.s1),
                      Text(
                        e.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: MyExType.subheadline,
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(MyExSpacing.s2),
            ],
        ],
      ),
    );
  }
}

/// A non-interactive feeling tag tinted by its mood step.
class _Tag extends StatelessWidget {
  const _Tag(this.label, {required this.level});
  final String label;
  final int level;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: MyExSpacing.s3,
      vertical: MyExSpacing.s1 + 2,
    ),
    decoration: BoxDecoration(
      color: MyExColors.mood(level).withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(MyExRadii.capsule),
      border: Border.all(color: MyExColors.mood(level).withValues(alpha: 0.6)),
    ),
    child: Text(
      label,
      style: MyExType.footnote.copyWith(
        color: MyExColors.ink,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

/// A guided journal: painted medallion, name, line and prompt count.
class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    super.key,
    required this.art,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.onTap,
  });

  final ArtKind art;
  final String title;
  final String subtitle;
  final String count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Semantics(
      button: true,
      child: Pressable(
        onTap: onTap,
        pressedScale: 0.98,
        child: SolidCard(
          child: Row(
            children: [
              ArtMedallion(kind: art, size: 52),
              const Gap(MyExSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: MyExType.headline),
                    Text(subtitle, style: MyExType.subheadline),
                    const Gap(2),
                    Text(
                      count,
                      style: MyExType.caption1.copyWith(
                        color: MyExColors.accentInk,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                MyExIcons.forward,
                size: MyExSizes.icon,
                color: MyExColors.ink3,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Tonight's prompt: the one serif moment on the Entries tab.
class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.kindLabel,
    required this.prompt,
    required this.onWrite,
  });

  final String kindLabel;
  final String prompt;
  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Pressable(
      onTap: onWrite,
      pressedScale: 0.98,
      child: SolidCard(
        padding: const EdgeInsets.all(MyExSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l.journalPromptToday} · $kindLabel',
              style: MyExType.footnote.copyWith(color: MyExColors.accentInk),
            ),
            const Gap(MyExSpacing.s2),
            Text(
              prompt,
              style: MyExType.display.copyWith(fontSize: 30, height: 34 / 30),
            ),
            const Gap(MyExSpacing.s4),
            Row(
              children: [
                const Spacer(),
                Text(
                  l.journalWrite,
                  style: MyExType.headline.copyWith(
                    color: MyExColors.accentInk,
                  ),
                ),
                Icon(
                  MyExIcons.arrowRight,
                  size: MyExSizes.icon,
                  color: MyExColors.accentInk,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
