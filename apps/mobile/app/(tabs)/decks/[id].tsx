import { useLocalSearchParams, useRouter } from 'expo-router';
import { useState } from 'react';
import { ScrollView, StyleSheet, View } from 'react-native';

import { AppBanner } from '../../../src/components/AppBanner';
import { AppButton } from '../../../src/components/AppButton';
import { AppChip } from '../../../src/components/AppChip';
import { AppConfirmSheet, AppSheet } from '../../../src/components/AppSheet';
import { AppEmptyState } from '../../../src/components/AppEmptyState';
import { AppIcon } from '../../../src/components/AppIcon';
import { AppListGroup, AppListRow } from '../../../src/components/AppList';
import { AppIconButton, AppPage } from '../../../src/components/AppPage';
import { AppText } from '../../../src/components/AppText';
import { useDb } from '../../../src/db/provider';
import type { CardRow, Deck } from '../../../src/db/schema';
import { useDbQuery } from '../../../src/db/useDbQuery';
import { CardFormSheet } from '../../../src/features/decks/CardFormSheet';
import { DeckFormSheet } from '../../../src/features/decks/DeckFormSheet';
import { PasteCardsSheet } from '../../../src/features/decks/PasteCardsSheet';
import {
  getDeckById,
  softDeleteDeck,
} from '../../../src/features/decks/deckRepository';
import { getCardsByDeck } from '../../../src/features/study/cardRepository';
import { colors, space } from '../../../src/theme/tokens';

export default function DeckDetailScreen(): React.JSX.Element {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();
  const deckId = id ?? '';
  const db = useDb();

  const deck = useDbQuery((database) => getDeckById(database, deckId), [deckId]);
  const cards = useDbQuery(async (database) => {
    const rows = await getCardsByDeck(database, deckId);
    const now = Date.now();
    return rows.map((card) => ({
      ...card,
      isDue: card.dueAt.getTime() <= now,
    }));
  }, [deckId]);

  const [formVisible, setFormVisible] = useState(false);
  const [cardVisible, setCardVisible] = useState(false);
  const [editingCard, setEditingCard] = useState<CardRow | null>(null);
  const [pasteVisible, setPasteVisible] = useState(false);
  const [menuVisible, setMenuVisible] = useState(false);
  const [deleteVisible, setDeleteVisible] = useState(false);

  const goBack = () => {
    if (router.canGoBack()) router.back();
    else router.replace('/decks');
  };

  const deleteDeck = async () => {
    setDeleteVisible(false);
    if (!deck.data) return;
    await softDeleteDeck(db, deck.data.id);
    router.replace('/decks');
  };

  if (deck.loading && deck.data === null) {
    return (
      <AppPage title="Deck" leading={<BackButton onPress={goBack} />}>
        <CardSkeleton />
      </AppPage>
    );
  }

  if (deck.error) {
    return (
      <AppPage title="Deck" leading={<BackButton onPress={goBack} />}>
        <AppBanner
          tone="danger"
          message="Deck gagal dimuat. Coba lagi sebentar."
          actionLabel="Coba lagi"
          onAction={deck.reload}
        />
      </AppPage>
    );
  }

  if (!deck.data) {
    return (
      <AppPage title="Deck" leading={<BackButton onPress={goBack} />}>
        <AppEmptyState
          icon="stack"
          title="Deck tidak ditemukan"
          message="Deck ini mungkin sudah dihapus."
          action={
            <AppButton
              label="Kembali ke Deck"
              variant="secondary"
              expand={false}
              onPress={() => router.replace('/decks')}
            />
          }
        />
      </AppPage>
    );
  }

  const value: Deck = deck.data;
  const cardList = cards.data ?? [];

  return (
    <AppPage
      title={value.name}
      subtitle={subtitle(cardList)}
      leading={<BackButton onPress={goBack} />}
      trailing={
        <AppIconButton label="Aksi deck" onPress={() => setMenuVisible(true)}>
          <AppIcon name="dotsThreeVertical" size={22} color={colors.inkSoft} />
        </AppIconButton>
      }
    >
      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.content}
        keyboardShouldPersistTaps="handled"
      >
        <AppButton
          label="Tambah kartu"
          icon="plus"
          onPress={() => {
            setEditingCard(null);
            setCardVisible(true);
          }}
        />
        <View style={styles.gap}>
          <AppButton
            label="Tempel banyak kartu"
            variant="secondary"
            icon="clipboardText"
            onPress={() => setPasteVisible(true)}
          />
        </View>

        <View style={styles.section}>
          {cards.error ? (
            <AppBanner
              tone="danger"
              message="Kartu gagal dimuat."
              actionLabel="Coba lagi"
              onAction={cards.reload}
            />
          ) : cards.loading && cards.data === null ? (
            <CardSkeleton />
          ) : cardList.length === 0 ? (
            <AppEmptyState
              icon="cards"
              title="Belum ada kartu"
              message="Tambahkan kartu pertama, atau tempel banyak sekaligus."
            />
          ) : (
            <AppListGroup>
              {cardList.map((card) => (
                <AppListRow
                  key={card.id}
                  title={card.front}
                  subtitle={card.back}
                  trailing={
                    card.isDue ? (
                      <AppChip
                        label="Jatuh tempo"
                        selected
                        icon="clockCountdown"
                      />
                    ) : undefined
                  }
                  showChevron
                  onPress={() => {
                    setEditingCard(card);
                    setCardVisible(true);
                  }}
                />
              ))}
            </AppListGroup>
          )}
        </View>
      </ScrollView>

      <DeckFormSheet
        visible={formVisible}
        deck={value}
        onClose={() => setFormVisible(false)}
      />

      <CardFormSheet
        visible={cardVisible}
        deckId={value.id}
        card={editingCard}
        onClose={() => setCardVisible(false)}
      />

      <PasteCardsSheet
        visible={pasteVisible}
        deckId={value.id}
        onClose={() => setPasteVisible(false)}
      />

      <AppSheet visible={menuVisible} onClose={() => setMenuVisible(false)}>
        <AppText variant="h3" weight="semibold">
          Aksi deck
        </AppText>
        <View style={styles.menuList}>
          <AppListGroup>
            <AppListRow
              title="Ubah deck"
              onPress={() => {
                setMenuVisible(false);
                setFormVisible(true);
              }}
            />
            <AppListRow
              title="Hapus deck"
              destructive
              onPress={() => {
                setMenuVisible(false);
                setDeleteVisible(true);
              }}
            />
          </AppListGroup>
        </View>
      </AppSheet>

      <AppConfirmSheet
        visible={deleteVisible}
        title="Hapus deck?"
        message={`Deck "${value.name}" beserta kartunya akan disembunyikan. Riwayat ulangan tetap tersimpan untuk sinkronisasi.`}
        onCancel={() => setDeleteVisible(false)}
        onConfirm={deleteDeck}
      />
    </AppPage>
  );
}

function subtitle(cards: (CardRow & { isDue: boolean })[]): string {
  const due = cards.filter((card) => card.isDue).length;
  return due > 0 ? `${cards.length} kartu · ${due} jatuh tempo` : `${cards.length} kartu`;
}

function BackButton({ onPress }: { onPress: () => void }): React.JSX.Element {
  return (
    <AppIconButton label="Kembali" onPress={onPress}>
      <AppIcon name="caretLeft" size={22} color={colors.ink} />
    </AppIconButton>
  );
}

function CardSkeleton(): React.JSX.Element {
  return (
    <View>
      {[0, 1, 2, 3].map((index) => (
        <View key={index} style={styles.skeleton}>
          <View style={[styles.bar, { width: 180, height: 13 }]} />
          <View style={[styles.bar, { width: 110, height: 10 }]} />
        </View>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  content: {
    paddingBottom: space.xxl,
  },
  gap: {
    marginTop: space.md,
  },
  section: {
    marginTop: space.xxl,
  },
  menuList: {
    marginTop: space.lg,
  },
  skeleton: {
    height: 68,
    marginBottom: space.md,
    padding: space.lg,
    backgroundColor: colors.surface2,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: colors.border,
    justifyContent: 'center',
    gap: space.sm,
  },
  bar: {
    backgroundColor: colors.surface3,
    borderRadius: 4,
  },
});
