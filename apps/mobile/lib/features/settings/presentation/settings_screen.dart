import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/dev/demo_seed.dart';
import '../../../core/settings/theme_mode_provider.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';

/// Tab "Pengaturan".
///
/// Tema sudah berfungsi; pengingat, TTS, dan akun menyusul pada milestone
/// berikutnya.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _seeding = false;
  String? _seedMessage;
  AppBannerTone _seedTone = AppBannerTone.success;

  Future<void> _seedDemo() async {
    final confirmed = await showAppConfirmSheet(
      context,
      title: 'Isi data contoh?',
      message:
          'Deck "Biologi Sel" berisi 12 kartu dan riwayat 7 hari akan '
          'ditambahkan. Data ini hanya untuk mencoba aplikasi.',
      confirmLabel: 'Isi data',
      destructive: false,
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _seeding = true;
      _seedMessage = null;
    });

    try {
      final created = await ref.read(demoSeedProvider).seedIfEmpty();
      if (!mounted) return;
      setState(() {
        _seeding = false;
        _seedTone = created ? AppBannerTone.success : AppBannerTone.info;
        _seedMessage = created
            ? 'Data contoh siap. Buka tab Deck, Hari Ini, atau Progres.'
            : 'Data contoh sudah ada, tidak ada yang ditambahkan.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _seeding = false;
        _seedTone = AppBannerTone.danger;
        _seedMessage = 'Gagal membuat data contoh. Coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          if (demoSeedEnabled) ...[
            SizedBox(height: theme.space8),
            Text(
              'PENGEMBANG',
              style: AppTypography.overline.copyWith(color: colors.muted),
            ),
            SizedBox(height: theme.space3),
            AppListGroup(
              children: [
                AppListRow(
                  title: 'Isi data contoh',
                  subtitle:
                      'Deck "Biologi Sel" dengan 12 kartu dan riwayat 7 '
                      'hari untuk mencoba sesi dan Progres.',
                  leading: Container(
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
                  trailing: _seeding
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.accent,
                          ),
                        )
                      : null,
                  showChevron: !_seeding,
                  onTap: _seeding ? null : _seedDemo,
                ),
              ],
            ),
            if (_seedMessage != null) ...[
              SizedBox(height: theme.space3),
              AppBanner(message: _seedMessage!, tone: _seedTone),
            ],
          ],
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
