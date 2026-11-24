import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design.dart';
import '../../../core/util/context_x.dart';
import '../data/journal_repository.dart';
import '../domain/mood.dart';
import 'journal_labels.dart';

/// Two-tap mood check-in: a level (required), feeling words and a note
/// (optional). Returns true when saved.
Future<bool> showMoodCheckIn(BuildContext context, {int? initialLevel}) async {
  final saved = await showGlassSheet<bool>(
    context: context,
    semanticLabel: context.l10n.homeMoodTitle,
    builder: (_) => _MoodCheckIn(initialLevel: initialLevel),
  );
  return saved ?? false;
}

class _MoodCheckIn extends ConsumerStatefulWidget {
  const _MoodCheckIn({this.initialLevel});
  final int? initialLevel;

  @override
  ConsumerState<_MoodCheckIn> createState() => _MoodCheckInState();
}

class _MoodCheckInState extends ConsumerState<_MoodCheckIn> {
  late int? _level = widget.initialLevel;
  final _feelings = <MoodWord>{};
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final level = _level;
    if (level == null) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(journalRepositoryProvider)
          .addMood(
            level: level,
            feelings: [
              for (final f in MoodWord.values)
                if (_feelings.contains(f)) f,
            ],
            note: _note.text,
          );
      ref.invalidate(moodEntriesProvider);
      if (!mounted) return;
      unawaited(MyExHaptics.success());
      Navigator.of(context).pop(true);
      showMyExToast(context, context.l10n.moodSaved, success: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      showMyExToast(context, context.l10n.commonSaveFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      key: const Key('mood-sheet'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(l.homeMoodTitle, style: MyExType.title2),
        ),
        const Gap(MyExSpacing.s5),
        MoodScale(
          value: _level,
          words: l.moodWords,
          semantics: l.moodScaleSemantics,
          onChanged: (v) => setState(() => _level = v),
        ),
        const Gap(MyExSpacing.s5),
        Text(l.moodSheetFeelings, style: MyExType.headline),
        const Gap(MyExSpacing.s1),
        Wrap(
          spacing: MyExSpacing.s2,
          children: [
            for (final f in MoodWord.values)
              WordChip(
                label: l.feeling(f),
                selected: _feelings.contains(f),
                onTap: () => setState(
                  () => _feelings.contains(f)
                      ? _feelings.remove(f)
                      : _feelings.add(f),
                ),
              ),
          ],
        ),
        const Gap(MyExSpacing.s3),
        InsetTextField(
          label: l.moodSheetNote,
          controller: _note,
          maxLength: 280,
          maxLines: 3,
        ),
        const Gap(MyExSpacing.s5),
        PrimaryButton(
          key: const Key('mood-save'),
          label: l.moodSheetSave,
          busy: _busy,
          onPressed: _level == null ? null : _save,
        ),
      ],
    );
  }
}
