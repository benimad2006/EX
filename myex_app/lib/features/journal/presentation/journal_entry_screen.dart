import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/design/design.dart';
import '../../../core/util/context_x.dart';
import '../data/journal_repository.dart';
import '../domain/journal_entry.dart';
import 'journal_labels.dart';

/// Write or edit one entry: kind, optional guided prompt (serif), the text,
/// and how writing left you (optional mood). Explicit Save; leaving with
/// unsaved text asks first, so nothing is lost by accident.
class JournalEntryScreen extends ConsumerStatefulWidget {
  const JournalEntryScreen({super.key, this.id, this.kind, this.prompt});

  /// Existing entry to edit (null = new).
  final String? id;
  final JournalKind? kind;
  final String? prompt;

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  final _body = TextEditingController();
  late JournalKind _kind = widget.kind ?? JournalKind.reflection;
  late String? _prompt = widget.prompt;
  int? _mood;
  JournalEntry? _existing;
  bool _busy = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final id = widget.id;
    if (id != null) {
      final e = ref
          .read(journalEntriesProvider)
          .value
          ?.where((x) => x.id == id)
          .firstOrNull;
      if (e != null) {
        _existing = e;
        _kind = e.kind;
        _prompt = e.prompt;
        _mood = e.moodLevel;
        _body.text = e.body;
      }
    }
    _body.addListener(() {
      if (!_dirty) setState(() => _dirty = true);
    });
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  void _nextPrompt() {
    final l = context.l10n;
    final list = l.prompts(_kind);
    final i = list.indexOf(_prompt ?? '');
    setState(() => _prompt = list[(i + 1) % list.length]);
    MyExHaptics.selection();
  }

  Future<void> _save() async {
    if (_body.text.trim().isEmpty) return;
    setState(() => _busy = true);
    final now = DateTime.now();
    final e = JournalEntry(
      id: _existing?.id ?? const Uuid().v4(),
      kind: _kind,
      prompt: _prompt,
      body: _body.text.trim(),
      moodLevel: _mood,
      createdAt: _existing?.createdAt ?? now,
      updatedAt: now,
    );
    try {
      await ref.read(journalRepositoryProvider).save(e);
      ref.invalidate(journalEntriesProvider);
      if (!mounted) return;
      unawaited(MyExHaptics.success());
      showMyExToast(context, context.l10n.journalSaved, success: true);
      context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      showMyExToast(context, context.l10n.commonSaveFailed);
    }
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final ok = await showConfirmDialog(
      context: context,
      title: l.journalDeleteTitle,
      message: l.journalDeleteBody,
      confirmLabel: l.journalDelete,
      cancelLabel: l.commonCancel,
    );
    if (!ok || !mounted) return;
    await ref.read(journalRepositoryProvider).delete(_existing!.id);
    ref.invalidate(journalEntriesProvider);
    if (mounted) context.pop();
  }

  Future<void> _close() async {
    final l = context.l10n;
    if (_dirty && _body.text.trim().isNotEmpty) {
      final discard = await showConfirmDialog(
        context: context,
        title: l.journalDiscardTitle,
        message: l.journalDiscardBody,
        confirmLabel: l.journalDiscard,
        cancelLabel: l.journalKeepWriting,
      );
      if (!discard || !mounted) return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final top = MediaQuery.paddingOf(context).top;
    final canSave = _body.text.trim().isNotEmpty && !_busy;
    return PopScope(
      canPop: !_dirty || _body.text.trim().isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: MyExColors.bg,
        body: ScreenBackground(
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.fromLTRB(
                  MyExSpacing.margin,
                  top + MyExSizes.navBarHeight + MyExSpacing.s3,
                  MyExSpacing.margin,
                  MyExSpacing.s8 + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  MyExSegmented<JournalKind>(
                    value: _kind,
                    segments: {
                      for (final k in JournalKind.values) k: l.journalKind(k),
                    },
                    onChanged: (k) => setState(() {
                      _kind = k;
                      if (_prompt != null) _prompt = l.prompts(k).first;
                    }),
                  ),
                  const Gap(MyExSpacing.s5),
                  if (_prompt != null) ...[
                    Text(
                      _prompt!,
                      style: MyExType.display.copyWith(
                        fontSize: 30,
                        height: 34 / 30,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextLinkButton(
                        label: l.journalAnotherPrompt,
                        small: true,
                        onPressed: _nextPrompt,
                      ),
                    ),
                  ] else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextLinkButton(
                        label: l.journalPromptToday,
                        small: true,
                        onPressed: () =>
                            setState(() => _prompt = l.prompts(_kind).first),
                      ),
                    ),
                  const Gap(MyExSpacing.s3),
                  SolidCard(
                    child: TextField(
                      key: const Key('journal-body'),
                      controller: _body,
                      autofocus: widget.id == null,
                      minLines: 10,
                      maxLines: null,
                      maxLength: 10000,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      style: MyExType.body.copyWith(height: 26 / 17),
                      decoration: InputDecoration(
                        hintText: l.journalEditorHint,
                        counterText: '',
                        isCollapsed: true,
                      ),
                    ),
                  ),
                  const Gap(MyExSpacing.s5),
                  Text(l.journalMoodOptional, style: MyExType.footnote),
                  const Gap(MyExSpacing.s2),
                  MoodScale(
                    value: _mood,
                    dotSize: 30,
                    words: l.moodWords,
                    semantics: l.moodScaleSemantics,
                    onChanged: (v) => setState(() {
                      _mood = _mood == v ? null : v;
                      _dirty = true;
                    }),
                  ),
                  const Gap(MyExSpacing.s5),
                  Footnote(l.journalPrivate, icon: MyExIcons.lock),
                  if (_existing != null) ...[
                    const Gap(MyExSpacing.s4),
                    TextLinkButton(
                      label: l.journalDelete,
                      tone: TextLinkTone.danger,
                      onPressed: _delete,
                    ),
                  ],
                ],
              ),
              NavBar(
                showEdge: true,
                title: _existing == null
                    ? l.journalNew
                    : context.shortDate(_existing!.createdAt),
                leading: GlassIconButton(
                  icon: MyExIcons.close,
                  semanticLabel: l.commonClose,
                  onPressed: _close,
                ),
                trailing: GlassButton(
                  key: const Key('journal-save'),
                  label: l.journalSave,
                  busy: _busy,
                  onPressed: canSave ? _save : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
