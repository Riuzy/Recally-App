import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import '../theme/app_typography.dart';

/// Kerangka layar: margin 20px, judul H1, jarak 32px ke konten, dan ruang
/// bawah untuk bottom navigation yang mengambang.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding:
            padding ??
            EdgeInsets.fromLTRB(
              theme.space5,
              theme.space6,
              theme.space5,
              72 + bottomInset + theme.space6,
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                if (trailing != null) trailing!,
              ],
            ),
            SizedBox(height: theme.space8),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
