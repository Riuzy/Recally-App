import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import '../theme/app_typography.dart';

/// Empty state sesuai `docs/design/desain.md` §8.1: satu ikon, satu judul,
/// satu penjelasan singkat, satu aksi.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: theme.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: colors.accent),
            ),
            SizedBox(height: theme.space5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.h3.copyWith(color: colors.ink),
            ),
            if (message != null) ...[
              SizedBox(height: theme.space2),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: colors.muted),
              ),
            ],
            if (action != null) ...[
              SizedBox(height: theme.space6),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
