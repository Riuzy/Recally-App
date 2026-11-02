import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import '../theme/app_typography.dart';

/// Kerangka layar: margin 20px, judul 20px tebal, jarak 24px ke konten.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.eyebrow,
    this.trailing,
    this.leading,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final Widget? trailing;
  final Widget? leading;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding:
            padding ??
            EdgeInsets.fromLTRB(
              theme.space5,
              theme.space5,
              theme.space5,
              theme.space6,
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  leading!,
                  SizedBox(width: theme.space2),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (eyebrow != null) ...[
                        Text(
                          eyebrow!,
                          style: AppTypography.overline.copyWith(
                            color: colors.muted,
                          ),
                        ),
                        SizedBox(height: theme.space1),
                      ],
                      Text(
                        title,
                        style: AppTypography.h1.copyWith(color: colors.ink),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: theme.space1),
                        Text(
                          subtitle!,
                          style: AppTypography.body.copyWith(
                            color: colors.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: theme.space3),
                  trailing!,
                ],
              ],
            ),
            SizedBox(height: theme.space6),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
