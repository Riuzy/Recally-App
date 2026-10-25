import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';

/// Kerangka 4 tab dengan bottom navigation glass
/// (`docs/design/desain.md` §7.6).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<_TabSpec> _tabs = [
    _TabSpec(
      label: 'Hari Ini',
      icon: PhosphorIconsRegular.calendarBlank,
    ),
    _TabSpec(label: 'Deck', icon: PhosphorIconsRegular.cards),
    _TabSpec(label: 'Progres', icon: PhosphorIconsRegular.chartLine),
    _TabSpec(label: 'Pengaturan', icon: PhosphorIconsRegular.gear),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.glass,
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  height: 72,
                  child: Row(
                    children: [
                      for (var index = 0; index < _tabs.length; index++)
                        _NavTab(
                          spec: _tabs[index],
                          selected: navigationShell.currentIndex == index,
                          onTap: () => navigationShell.goBranch(
                            index,
                            initialLocation:
                                index == navigationShell.currentIndex,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _TabSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: spec.label,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: theme.motionFast,
                curve: Curves.easeOut,
                height: 2,
                width: selected ? 32 : 0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.accent, colors.accent2],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              SizedBox(height: theme.space2 + 2),
              Icon(
                spec.icon,
                size: 24,
                color: selected ? colors.accent : colors.muted,
              ),
              SizedBox(height: theme.space1),
              Text(
                spec.label,
                style: AppTypography.caption.copyWith(
                  color: selected ? colors.accent : colors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
