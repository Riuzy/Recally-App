import { useRouter } from 'expo-router';
import { ScrollView, StyleSheet, View } from 'react-native';

import { AppBanner } from '../../src/components/AppBanner';
import { AppButton } from '../../src/components/AppButton';
import { AppCard } from '../../src/components/AppCard';
import { AppChip } from '../../src/components/AppChip';
import { AppPage } from '../../src/components/AppPage';
import { AppText } from '../../src/components/AppText';
import { useDbQuery } from '../../src/db/useDbQuery';
import { getDueCards } from '../../src/features/study/cardRepository';
import { getReviewedToday, getStreak } from '../../src/features/study/reviewRepository';
import { formatLongDate } from '../../src/format/indonesianDate';
import { colors, space } from '../../src/theme/tokens';

export default function TodayScreen(): React.JSX.Element {
  const router = useRouter();
  const due = useDbQuery((db) => getDueCards(db));
  const streak = useDbQuery((db) => getStreak(db));
  const reviewed = useDbQuery((db) => getReviewedToday(db));

  const now = new Date();
  const streakCount = streak.data ?? 0;

  return (
    <AppPage
      eyebrow={formatLongDate(now).toUpperCase()}
      title={greeting(now.getHours())}
      subtitle="Belajar sedikit, ingat lebih lama."
      trailing={
        streakCount > 0 ? (
          <AppChip label={`${streakCount}`} icon="flame" />
        ) : undefined
      }
    >
      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.content}
      >
        <AppCard>
          <AppText variant="overline" color={colors.muted}>
            SESI HARI INI
          </AppText>
          <View style={styles.hero}>
            {due.loading && due.data === null ? (
              <HeroSkeleton />
            ) : due.error ? (
              <AppBanner
                tone="danger"
                message="Kartu jatuh tempo gagal dimuat."
                actionLabel="Coba lagi"
                onAction={due.reload}
              />
            ) : (
              <HeroBody
                count={due.data?.length ?? 0}
                reviewed={reviewed.data ?? 0}
                onStart={() => router.push('/session')}
                onOpenDecks={() => router.push('/decks')}
              />
            )}
          </View>
        </AppCard>
      </ScrollView>
    </AppPage>
  );
}

function HeroBody({
  count,
  reviewed,
  onStart,
  onOpenDecks,
}: {
  count: number;
  reviewed: number;
  onStart: () => void;
  onOpenDecks: () => void;
}): React.JSX.Element {
  const hasCards = count > 0;

  return (
    <View>
      <View style={styles.countRow}>
        <AppText variant="display" style={styles.count}>
          {count}
        </AppText>
        <AppText variant="body" color={colors.inkSoft} style={styles.countLabel}>
          kartu siap diulang
        </AppText>
      </View>
      {reviewed > 0 ? (
        <AppText variant="caption" color={colors.muted} style={styles.reviewed}>
          Sudah {reviewed} hari ini
        </AppText>
      ) : null}
      <View style={styles.primaryAction}>
        <AppButton
          label={hasCards ? 'Mulai sesi' : 'Tidak ada kartu'}
          icon={hasCards ? 'play' : undefined}
          onPress={hasCards ? onStart : undefined}
        />
      </View>
      {hasCards ? (
        <AppText variant="caption" color={colors.muted} style={styles.caption}>
          Perkiraan {estimateMinutes(count)} menit
        </AppText>
      ) : (
        <View>
          <AppButton
            label="Buka Deck"
            variant="secondary"
            onPress={onOpenDecks}
            style={styles.openDecks}
          />
          <AppText variant="caption" color={colors.muted} style={styles.caption}>
            Belum ada kartu jatuh tempo. Tambahkan kartu di deck.
          </AppText>
        </View>
      )}
    </View>
  );
}

function HeroSkeleton(): React.JSX.Element {
  return (
    <View>
      <View style={styles.countRow}>
        <View style={[styles.skeleton, { width: 56, height: 36 }]} />
        <View style={[styles.skeleton, { width: 124, height: 12, marginBottom: 6 }]} />
      </View>
      <View style={[styles.skeleton, styles.skeletonButton]} />
      <View style={[styles.skeleton, { width: 96, height: 10, marginTop: space.sm }]} />
    </View>
  );
}

function greeting(hour: number): string {
  if (hour < 11) return 'Selamat pagi';
  if (hour < 15) return 'Selamat siang';
  if (hour < 18) return 'Selamat sore';
  return 'Selamat malam';
}

function estimateMinutes(cardCount: number): number {
  const minutes = Math.ceil((cardCount * 20) / 60);
  return minutes < 1 ? 1 : minutes;
}

const styles = StyleSheet.create({
  content: {
    paddingBottom: space.xxl,
  },
  hero: {
    marginTop: space.md,
  },
  countRow: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    gap: space.sm,
  },
  count: {
    lineHeight: 38,
  },
  countLabel: {
    marginBottom: space.xs,
  },
  reviewed: {
    marginTop: space.sm,
  },
  primaryAction: {
    marginTop: space.xl,
  },
  caption: {
    marginTop: space.sm,
  },
  openDecks: {
    marginTop: space.md,
  },
  skeleton: {
    backgroundColor: colors.surface3,
    borderRadius: 4,
  },
  skeletonButton: {
    height: 52,
    borderRadius: 26,
    marginTop: space.xl,
  },
});
