import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/format/indonesian_date.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../data/card_repository.dart';
import '../data/review_repository.dart';
import '../domain/srs_engine.dart';
import '../domain/study_session.dart';

/// Ringkasan setelah kartu terakhir dinilai.
class StudySummaryView extends ConsumerWidget {
  const StudySummaryView({
    super.key,
    required this.session,
    required this.onDone,
    this.onRepeatLapsed,
  });

  final StudySession session;
  final VoidCallback onDone;

  /// Dipanggil dengan id kartu yang dinilai "Lupa" bila pengguna ingin
  /// mengulangnya sekarang juga.
  final ValueChanged<List<String>>? onRepeatLapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final colors = context.colors;
    final streak = ref.watch(streakProvider).valueOrNull ?? 0;
    final nextDue = ref.watch(nextDueCardProvider);
    final lapsed = session.lapsedCards;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: theme.space8),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsRegular.checkCircle,
                size: 32,
                color: colors.accent,
              ),
            ),
          ),
          SizedBox(height: theme.space5),
          Text(
            'Sesi selesai.',
            textAlign: TextAlign.center,
            style: AppTypography.h1.copyWith(color: colors.ink),
          ),
          SizedBox(height: theme.space2),
          Text(
            'Kamu menyelesaikan ${session.answeredCount} kartu. '
            'Teruskan besok agar ingatan tetap kuat.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: colors.muted),
          ),
          SizedBox(height: theme.space6),
          AppCard(
            child: Row(
              children: [
                _Count(
                  label: 'Ingat',
                  value: session.countOf(RecallRating.ingat),
                  color: colors.success,
                ),
                _Divider(color: colors.border),
                _Count(
                  label: 'Ragu',
                  value: session.countOf(RecallRating.ragu),
                  color: colors.warning,
                ),
                _Divider(color: colors.border),
                _Count(
                  label: 'Lupa',
                  value: session.countOf(RecallRating.lupa),
                  color: colors.danger,
                ),
              ],
            ),
          ),
          if (streak > 0) ...[
            SizedBox(height: theme.space4),
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.space4,
                  vertical: theme.space3,
                ),
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(theme.radiusControl),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIconsRegular.flame,
                      size: 18,
                      color: colors.warning,
                    ),
                    SizedBox(width: theme.space2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$streak hari beruntun',
                          style: AppTypography.label.copyWith(
                            color: colors.ink,
                          ),
                        ),
                        Text(
                          'Konsistensi mengalahkan durasi.',
                          style: AppTypography.caption.copyWith(
                            color: colors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: theme.space4),
          AppCard(
            padding: EdgeInsets.all(theme.space4),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.surface2,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIconsRegular.clock,
                    size: 18,
                    color: colors.muted,
                  ),
                ),
                SizedBox(width: theme.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jadwal berikutnya',
                        style: AppTypography.caption.copyWith(
                          color: colors.muted,
                        ),
                      ),
                      SizedBox(height: theme.space1),
                      nextDue.when(
                        loading: () => Text(
                          'Memuat…',
                          style: AppTypography.body.copyWith(
                            color: colors.muted,
                          ),
                        ),
                        error: (_, __) => Text(
                          'Tidak tersedia',
                          style: AppTypography.body.copyWith(
                            color: colors.muted,
                          ),
                        ),
                        data: (card) => Text(
                          card == null
                              ? 'Belum ada jadwal'
                              : formatDueLabel(card.dueAt),
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: theme.space6),
          AppButton(label: 'Kembali ke Hari Ini', onPressed: onDone),
          if (lapsed.isNotEmpty && onRepeatLapsed != null) ...[
            SizedBox(height: theme.space2),
            AppButton(
              label: 'Ulangi kartu yang lupa',
              variant: AppButtonVariant.secondary,
              onPressed: () => onRepeatLapsed!(
                lapsed.map((card) => card.id).toList(growable: false),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: AppTypography.h1.copyWith(color: color, height: 1),
          ),
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

class _Divider extends StatelessWidget {
  const _Divider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: color);
  }
}
