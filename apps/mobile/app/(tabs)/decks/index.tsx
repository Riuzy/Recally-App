import { useRouter } from 'expo-router';
import { useState } from 'react';
import { ScrollView, StyleSheet, View } from 'react-native';

import { AppBanner } from '../../../src/components/AppBanner';
import { AppButton } from '../../../src/components/AppButton';
import { AppChip } from '../../../src/components/AppChip';
import { AppEmptyState } from '../../../src/components/AppEmptyState';
import { AppIcon } from '../../../src/components/AppIcon';
import { AppIconButton, AppPage } from '../../../src/components/AppPage';
import { AppListGroup, AppListRow } from '../../../src/components/AppList';
import { useDbQuery } from '../../../src/db/useDbQuery';
import { DeckFormSheet } from '../../../src/features/decks/DeckFormSheet';
import { getDeckOverview } from '../../../src/features/decks/deckRepository';
import { colors, space } from '../../../src/theme/tokens';

export default function DecksScreen(): React.JSX.Element {
  const router = useRouter();
  const overview = useDbQuery((db) => getDeckOverview(db));
  const [formVisible, setFormVisible] = useState(false);

  const createDeck = () => setFormVisible(true);

  return (
    <AppPage
      title="Deck"
      subtitle="Kumpulan kartu yang kamu pelajari."
      trailing={
        <AppIconButton label="Deck baru" onPress={createDeck}>
          <AppIcon name="plus" size={24} color={colors.accent} />
        </AppIconButton>
      }
    >
      {overview.loading && overview.data === null ? (
        <DeckSkeleton />
      ) : overview.error ? (
        <AppBanner
          tone="danger"
          message="Deck gagal dimuat. Coba lagi sebentar."
          actionLabel="Coba lagi"
          onAction={overview.reload}
        />
      ) : overview.data && overview.data.length === 0 ? (
        <AppEmptyState
          icon="stack"
          title="Belum ada deck"
          message="Mulai dari satu deck, lalu tambahkan kartu yang ingin kamu ingat."
          action={
            <AppButton label="Buat deck pertama" expand={false} onPress={createDeck} />
          }
        />
      ) : (
        <ScrollView
          showsVerticalScrollIndicator={false}
          contentContainerStyle={styles.content}
        >
          <AppListGroup>
            {(overview.data ?? []).map((item) => (
              <AppListRow
                key={item.deck.id}
                title={item.deck.name}
                subtitle={`${item.cardCount} kartu`}
                trailing={
                  item.dueCount > 0 ? (
                    <AppChip
                      label={`${item.dueCount}`}
                      icon="clockCountdown"
                      selected
                      accessibilityLabel={`${item.dueCount} kartu jatuh tempo`}
                    />
                  ) : undefined
                }
                showChevron
                onPress={() =>
                  router.push({
                    pathname: '/decks/[id]',
                    params: { id: item.deck.id },
                  })
                }
              />
            ))}
          </AppListGroup>
        </ScrollView>
      )}

      <DeckFormSheet
        visible={formVisible}
        onClose={() => setFormVisible(false)}
        onSaved={(id) => {
          setFormVisible(false);
          router.push({ pathname: '/decks/[id]', params: { id } });
        }}
      />
    </AppPage>
  );
}

function DeckSkeleton(): React.JSX.Element {
  return (
    <View>
      {[0, 1, 2].map((index) => (
        <View key={index} style={styles.skeleton}>
          <View style={[styles.bar, { width: 148, height: 14 }]} />
          <View style={[styles.bar, { width: 76, height: 10 }]} />
        </View>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  content: {
    paddingBottom: space.xxl,
  },
  skeleton: {
    height: 76,
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
