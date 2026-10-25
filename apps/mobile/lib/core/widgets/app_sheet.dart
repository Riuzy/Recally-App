import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';

/// Bottom sheet sesuai `docs/design/desain.md` §7.7.
///
/// Satu-satunya tempat selain bottom navigation yang boleh memakai radius
/// besar (28px atas) dan border kuat.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  final theme = context.appTheme;
  final colors = theme.colors;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    backgroundColor: Colors.transparent,
    barrierColor: colors.overlay,
    builder: (sheetContext) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? colors.surface2 : colors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(theme.radiusSheet),
          ),
          border: Border(top: BorderSide(color: colors.borderStrong)),
        ),
        padding: EdgeInsets.fromLTRB(
          theme.space5,
          theme.space3,
          theme.space5,
          theme.space5 + MediaQuery.viewPaddingOf(sheetContext).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: theme.space4),
            Flexible(child: builder(sheetContext)),
          ],
        ),
      );
    },
  );
}
