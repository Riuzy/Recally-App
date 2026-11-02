import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/format/indonesian_date.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../study/data/card_repository.dart';
import '../../study/data/review_repository.dart';

/// Tab "Hari Ini": ringkasan kartu jatuh tempo, streak, dan pintu masuk sesi.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = ref.watch(dueCardsProvider);
    final streak = ref.watch(streakProvider).valueOrNull ?? 0;
    final now = DateTime.now();
    final theme = context.appTheme;
    final colors = context.colors;

    return AppPage(
      eyebrow: formatLongDate(now).toUpperCase(),
      title: _greeting(now.hour),
      subtitle: 'Belajar sedikit, ingat lebih lama.',
      trailing: streak > 0
          ? AppChip(
              label: '$streak hari',
              icon: PhosphorIconsRegular.flame,
              selected: true,
            )
          : null,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          AppCard(
            padding: EdgeInsets.all(theme.space5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SESI HARI INI',
                  style: AppTypography.overline.copyWith(color: colors.muted),
                ),
                SizedBox(height: theme.space3),
                due.when(
                  loading: () => const _HeroSkeleton(),
                  error: (_, __) => AppBanner(
                    tone: AppBannerTone.danger,
                    message: 'Kartu jatuh tempo gagal dimuat.',
                    actionLabel: 'Coba lagi',
                    onAction: () => ref.invalidate(dueCardsProvider),
                  ),
                  data: (cards) => _HeroBody(cards: cards),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(int hour) {
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }
}

class _HeroBody extends StatelessWidget {
  const _HeroBody({required this.cards});

  final List<CardRow> cards;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = context.colors;
    final hasCards = cards.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${cards.length}',
              style: AppTypography.display.copyWith(
                color: colors.ink,
                height: 1,
              ),
            ),
            SizedBox(width: theme.space2),
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'kartu siap diulang',
                style: AppTypography.body.copyWith(color: colors.inkSoft),
              ),
            ),
          ],
        ),
        SizedBox(height: theme.space5),
        AppButton(
          label: 'Mulai sesi',
          icon: PhosphorIconsRegular.play,
          onPressed: hasCards ? () => context.push('/session') : null,
        ),
        if (hasCards) ...[
          SizedBox(height: theme.space2),
          Text(
            'Perkiraan ${_estimateMinutes(cards.length)} menit',
            style: AppTypography.caption.copyWith(color: colors.muted),
          ),
        ] else ...[
          SizedBox(height: theme.space3),
          AppButton(
            label: 'Buka Deck',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go('/decks'),
          ),
          SizedBox(height: theme.space2),
          Text(
            'Belum ada kartu jatuh tempo. Tambahkan kartu di deck.',
            style: AppTypography.caption.copyWith(color: colors.muted),
          ),
        ],
      ],
    );
  }

  int _estimateMinutes(int cardCount) {
    final minutes = (cardCount * 20 / 60).ceil();
    return minutes < 1 ? 1 : minutes;
  }
}

/// Skeleton tanpa shimmer (desain §8.2).
class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;

    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surface3,
        borderRadius: BorderRadius.circular(4),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            bar(56, 36),
            SizedBox(width: theme.space2),
            Padding(padding: EdgeInsets.only(bottom: 6), child: bar(124, 12)),
          ],
        ),
        SizedBox(height: theme.space5),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: colors.surface2,
            borderRadius: BorderRadius.circular(theme.radiusControl),
          ),
        ),
        SizedBox(height: theme.space2),
        bar(96, 10),
      ],
    );
  }
}
