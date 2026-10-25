import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import '../theme/app_typography.dart';

/// Input sesuai `docs/design/desain.md` §7.2.
///
/// Label selalu berada di atas field, bukan placeholder. Fokus memakai border
/// `accent` plus ring 3px lembut di belakangnya.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.maxLines = 1,
    this.minLines,
    this.errorText,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.suffixIcon,
    this.autofocus = false,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int maxLines;
  final int? minLines;
  final String? errorText;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool autofocus;
  final bool enabled;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  late final bool _ownsFocusNode = widget.focusNode == null;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focused == _focusNode.hasFocus) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showRing = _focused && widget.enabled;

    final ringColor = isDark
        ? colors.accent.withValues(alpha: 0.18)
        : colors.accentSoft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.label.copyWith(color: colors.inkSoft),
        ),
        SizedBox(height: theme.space2),
        AnimatedContainer(
          duration: theme.motionFast,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.radiusControl),
            boxShadow: showRing
                ? [
                    BoxShadow(
                      color: ringColor,
                      spreadRadius: 3,
                      blurRadius: 0,
                    ),
                  ]
                : const [],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            obscureText: widget.obscureText,
            autofocus: widget.autofocus,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            style: AppTypography.body.copyWith(
              color: widget.enabled ? colors.ink : colors.muted,
            ),
            cursorColor: colors.accent,
            decoration: InputDecoration(
              hintText: widget.hint,
              errorText: widget.errorText,
              helperText: widget.helperText,
              helperMaxLines: 2,
              errorMaxLines: 2,
              suffixIcon: widget.suffixIcon,
              suffixIconColor: colors.muted,
            ),
          ),
        ),
      ],
    );
  }
}
