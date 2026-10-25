import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import '../theme/app_typography.dart';

enum AppBannerTone { info, success, warning, danger }

/// Banner inline sesuai `docs/design/desain.md` §7.9 dan §8.
///
/// Dipakai untuk status offline, error ringan, atau konfirmasi. Bukan untuk
/// pesan pemasaran.
class AppBanner extends StatelessWidget {
  const AppBanner({
    super.key,
    required this.message,
    this.tone = AppBannerTone.info,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final AppBannerTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;

    final (Color background, Color border, Color foreground, IconData icon) =
        switch (tone) {
          AppBannerTone.info => (
            colors.infoSoft,
            colors.info,
            colors.info,
            Icons.info_outline,
          ),
          AppBannerTone.success => (
            colors.successSoft,
            colors.success,
            colors.success,
            Icons.check_circle_outline,
          ),
          AppBannerTone.warning => (
            colors.warningSoft,
            colors.warning,
            colors.warning,
            Icons.warning_amber_outlined,
          ),
          AppBannerTone.danger => (
            colors.dangerSoft,
            colors.danger,
            colors.danger,
            Icons.error_outline,
          ),
        };

    return Container(
      padding: EdgeInsets.all(theme.space4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(theme.radiusControl),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: foreground),
          SizedBox(width: theme.space3),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body.copyWith(color: foreground),
            ),
          ),
          if (actionLabel != null) ...[
            SizedBox(width: theme.space2),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTypography.label.copyWith(color: colors.accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
