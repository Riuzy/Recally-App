import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';
import 'app_sheet.dart';

/// Konfirmasi destruktif dalam bottom sheet tema-aware.
///
/// Mengembalikan `true` hanya bila pengguna menekan tombol konfirmasi.
Future<bool> showAppConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Hapus',
  String cancelLabel = 'Batal',
  bool destructive = true,
}) async {
  final result = await showAppSheet<bool>(
    context: context,
    builder: (sheetContext) {
      final theme = sheetContext.appTheme;
      final colors = sheetContext.colors;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTypography.h3.copyWith(color: colors.ink)),
          SizedBox(height: theme.space2),
          Text(
            message,
            style: AppTypography.body.copyWith(color: colors.inkSoft),
          ),
          SizedBox(height: theme.space6),
          AppButton(
            label: confirmLabel,
            variant: destructive
                ? AppButtonVariant.danger
                : AppButtonVariant.primary,
            onPressed: () => Navigator.of(sheetContext).pop(true),
          ),
          SizedBox(height: theme.space2),
          AppButton(
            label: cancelLabel,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(sheetContext).pop(false),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
