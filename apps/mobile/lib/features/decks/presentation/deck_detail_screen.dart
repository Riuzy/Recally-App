import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../study/data/card_repository.dart';
import '../data/deck_repository.dart';
import 'card_form_sheet.dart';
import 'deck_form_sheet.dart';
import 'paste_cards_sheet.dart';

/// Detail satu deck: daftar kartu plus aksi tambah/ubah/hapus.
class DeckDetailScreen extends ConsumerWidget {
  const DeckDetailScreen({super.key, required this.deckId});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckAsync = ref.watch(deckByIdProvider(deckId));
    final cardsAsync = ref.watch(cardsByDeckProvider(deckId));

    return deckAsync.when(
      loading: () => const AppPage(
        title: 'Deck',
        leading: _BackButton(),
        child: _CardSkeleton(),
      ),
      error: (_, __) => AppPage(
        title: 'Deck',
        leading: const _BackButton(),
        child: Align(
          alignment: Alignment.topCenter,
          child: AppBanner(
            tone: AppBannerTone.danger,
            message: 'Deck gagal dimuat. Coba lagi sebentar.',
            actionLabel: 'Coba lagi',
            onAction: () => ref.invalidate(deckByIdProvider(deckId)),
          ),
        ),
      ),
      data: (deck) {
        if (deck == null) {
          return AppPage(
            title: 'Deck',
            leading: const _BackButton(),
            child: AppEmptyState(
              icon: PhosphorIconsRegular.stack,
              title: 'Deck tidak ditemukan',
              message: 'Deck ini mungkin sudah dihapus.',
              action: AppButton(
                label: 'Kembali ke Deck',
                variant: AppButtonVariant.secondary,
                expand: false,
                onPressed: () => context.go('/decks'),
              ),
            ),
          );
        }

        return AppPage(
          title: deck.name,
          subtitle: _subtitle(cardsAsync),
          leading: const _BackButton(),
          trailing: _DeckMenu(deck: deck),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              AppButton(
                label: 'Tambah kartu',
                icon: PhosphorIconsRegular.plus,
                onPressed: () => showCardFormSheet(context, deckId: deck.id),
              ),
              SizedBox(height: context.appTheme.space3),
              AppButton(
                label: 'Tempel banyak kartu',
                variant: AppButtonVariant.secondary,
                icon: PhosphorIconsRegular.clipboardText,
                onPressed: () => showPasteCardsSheet(context, deckId: deck.id),
              ),
              SizedBox(height: context.appTheme.space6),
              ...switch (cardsAsync) {
                AsyncData(:final value) => _cardSection(context, deck, value),
                AsyncError() => [
                  AppBanner(
                    tone: AppBannerTone.danger,
                    message: 'Kartu gagal dimuat.',
                    actionLabel: 'Coba lagi',
                    onAction: () => ref.invalidate(cardsByDeckProvider(deckId)),
                  ),
                ],
                _ => const [_CardSkeleton()],
              },
            ],
          ),
        );
      },
    );
  }

  String _subtitle(AsyncValue<List<CardRow>> cardsAsync) {
    return cardsAsync.maybeWhen(
      data: (cards) {
        final now = DateTime.now();
        final due = cards.where((card) => !card.dueAt.isAfter(now)).length;
        return due > 0
            ? '${cards.length} kartu · $due jatuh tempo'
            : '${cards.length} kartu';
      },
      orElse: () => 'Memuat kartu…',
    );
  }

  List<Widget> _cardSection(
    BuildContext context,
    Deck deck,
    List<CardRow> cards,
  ) {
    if (cards.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.only(top: 40),
          child: AppEmptyState(
            icon: PhosphorIconsRegular.cards,
            title: 'Belum ada kartu',
            message: 'Tambahkan kartu pertama, atau tempel banyak sekaligus.',
          ),
        ),
      ];
    }

    final now = DateTime.now();
    return [
      AppListGroup(
        children: [
          for (final card in cards)
            AppListRow(
              title: card.front,
              subtitle: card.back,
              trailing: card.dueAt.isAfter(now)
                  ? null
                  : AppChip(
                      label: 'Jatuh tempo',
                      selected: true,
                      icon: PhosphorIconsRegular.clockCountdown,
                    ),
              showChevron: true,
              onTap: () =>
                  showCardFormSheet(context, deckId: deck.id, card: card),
            ),
        ],
      ),
    ];
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return IconButton(
      tooltip: 'Kembali',
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/decks');
        }
      },
      icon: Icon(PhosphorIconsRegular.caretLeft, size: 22, color: colors.ink),
    );
  }
}

class _DeckMenu extends ConsumerWidget {
  const _DeckMenu({required this.deck});

  final Deck deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return PopupMenuButton<String>(
      tooltip: 'Aksi deck',
      icon: Icon(
        PhosphorIconsRegular.dotsThreeVertical,
        size: 22,
        color: colors.inkSoft,
      ),
      color: colors.surface,
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            await showDeckFormSheet(context, deck: deck);
          case 'delete':
            final confirmed = await showAppConfirmSheet(
              context,
              title: 'Hapus deck?',
              message:
                  'Deck "${deck.name}" beserta kartunya akan disembunyikan. '
                  'Riwayat ulangan tetap tersimpan untuk sinkronisasi.',
            );
            if (!confirmed || !context.mounted) return;
            await ref.read(deckRepositoryProvider).softDelete(deck.id);
            if (context.mounted) context.go('/decks');
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Text(
            'Ubah deck',
            style: AppTypography.body.copyWith(color: colors.ink),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'Hapus deck',
            style: AppTypography.body.copyWith(color: colors.danger),
          ),
        ),
      ],
    );
  }
}

/// Skeleton kartu tanpa shimmer (desain §8.2).
class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = theme.colors;

    return Padding(
      padding: EdgeInsets.only(top: theme.space2),
      child: Column(
        children: [
          for (var index = 0; index < 4; index++)
            Container(
              height: 68,
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
                    width: 180,
                    height: 13,
                    decoration: BoxDecoration(
                      color: colors.surface3,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: theme.space2),
                  Container(
                    width: 110,
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
      ),
    );
  }
}
