import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_theme_extension.dart';
import '../theme/app_typography.dart';

/// Grup baris sesuai desain §7.8: satu wadah, divider 1px, tanpa kartu per
/// baris. Dipakai untuk daftar deck, kartu, dan pengaturan.
class AppListGroup extends StatelessWidget {
  const AppListGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;
    final radius = BorderRadius.circular(theme.radiusCard);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final rows = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (index > 0) {
        rows.add(Divider(height: 1, thickness: 1, color: colors.border));
      }
      rows.add(children[index]);
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: radius,
        border: Border.all(color: colors.border),
        boxShadow: [isDark ? colors.innerHighlight : colors.shadowSurface],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(mainAxisSize: MainAxisSize.min, children: rows),
      ),
    );
  }
}

/// Satu baris daftar: judul, metadata opsional, aksi di kanan.
class AppListRow extends StatelessWidget {
  const AppListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = false,
    this.destructive = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;

    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.space4,
          vertical: theme.space3,
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, SizedBox(width: theme.space3)],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: destructive ? colors.danger : colors.ink,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: theme.space1),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label.copyWith(
                        fontWeight: FontWeight.w400,
                        color: colors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[SizedBox(width: theme.space2), trailing!],
            if (showChevron) ...[
              SizedBox(width: theme.space2),
              Icon(
                PhosphorIconsRegular.caretRight,
                size: 18,
                color: colors.muted,
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}
