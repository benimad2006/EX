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
import 'journal_labels.dart';

/// Journal tab: tonight's prompt, search + kind filter, entries by month.
/// Private by default (spec: Day One / Spill references in docs/design).
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _search = TextEditingController();
  JournalKind? _kind;

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
    final (pKind, pText) = l.promptOfTheDay(DateTime.now());
    final shown = filterJournal(all, query: _search.text, kind: _kind);

    return ScreenBackground(
      child: LargeTitleScrollView(
        title: l.journalTitle,
        trailing: GlassIconButton(
          key: const Key('journal-new'),
          icon: Icons.edit_outlined,
          semanticLabel: l.journalNew,
          onPressed: _write,
        ),
        onRefresh: () async => ref.invalidate(journalEntriesProvider),
        children: [
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
                      onTap: () =>
                          setState(() => _kind = _kind == k ? null : k),
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
          Footnote(l.journalPrivate, icon: Icons.lock_outline_rounded),
        ],
      ),
    );
  }

  List<Widget> _byMonth(BuildContext context, List<JournalEntry> entries) {
    final l = context.l10n;
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
              children: [
                for (final e in g.value)
                  ListRow(
                    key: Key('journal-row-${e.id}'),
                    leading: SizedBox(
                      width: MyExSizes.iconSquare,
                      child: Center(
                        child: MoodDot(
                          level: e.moodLevel?.toDouble(),
                          size: 12,
                        ),
                      ),
                    ),
                    title: e.headline,
                    subtitle:
                        '${l.journalKind(e.kind)} · ${context.shortDate(e.createdAt)}',
                    onTap: () => context.push(Routes.journalEntry(id: e.id)),
                  ),
              ],
            ),
          ],
        ),
    ];
  }
}

/// Tonight's prompt: the one serif moment on this screen.
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
                  Icons.arrow_forward_rounded,
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
