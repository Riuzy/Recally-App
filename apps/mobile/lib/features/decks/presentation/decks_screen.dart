import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/widgets.dart';
import '../data/deck_repository.dart';
import 'deck_form_sheet.dart';

/// Tab "Deck": daftar deck dengan jumlah kartu dan kartu jatuh tempo.
class DecksScreen extends ConsumerWidget {
  const DecksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(deckOverviewProvider);

    return AppPage(
      title: 'Deck',
      subtitle: 'Kumpulan kartu yang kamu pelajari.',
      trailing: _AddDeckButton(onPressed: () => _createDeck(context, ref)),
      child: overview.when(
        loading: () => const _DeckSkeleton(),
        error: (_, __) => Align(
          alignment: Alignment.topCenter,
          child: AppBanner(
            tone: AppBannerTone.danger,
            message: 'Deck gagal dimuat. Coba lagi sebentar.',
            actionLabel: 'Coba lagi',
            onAction: () => ref.invalidate(deckOverviewProvider),
          ),
        ),
        data: (decks) => decks.isEmpty
            ? AppEmptyState(
                icon: PhosphorIconsRegular.stack,
                title: 'Belum ada deck',
                message:
                    'Mulai dari satu deck, lalu tambahkan kartu yang ingin '
                    'kamu ingat.',
                action: AppButton(
                  label: 'Buat deck pertama',
                  expand: false,
                  onPressed: () => _createDeck(context, ref),
                ),
              )
            : _DeckList(decks: decks),
      ),
    );
  }

  Future<void> _createDeck(BuildContext context, WidgetRef ref) async {
    final id = await showDeckFormSheet(context);
    if (id == null || !context.mounted) return;
    context.push('/decks/$id');
  }
}

class _DeckList extends StatelessWidget {
  const _DeckList({required this.decks});

  final List<DeckOverview> decks;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        AppListGroup(
          children: [
            for (final item in decks)
              AppListRow(
                title: item.deck.name,
                subtitle: '${item.cardCount} kartu',
                trailing: item.dueCount > 0
                    ? Semantics(
                        label: '${item.dueCount} kartu jatuh tempo',
                        child: AppChip(
                          label: '${item.dueCount}',
                          icon: PhosphorIconsRegular.clockCountdown,
                          selected: true,
                        ),
                      )
                    : null,
                showChevron: true,
                onTap: () => context.push('/decks/${item.deck.id}'),
              ),
          ],
        ),
      ],
    );
  }
}

class _AddDeckButton extends StatelessWidget {
  const _AddDeckButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return IconButton(
      tooltip: 'Deck baru',
      onPressed: onPressed,
      icon: Icon(PhosphorIconsRegular.plus, size: 24, color: colors.accent),
    );
  }
}

/// Skeleton tanpa shimmer (desain §8.2).
class _DeckSkeleton extends StatelessWidget {
  const _DeckSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (var index = 0; index < 3; index++)
          Container(
            height: 76,
            margin: EdgeInsets.only(bottom: theme.space3),
            padding: EdgeInsets.all(theme.space4),
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: BorderRadius.circular(theme.radiusCard),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 148,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colors.surface3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: theme.space2),
                Container(
                  width: 76,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors.surface3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
