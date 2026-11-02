import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';

/// Kerangka 4 tab dengan bottom navigation putih yang tenang.
///
/// Tab aktif memakai kapsul oranye lembut dan label navy. Oranye tidak dipakai
/// sebagai teks kecil di atas krem.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<_TabSpec> _tabs = [
    _TabSpec(label: 'Hari Ini', icon: PhosphorIconsRegular.calendarBlank),
    _TabSpec(label: 'Deck', icon: PhosphorIconsRegular.cards),
    _TabSpec(label: 'Progres', icon: PhosphorIconsRegular.chartLine),
    _TabSpec(label: 'Pengaturan', icon: PhosphorIconsRegular.gear),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: SafeArea(
          top: false,
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
                      initialLocation: index == navigationShell.currentIndex,
                    ),
                  ),
              ],
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
                width: 40,
                height: 28,
                decoration: BoxDecoration(
                  color: selected ? colors.accentSoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(theme.radiusPill),
                ),
                child: Icon(
                  spec.icon,
                  size: 20,
                  color: selected ? colors.accentStrong : colors.muted,
                ),
              ),
              SizedBox(height: theme.space1),
              Text(
                spec.label,
                style: AppTypography.label.copyWith(
                  color: selected ? colors.ink : colors.muted,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
