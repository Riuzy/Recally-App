import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/format/indonesian_date.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../data/progress_repository.dart';
import '../domain/progress_stats.dart';
import 'activity_chart.dart';

/// Tab "Progres": retensi, aktivitas, penguasaan kartu, dan progres per deck.
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  ProgressPeriod _period = ProgressPeriod.week;

  Future<void> _pickPeriod() async {
    final selected = await showAppSheet<ProgressPeriod>(
      context: context,
      builder: (sheetContext) {
        final theme = sheetContext.appTheme;
        final colors = sheetContext.colors;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Rentang waktu',
              style: AppTypography.h3.copyWith(color: colors.ink),
            ),
            SizedBox(height: theme.space4),
            AppListGroup(
              children: [
                for (final period in ProgressPeriod.values)
                  AppListRow(
                    title: period.label,
                    subtitle: period == ProgressPeriod.week
                        ? 'Retensi dan aktivitas 7 hari terakhir.'
                        : 'Retensi dan aktivitas 30 hari terakhir.',
                    trailing: period == _period
                        ? Icon(
                            PhosphorIconsRegular.check,
                            size: 20,
                            color: colors.accent,
                          )
                        : null,
                    onTap: () => Navigator.of(sheetContext).pop(period),
                  ),
              ],
            ),
          ],
        );
      },
    );

    if (selected == null || !mounted) return;
    setState(() => _period = selected);
  }

  void _retry() {
    ref.invalidate(cardProgressProvider);
    ref.invalidate(reviewActivityProvider(_period));
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(cardProgressProvider);
    final reviews = ref.watch(reviewActivityProvider(_period));
    final cardStats = cards.valueOrNull;
    final activity = reviews.valueOrNull;

    Widget child;
    if (cards.hasError || reviews.hasError) {
      child = _ProgressError(onRetry: _retry);
    } else if (cardStats == null || activity == null) {
      child = const _ProgressSkeleton();
    } else if (!activity.hasAnyReview) {
      child = AppEmptyState(
        icon: PhosphorIconsRegular.chartLine,
        title: 'Mulai sesi pertamamu',
        message:
            'Progres, retensi, dan riwayat muncul setelah kamu menyelesaikan '
            'satu sesi belajar.',
        action: AppButton(
          label: 'Mulai sesi',
          expand: false,
          onPressed: () => context.push('/session'),
        ),
      );
    } else {
      child = _ProgressContent(cardStats: cardStats, activity: activity);
    }

    return AppPage(
      title: 'Progres',
      trailing: AppChip(
        label: _period.label,
        trailingIcon: PhosphorIconsRegular.caretDown,
        onTap: _pickPeriod,
      ),
      child: child,
    );
  }
}

class _ProgressContent extends StatelessWidget {
  const _ProgressContent({required this.cardStats, required this.activity});

  final CardProgress cardStats;
  final ReviewActivity activity;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = context.colors;
    final decks = cardStats.decks.take(4).toList(growable: false);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _RetentionCard(activity: activity),
        SizedBox(height: theme.space4),
        _MetricRow(cardStats: cardStats, activity: activity),
        SizedBox(height: theme.space4),
        _ActivitySection(activity: activity),
        SizedBox(height: theme.space4),
        _MasterySection(cardStats: cardStats),
        if (decks.isNotEmpty) ...[
          SizedBox(height: theme.space5),
          Text('Per deck', style: AppTypography.h3.copyWith(color: colors.ink)),
          SizedBox(height: theme.space3),
          _DeckList(decks: decks),
        ],
        if (activity.recentDays.isNotEmpty) ...[
          SizedBox(height: theme.space5),
          Text(
            'Riwayat belajar',
            style: AppTypography.h3.copyWith(color: colors.ink),
          ),
          SizedBox(height: theme.space3),
          _HistoryList(days: activity.recentDays),
        ],
        SizedBox(height: theme.space4),
      ],
    );
  }
}

class _RetentionCard extends StatelessWidget {
  const _RetentionCard({required this.activity});

  final ReviewActivity activity;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = context.colors;
    final retention = activity.retention;
    final delta = activity.retentionDelta;

    final value = retention == null ? '—' : '${(retention * 100).round()}%';
    final helper = retention == null
        ? 'Belum ada ulasan pada periode ini.'
        : delta == null
        ? 'Belum ada data pembanding.'
        : 'Dibanding ${activity.period.comparisonLabel} '
              '${_signedPoints(delta)} poin.';

    return AppCard(
      padding: EdgeInsets.all(theme.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTypography.display.copyWith(
                  color: colors.ink,
                  height: 1,
                ),
              ),
              SizedBox(width: theme.space2),
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  'retensi',
                  style: AppTypography.body.copyWith(color: colors.muted),
                ),
              ),
            ],
          ),
          SizedBox(height: theme.space4),
          AppProgressBar(value: retention ?? 0),
          SizedBox(height: theme.space3),
          Text(
            helper,
            style: AppTypography.caption.copyWith(color: colors.muted),
          ),
        ],
      ),
    );
  }

  String _signedPoints(double delta) {
    final points = (delta * 100).round();
    return points >= 0 ? '+$points' : '$points';
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.cardStats, required this.activity});

  final CardProgress cardStats;
  final ReviewActivity activity;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(vertical: theme.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(theme.radiusCard),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          _Metric(value: '${activity.streak} hari', label: 'streak'),
          _MetricDivider(color: colors.border),
          _Metric(value: '${cardStats.total}', label: 'kartu'),
          _MetricDivider(color: colors.border),
          _Metric(
            value: '${(cardStats.mastery * 100).round()}%',
            label: 'dikuasai',
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTypography.h3.copyWith(color: colors.ink)),
          SizedBox(height: context.appTheme.space1),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: colors.muted),
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: color);
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.activity});

  final ReviewActivity activity;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = context.colors;

    return AppCard(
      padding: EdgeInsets.all(theme.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Aktivitas',
                style: AppTypography.label.copyWith(color: colors.ink),
              ),
              const Spacer(),
              Text(
                '${activity.total} ulasan',
                style: AppTypography.caption.copyWith(color: colors.muted),
              ),
            ],
          ),
          SizedBox(height: theme.space4),
          ActivityChart(days: activity.days),
          if (activity.total == 0) ...[
            SizedBox(height: theme.space2),
            Text(
              'Belum ada ulasan pada periode ini.',
              style: AppTypography.caption.copyWith(color: colors.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _MasterySection extends StatelessWidget {
  const _MasterySection({required this.cardStats});

  final CardProgress cardStats;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = context.colors;

    return AppCard(
      padding: EdgeInsets.all(theme.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Kartu dikuasai',
                style: AppTypography.label.copyWith(color: colors.ink),
              ),
              const Spacer(),
              Text(
                '${(cardStats.mastery * 100).round()}%',
                style: AppTypography.label.copyWith(color: colors.accent),
              ),
            ],
          ),
          SizedBox(height: theme.space3),
          _MasteryBar(cardStats: cardStats),
          SizedBox(height: theme.space3),
          Wrap(
            spacing: theme.space4,
            runSpacing: theme.space2,
            children: [
              _Legend(
                color: colors.success,
                label: '${cardStats.mastered} dikuasai',
              ),
              _Legend(
                color: colors.warning,
                label: '${cardStats.learning} sedang dipelajari',
              ),
              _Legend(color: colors.border, label: '${cardStats.fresh} baru'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MasteryBar extends StatelessWidget {
  const _MasteryBar({required this.cardStats});

  final CardProgress cardStats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 6,
        width: double.infinity,
        child: cardStats.total == 0
            ? ColoredBox(color: colors.surface3)
            : Row(
                children: [
                  if (cardStats.mastered > 0)
                    Expanded(
                      flex: cardStats.mastered,
                      child: ColoredBox(color: colors.success),
                    ),
                  if (cardStats.learning > 0)
                    Expanded(
                      flex: cardStats.learning,
                      child: ColoredBox(color: colors.warning),
                    ),
                  if (cardStats.fresh > 0)
                    Expanded(
                      flex: cardStats.fresh,
                      child: ColoredBox(color: colors.border),
                    ),
                ],
              ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: context.appTheme.space2),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: context.colors.muted),
        ),
      ],
    );
  }
}

class _DeckList extends StatelessWidget {
  const _DeckList({required this.decks});

  final List<DeckProgress> decks;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < decks.length; index++) ...[
            if (index > 0)
              Divider(height: 1, thickness: 1, color: colors.border),
            _DeckRow(deck: decks[index]),
          ],
        ],
      ),
    );
  }
}

class _DeckRow extends StatelessWidget {
  const _DeckRow({required this.deck});

  final DeckProgress deck;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = context.colors;

    return InkWell(
      onTap: () => context.go('/decks/${deck.deckId}'),
      child: Padding(
        padding: EdgeInsets.all(theme.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.accentSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIconsRegular.cards,
                    size: 18,
                    color: colors.accent,
                  ),
                ),
                SizedBox(width: theme.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deck.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.ink,
                        ),
                      ),
                      SizedBox(height: theme.space1),
                      Text(
                        '${deck.mastered} dari ${deck.total} kartu dikuasai',
                        style: AppTypography.caption.copyWith(
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: theme.space2),
                Text(
                  '${(deck.mastery * 100).round()}%',
                  style: AppTypography.label.copyWith(color: colors.ink),
                ),
                SizedBox(width: theme.space1),
                Icon(
                  PhosphorIconsRegular.caretRight,
                  size: 16,
                  color: colors.muted,
                ),
              ],
            ),
            SizedBox(height: theme.space3),
            AppProgressBar(value: deck.mastery),
          ],
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.days});

  final List<DayReviewSummary> days;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = context.colors;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < days.length; index++) ...[
            if (index > 0)
              Divider(height: 1, thickness: 1, color: colors.border),
            Padding(
              padding: EdgeInsets.all(theme.space4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatDayLabel(days[index].day),
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.ink,
                          ),
                        ),
                        SizedBox(height: theme.space1),
                        Text(
                          '${days[index].reviews} ulasan',
                          style: AppTypography.caption.copyWith(
                            color: colors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${days[index].ingat} Ingat',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.success,
                    ),
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

class _ProgressSkeleton extends StatelessWidget {
  const _ProgressSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = context.colors;

    Widget block(double height) => Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(theme.radiusCard),
      ),
    );

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        block(150),
        SizedBox(height: theme.space4),
        block(76),
        SizedBox(height: theme.space4),
        block(260),
        SizedBox(height: theme.space4),
        block(112),
      ],
    );
  }
}

class _ProgressError extends StatelessWidget {
  const _ProgressError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.space5),
        child: AppBanner(
          tone: AppBannerTone.danger,
          message: 'Statistik gagal dimuat.',
          actionLabel: 'Coba lagi',
          onAction: onRetry,
        ),
      ),
    );
  }
}
