import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../decks/data/deck_repository.dart';
import '../data/card_repository.dart';
import '../domain/srs_engine.dart';
import '../domain/study_session.dart';
import 'study_summary_view.dart';

/// Sesi belajar layar penuh: tulis jawaban, cek, nilai, lalu ringkasan.
class StudySessionScreen extends ConsumerStatefulWidget {
  const StudySessionScreen({super.key, this.cardIds});

  /// Bila diisi, sesi hanya memakai kartu ini (mis. "Ulangi kartu yang lupa").
  /// Bila null, sesi memakai snapshot kartu yang jatuh tempo.
  final List<String>? cardIds;

  @override
  ConsumerState<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends ConsumerState<StudySessionScreen> {
  final TextEditingController _answer = TextEditingController();
  final FocusNode _answerFocus = FocusNode();

  StudySession? _session;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _answer.dispose();
    _answerFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final repository = ref.read(cardRepositoryProvider);
      final cards = widget.cardIds == null
          ? await repository.dueCards()
          : await repository.cardsByIds(widget.cardIds!);
      if (!mounted) return;
      setState(() {
        _session = StudySession(cards: cards);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Sesi gagal dimuat. Periksa lagi sebentar.';
      });
    }
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/today');
    }
  }

  void _submitAnswer() {
    final session = _session;
    if (session == null) return;
    setState(() => session.submitAnswer(_answer.text));
    _answerFocus.unfocus();
  }

  void _reveal() {
    final session = _session;
    if (session == null) return;
    setState(() => session.reveal());
    _answerFocus.unfocus();
  }

  Future<void> _grade(RecallRating rating) async {
    final session = _session;
    if (session == null || _saving) return;

    setState(() {
      _saving = true;
      _saveError = null;
    });

    try {
      await ref
          .read(cardRepositoryProvider)
          .applyReview(card: session.current.card, rating: rating);
      if (!mounted) return;
      setState(() {
        session.grade(rating);
        _saving = false;
        _answer.clear();
      });
      if (!session.finished && session.step == StudyStep.jawab) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _answerFocus.requestFocus();
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError = 'Nilai gagal disimpan. Coba pilih sekali lagi.';
      });
    }
  }

  Future<void> _openModeSheet() async {
    final session = _session;
    if (session == null) return;

    final selected = await showAppSheet<StudyMode>(
      context: context,
      builder: (sheetContext) {
        final theme = sheetContext.appTheme;
        final colors = sheetContext.colors;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Mode belajar',
              style: AppTypography.h3.copyWith(color: colors.ink),
            ),
            SizedBox(height: theme.space4),
            AppListGroup(
              children: [
                AppListRow(
                  title: 'Tulis jawaban',
                  subtitle: 'Ketik jawaban sebelum jawaban benar dibuka.',
                  trailing: session.mode == StudyMode.tulis
                      ? Icon(
                          PhosphorIconsRegular.check,
                          size: 20,
                          color: colors.accent,
                        )
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(StudyMode.tulis),
                ),
                AppListRow(
                  title: 'Hafalan',
                  subtitle: 'Balik kartu tanpa mengetik, lalu nilai ingatanmu.',
                  trailing: session.mode == StudyMode.hafalan
                      ? Icon(
                          PhosphorIconsRegular.check,
                          size: 20,
                          color: colors.accent,
                        )
                      : null,
                  onTap: () =>
                      Navigator.of(sheetContext).pop(StudyMode.hafalan),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (selected == null || !mounted) return;
    _setMode(selected);
  }

  void _setMode(StudyMode mode) {
    final session = _session;
    if (session == null) return;

    setState(() => session.setMode(mode));
    if (mode == StudyMode.hafalan) {
      _answerFocus.unfocus();
      return;
    }
    if (session.step == StudyStep.jawab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _answerFocus.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.canvas,
      body: SafeArea(
        child: switch (_session) {
          _ when _loading => const Center(child: CircularProgressIndicator()),
          _ when _loadError != null => _LoadError(
            message: _loadError!,
            onRetry: _load,
            onClose: _close,
          ),
          final session? when session.isEmpty => _EmptySession(onClose: _close),
          final session? when session.finished => Padding(
            padding: EdgeInsets.all(context.appTheme.space5),
            child: StudySummaryView(
              session: session,
              onDone: () => context.go('/today'),
              onRepeatLapsed: (ids) =>
                  context.pushReplacement('/session?cards=${ids.join(',')}'),
            ),
          ),
          final session? => _SessionBody(
            session: session,
            answer: _answer,
            answerFocus: _answerFocus,
            saving: _saving,
            saveError: _saveError,
            onClose: _close,
            onMode: _openModeSheet,
            onSubmit: _submitAnswer,
            onReveal: _reveal,
            onGrade: _grade,
            onAnswerChanged: () => setState(() {}),
            onSwitchMode: _setMode,
            deckId: session.current.card.deckId,
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _SessionBody extends ConsumerWidget {
  const _SessionBody({
    required this.session,
    required this.answer,
    required this.answerFocus,
    required this.saving,
    required this.saveError,
    required this.onClose,
    required this.onMode,
    required this.onSubmit,
    required this.onReveal,
    required this.onGrade,
    required this.onAnswerChanged,
    required this.onSwitchMode,
    required this.deckId,
  });

  final StudySession session;
  final TextEditingController answer;
  final FocusNode answerFocus;
  final bool saving;
  final String? saveError;
  final VoidCallback onClose;
  final VoidCallback onMode;
  final VoidCallback onSubmit;
  final VoidCallback onReveal;
  final ValueChanged<RecallRating> onGrade;
  final VoidCallback onAnswerChanged;
  final ValueChanged<StudyMode> onSwitchMode;
  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final deckName = ref.watch(deckByIdProvider(deckId)).valueOrNull?.name;
    final card = session.current.card;
    final showingAnswer = session.step == StudyStep.nilai;

    return Column(
      children: [
        _SessionTopBar(
          position: session.position,
          total: session.total,
          onClose: onClose,
          onMode: onMode,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.space5),
          child: AppProgressBar(value: session.progress),
        ),
        SizedBox(height: theme.space4),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              theme.space5,
              theme.space2,
              theme.space5,
              theme.space6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (deckName != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppChip(label: deckName),
                  ),
                  SizedBox(height: theme.space4),
                ],
                if (showingAnswer)
                  _GradingCard(
                    session: session,
                    card: card,
                    saving: saving,
                    saveError: saveError,
                    onGrade: onGrade,
                  )
                else
                  _QuestionCard(
                    session: session,
                    card: card,
                    answer: answer,
                    answerFocus: answerFocus,
                    onAnswerChanged: onAnswerChanged,
                  ),
              ],
            ),
          ),
        ),
        if (!showingAnswer)
          _AnswerActions(
            mode: session.mode,
            canSubmit: answer.text.trim().isNotEmpty,
            onSubmit: onSubmit,
            onReveal: onReveal,
            onSwitchMode: onSwitchMode,
            onMode: onMode,
          ),
      ],
    );
  }
}

class _SessionTopBar extends StatelessWidget {
  const _SessionTopBar({
    required this.position,
    required this.total,
    required this.onClose,
    required this.onMode,
  });

  final int position;
  final int total;
  final VoidCallback onClose;
  final VoidCallback onMode;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = context.colors;

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Tutup sesi',
            onPressed: onClose,
            icon: Icon(PhosphorIconsRegular.x, size: 22, color: colors.ink),
          ),
          Expanded(
            child: Text(
              'Kartu $position dari $total',
              textAlign: TextAlign.center,
              style: AppTypography.label.copyWith(color: colors.muted),
            ),
          ),
          TextButton(
            onPressed: onMode,
            style: TextButton.styleFrom(
              minimumSize: const Size(56, 44),
              padding: EdgeInsets.symmetric(horizontal: theme.space2),
            ),
            child: Text(
              'Mode',
              style: AppTypography.label.copyWith(color: colors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.session,
    required this.card,
    required this.answer,
    required this.answerFocus,
    required this.onAnswerChanged,
  });

  final StudySession session;
  final CardRow card;
  final TextEditingController answer;
  final FocusNode answerFocus;
  final VoidCallback onAnswerChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'PERTANYAAN',
            style: AppTypography.overline.copyWith(color: colors.muted),
          ),
          SizedBox(height: theme.space3),
          Text(card.front, style: AppTypography.h2.copyWith(color: colors.ink)),
          SizedBox(height: theme.space5),
          if (session.mode == StudyMode.tulis) ...[
            AppTextField(
              label: 'Jawabanmu',
              hint: 'Tulis jawaban dengan kata-katamu sendiri.',
              controller: answer,
              focusNode: answerFocus,
              minLines: 3,
              maxLines: 5,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => onAnswerChanged(),
            ),
          ] else ...[
            Text(
              'Pikirkan jawabannya, lalu balik kartu.',
              style: AppTypography.body.copyWith(color: colors.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _GradingCard extends StatelessWidget {
  const _GradingCard({
    required this.session,
    required this.card,
    required this.saving,
    required this.saveError,
    required this.onGrade,
  });

  final StudySession session;
  final CardRow card;
  final bool saving;
  final String? saveError;
  final ValueChanged<RecallRating> onGrade;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'PERTANYAAN',
          style: AppTypography.overline.copyWith(color: colors.muted),
        ),
        SizedBox(height: theme.space2),
        Text(card.front, style: AppTypography.h3.copyWith(color: colors.ink)),
        SizedBox(height: theme.space5),
        if (session.mode == StudyMode.tulis) ...[
          _AnswerPanel(label: 'Jawabanmu', text: session.current.answer),
          SizedBox(height: theme.space3),
        ],
        _AnswerPanel(label: 'Jawaban benar', text: card.back, correct: true),
        SizedBox(height: theme.space6),
        Text(
          'Seberapa yakin kamu?',
          style: AppTypography.label.copyWith(color: colors.ink),
        ),
        SizedBox(height: theme.space3),
        _GradeButtons(enabled: !saving, onGrade: onGrade),
        if (saving) ...[
          SizedBox(height: theme.space3),
          Text(
            'Menyimpan nilai…',
            style: AppTypography.caption.copyWith(color: colors.muted),
          ),
        ],
        if (saveError != null) ...[
          SizedBox(height: theme.space3),
          AppBanner(tone: AppBannerTone.danger, message: saveError!),
        ],
        SizedBox(height: theme.space3),
        Text(
          'Jadwal berikutnya dihitung otomatis dari pilihanmu.',
          style: AppTypography.caption.copyWith(color: colors.muted),
        ),
      ],
    );
  }
}

class _AnswerPanel extends StatelessWidget {
  const _AnswerPanel({
    required this.label,
    required this.text,
    this.correct = false,
  });

  final String label;
  final String text;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = context.colors;
    final radius = BorderRadius.circular(theme.radiusCard);

    return Container(
      decoration: BoxDecoration(
        color: correct ? colors.surface : colors.surface2,
        borderRadius: radius,
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (correct)
              ColoredBox(color: colors.accent, child: SizedBox(width: 2)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(theme.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.caption.copyWith(
                        color: colors.muted,
                      ),
                    ),
                    SizedBox(height: theme.space2),
                    Text(
                      text,
                      style: AppTypography.body.copyWith(color: colors.ink),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeButtons extends StatelessWidget {
  const _GradeButtons({required this.enabled, required this.onGrade});

  final bool enabled;
  final ValueChanged<RecallRating> onGrade;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Row(
      children: [
        Expanded(
          child: _GradeButton(
            label: 'Lupa',
            helper: 'Ulang lagi',
            icon: PhosphorIconsRegular.x,
            foreground: theme.colors.danger,
            background: theme.colors.dangerSoft,
            onTap: enabled ? () => onGrade(RecallRating.lupa) : null,
          ),
        ),
        SizedBox(width: theme.space2),
        Expanded(
          child: _GradeButton(
            label: 'Ragu',
            helper: 'Ulang segera',
            icon: PhosphorIconsRegular.question,
            foreground: theme.colors.warning,
            background: theme.colors.warningSoft,
            onTap: enabled ? () => onGrade(RecallRating.ragu) : null,
          ),
        ),
        SizedBox(width: theme.space2),
        Expanded(
          child: _GradeButton(
            label: 'Ingat',
            helper: 'Ulang nanti',
            icon: PhosphorIconsRegular.check,
            foreground: theme.colors.success,
            background: theme.colors.successSoft,
            onTap: enabled ? () => onGrade(RecallRating.ingat) : null,
          ),
        ),
      ],
    );
  }
}

class _GradeButton extends StatelessWidget {
  const _GradeButton({
    required this.label,
    required this.helper,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onTap,
  });

  final String label;
  final String helper;
  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final radius = BorderRadius.circular(theme.radiusControl);

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: '$label, $helper',
      child: Material(
        color: background,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 92,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: foreground.withValues(alpha: 0.28)),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: theme.space2,
              vertical: theme.space3,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: foreground),
                SizedBox(height: theme.space1),
                Text(
                  label,
                  style: AppTypography.label.copyWith(color: foreground),
                ),
                SizedBox(height: 2),
                Text(
                  helper,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: foreground.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerActions extends StatelessWidget {
  const _AnswerActions({
    required this.mode,
    required this.canSubmit,
    required this.onSubmit,
    required this.onReveal,
    required this.onSwitchMode,
    required this.onMode,
  });

  final StudyMode mode;
  final bool canSubmit;
  final VoidCallback onSubmit;
  final VoidCallback onReveal;
  final ValueChanged<StudyMode> onSwitchMode;
  final VoidCallback onMode;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        theme.space5,
        theme.space3,
        theme.space5,
        theme.space4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mode == StudyMode.tulis)
            AppButton(
              label: 'Periksa jawaban',
              onPressed: canSubmit ? onSubmit : null,
            )
          else
            AppButton(label: 'Lihat jawaban', onPressed: onReveal),
          SizedBox(height: theme.space1),
          if (mode == StudyMode.tulis)
            AppButton(
              label: 'Lihat jawaban',
              variant: AppButtonVariant.text,
              onPressed: onReveal,
            )
          else
            AppButton(
              label: 'Tulis jawaban',
              variant: AppButtonVariant.text,
              onPressed: () => onSwitchMode(StudyMode.tulis),
            ),
          if (mode == StudyMode.tulis) ...[
            SizedBox(height: theme.space1),
            TextButton(
              onPressed: onMode,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: EdgeInsets.symmetric(horizontal: theme.space2),
                foregroundColor: context.colors.muted,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mode: Tulis jawaban',
                    style: AppTypography.caption.copyWith(
                      color: context.colors.muted,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    PhosphorIconsRegular.caretRight,
                    size: 12,
                    color: context.colors.muted,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({
    required this.message,
    required this.onRetry,
    required this.onClose,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Padding(
      padding: EdgeInsets.all(theme.space5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppBanner(
            tone: AppBannerTone.danger,
            message: message,
            actionLabel: 'Coba lagi',
            onAction: onRetry,
          ),
          SizedBox(height: theme.space4),
          AppButton(
            label: 'Tutup',
            variant: AppButtonVariant.secondary,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _EmptySession extends StatelessWidget {
  const _EmptySession({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: PhosphorIconsRegular.cards,
      title: 'Tidak ada kartu untuk diulang',
      message: 'Semua kartu sudah terjadwal. Kembali lagi nanti.',
      action: AppButton(
        label: 'Kembali ke Hari Ini',
        variant: AppButtonVariant.secondary,
        expand: false,
        onPressed: onClose,
      ),
    );
  }
}
