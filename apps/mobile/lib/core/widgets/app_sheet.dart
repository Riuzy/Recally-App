import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';

/// Bottom sheet putih dengan sudut atas 24px dan handle tipis.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  final theme = context.appTheme;
  final colors = theme.colors;

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    isDismissible: isDismissible,
    backgroundColor: Colors.transparent,
    barrierColor: colors.overlay,
    builder: (sheetContext) {
      return Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(theme.radiusSheet),
          ),
          border: Border(top: BorderSide(color: colors.border)),
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
                color: colors.border,
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
