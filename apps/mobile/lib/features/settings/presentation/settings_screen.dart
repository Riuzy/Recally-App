import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/settings/theme_mode_provider.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';

/// Tab "Pengaturan".
///
/// Tema sudah berfungsi; pengingat, TTS, dan akun menyusul pada milestone
/// berikutnya.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final colors = theme.colors;
    final themeMode = ref.watch(themeModeProvider);
    final controller = ref.read(themeModeProvider.notifier);

    return AppPage(
      title: 'Pengaturan',
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Text(
            'TAMPILAN',
            style: AppTypography.overline.copyWith(color: colors.muted),
          ),
          SizedBox(height: theme.space3),
          Wrap(
            spacing: theme.space2,
            runSpacing: theme.space2,
            children: [
              for (final mode in ThemeMode.values)
                AppChip(
                  label: mode.label,
                  selected: themeMode == mode,
                  onTap: () => controller.setMode(mode),
                ),
            ],
          ),
          SizedBox(height: theme.space8),
          Text(
            'AKUN',
            style: AppTypography.overline.copyWith(color: colors.muted),
          ),
          SizedBox(height: theme.space3),
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.accentSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIconsRegular.cloudArrowUp,
                    size: 22,
                    color: colors.accent,
                  ),
                ),
                SizedBox(width: theme.space4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sinkronisasi',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.ink,
                        ),
                      ),
                      SizedBox(height: theme.space1),
                      Text(
                        'Login opsional. Aplikasi tetap berjalan penuh tanpa '
                        'akun dan tanpa koneksi.',
                        style: AppTypography.caption.copyWith(
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: theme.space8),
          Text(
            'TENTANG',
            style: AppTypography.overline.copyWith(color: colors.muted),
          ),
          SizedBox(height: theme.space3),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recally',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  ),
                ),
                SizedBox(height: theme.space1),
                Text(
                  'Versi 1.0.0 · Local-first spaced repetition',
                  style: AppTypography.caption.copyWith(color: colors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
