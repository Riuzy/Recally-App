import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import '../theme/app_typography.dart';

enum AppBannerTone { info, success, warning, danger }

/// Banner inline premium: ikon + teks + aksi. Tone sesuai intent.
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

    final (
      Color bgColor,
      Color borderColor,
      Color iconColor,
      IconData icon,
    ) = switch (tone) {
      AppBannerTone.info => (
        colors.infoSoft,
        colors.info,
        colors.ink,
        Icons.info_outline,
      ),
      AppBannerTone.success => (
        colors.successSoft,
        colors.success,
        colors.ink,
        Icons.check_circle_outline,
      ),
      AppBannerTone.warning => (
        colors.warningSoft,
        colors.warning,
        colors.ink,
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
        color: bgColor,
        borderRadius: BorderRadius.circular(theme.radiusControl),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          SizedBox(width: theme.space3),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body.copyWith(color: iconColor, height: 1.5),
            ),
          ),
          if (actionLabel != null) ...[
            SizedBox(width: theme.space2),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTypography.label.copyWith(
                  color: colors.accentStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
