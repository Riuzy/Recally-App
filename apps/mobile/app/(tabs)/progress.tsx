import { useRouter } from 'expo-router';
import { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, View } from 'react-native';

import { AppBanner } from '../../src/components/AppBanner';
import { AppButton } from '../../src/components/AppButton';
import { AppCard } from '../../src/components/AppCard';
import { AppChip } from '../../src/components/AppChip';
import { AppEmptyState } from '../../src/components/AppEmptyState';
import { AppIcon } from '../../src/components/AppIcon';
import { AppIconBadge } from '../../src/components/AppList';
import { AppPage } from '../../src/components/AppPage';
import { AppProgressBar, AppSegmentedBar } from '../../src/components/AppProgressBar';
import { AppSheet } from '../../src/components/AppSheet';
import { AppText } from '../../src/components/AppText';
import { useDbQuery } from '../../src/db/useDbQuery';
import { ActivityChart } from '../../src/features/progress/ActivityChart';
import { getCardProgress, getReviewActivity } from '../../src/features/progress/progressRepository';
import type {
  CardProgress,
  DeckProgress,
  ProgressPeriod,
  ReviewActivity,
} from '../../src/features/progress/progressStats';
import { PROGRESS_PERIODS } from '../../src/features/progress/progressStats';
import { formatDayLabel } from '../../src/format/indonesianDate';
import { colors, space } from '../../src/theme/tokens';

export default function ProgressScreen(): React.JSX.Element {
  const router = useRouter();
  const [period, setPeriod] = useState<ProgressPeriod>('week');
  const [periodVisible, setPeriodVisible] = useState(false);

  const cardProgress = useDbQuery((db) => getCardProgress(db));
  const activity = useDbQuery((db) => getReviewActivity(db, period), [period]);

  const retry = () => {
    cardProgress.reload();
    activity.reload();
  };

  let child: React.ReactNode;
  if (cardProgress.error || activity.error) {
    child = (
      <View style={styles.center}>
        <AppBanner
          tone="danger"
          message="Statistik gagal dimuat."
          actionLabel="Coba lagi"
          onAction={retry}
        />
      </View>
    );
  } else if (!cardProgress.data || !activity.data) {
    child = <ProgressSkeleton />;
  } else if (!activity.data.hasAnyReview) {
    child = (
      <AppEmptyState
        icon="chartLine"
        title="Mulai sesi pertamamu"
        message="Progres, retensi, dan riwayat muncul setelah kamu menyelesaikan satu sesi belajar."
        action={
          <AppButton
            label="Mulai sesi"
            expand={false}
            onPress={() => router.push('/session')}
          />
        }
      />
    );
  } else {
    child = (
      <ProgressContent
        cardStats={cardProgress.data}
        activity={activity.data}
        onOpenDeck={(deckId) =>
          router.push({ pathname: '/decks/[id]', params: { id: deckId } })
        }
      />
    );
  }

  return (
    <AppPage
      title="Progres"
      trailing={
        <AppChip
          label={PROGRESS_PERIODS[period].label}
          trailingIcon="caretDown"
          onPress={() => setPeriodVisible(true)}
        />
      }
    >
      {child}

      <AppSheet visible={periodVisible} onClose={() => setPeriodVisible(false)}>
        <AppText variant="h3" weight="semibold">
          Rentang waktu
        </AppText>
        <View style={styles.periodList}>
          {(['week', 'month'] as const).map((value) => (
            <Pressable
              key={value}
              accessibilityRole="button"
              accessibilityState={{ selected: value === period }}
              onPress={() => {
                setPeriod(value);
                setPeriodVisible(false);
              }}
              style={({ pressed }) => [
                styles.periodRow,
                {
                  backgroundColor: pressed ? colors.surface2 : colors.surface,
                  borderColor:
                    value === period ? colors.accent : colors.border,
                },
              ]}
            >
              <View style={styles.periodText}>
                <AppText variant="bodyLarge" weight="semibold">
                  {PROGRESS_PERIODS[value].label}
                </AppText>
                <AppText variant="caption" color={colors.muted} style={styles.periodSub}>
                  {value === 'week'
                    ? 'Retensi dan aktivitas 7 hari terakhir.'
                    : 'Retensi dan aktivitas 30 hari terakhir.'}
                </AppText>
              </View>
              {value === period ? (
                <AppIcon name="check" size={20} color={colors.accentStrong} />
              ) : null}
            </Pressable>
          ))}
        </View>
      </AppSheet>
    </AppPage>
  );
}

function ProgressContent({
  cardStats,
  activity,
  onOpenDeck,
}: {
  cardStats: CardProgress;
  activity: ReviewActivity;
  onOpenDeck: (deckId: string) => void;
}): React.JSX.Element {
  const decks = cardStats.decks.slice(0, 4);

  return (
    <ScrollView
      showsVerticalScrollIndicator={false}
      contentContainerStyle={styles.content}
    >
      <RetentionCard activity={activity} />
      <View style={styles.gap}>
        <MetricRow cardStats={cardStats} activity={activity} />
      </View>
      <View style={styles.gap}>
        <ActivitySection activity={activity} />
      </View>
      <View style={styles.gap}>
        <MasterySection cardStats={cardStats} />
      </View>

      {decks.length > 0 ? (
        <View style={styles.gapLarge}>
          <AppText variant="h3" weight="semibold">
            Per deck
          </AppText>
          <View style={styles.gapSmall}>
            <DeckList decks={decks} onOpenDeck={onOpenDeck} />
          </View>
        </View>
      ) : null}

      {activity.recentDays.length > 0 ? (
        <View style={styles.gapLarge}>
          <AppText variant="h3" weight="semibold">
            Riwayat belajar
          </AppText>
          <View style={styles.gapSmall}>
            <HistoryList activity={activity} />
          </View>
        </View>
      ) : null}
    </ScrollView>
  );
}

function RetentionCard({ activity }: { activity: ReviewActivity }): React.JSX.Element {
  const retention = activity.retention;
  const delta = activity.retentionDelta;

  const value = retention === null ? '—' : `${Math.round(retention * 100)}%`;
  const helper =
    retention === null
      ? 'Belum ada ulasan pada periode ini.'
      : delta === null
        ? 'Belum ada data pembanding.'
        : `Dibanding ${PROGRESS_PERIODS[activity.period].comparisonLabel} ${signedPoints(delta)} poin.`;

  return (
    <AppCard>
      <View style={styles.retentionRow}>
        <AppText variant="display" style={styles.retentionValue}>
          {value}
        </AppText>
        <AppText variant="body" color={colors.muted} style={styles.retentionLabel}>
          retensi
        </AppText>
      </View>
      <View style={styles.retentionBar}>
        <AppProgressBar value={retention ?? 0} />
      </View>
      <AppText variant="caption" color={colors.muted} style={styles.retentionHelper}>
        {helper}
      </AppText>
    </AppCard>
  );
}

function MetricRow({
  cardStats,
  activity,
}: {
  cardStats: CardProgress;
  activity: ReviewActivity;
}): React.JSX.Element {
  return (
    <View style={styles.metricCard}>
      <Metric value={`${activity.streak} hari`} label="streak" />
      <View style={styles.metricDivider} />
      <Metric value={`${cardStats.total}`} label="kartu" />
      <View style={styles.metricDivider} />
      <Metric value={`${Math.round(cardStats.mastery * 100)}%`} label="dikuasai" />
    </View>
  );
}

function Metric({ value, label }: { value: string; label: string }): React.JSX.Element {
  return (
    <View style={styles.metric}>
      <AppText variant="h3" weight="semibold">
        {value}
      </AppText>
      <AppText variant="caption" color={colors.muted} style={styles.metricLabel}>
        {label}
      </AppText>
    </View>
  );
}

function ActivitySection({ activity }: { activity: ReviewActivity }): React.JSX.Element {
  return (
    <AppCard>
      <View style={styles.sectionHeader}>
        <AppText variant="label" color={colors.ink}>
          Aktivitas
        </AppText>
        <AppText variant="caption" color={colors.muted}>
          {activity.total} ulasan
        </AppText>
      </View>
      <View style={styles.chart}>
        <ActivityChart days={activity.days} />
      </View>
      {activity.total === 0 ? (
        <AppText variant="caption" color={colors.muted} style={styles.chartEmpty}>
          Belum ada ulasan pada periode ini.
        </AppText>
      ) : null}
    </AppCard>
  );
}

function MasterySection({ cardStats }: { cardStats: CardProgress }): React.JSX.Element {
  return (
    <AppCard>
      <View style={styles.sectionHeader}>
        <AppText variant="label" color={colors.ink}>
          Kartu dikuasai
        </AppText>
        <AppText variant="label" color={colors.ink}>
          {Math.round(cardStats.mastery * 100)}%
        </AppText>
      </View>
      <View style={styles.masteryBar}>
        <AppSegmentedBar
          segments={[
            { value: cardStats.mastered, color: colors.success },
            { value: cardStats.learning, color: colors.warning },
            { value: cardStats.fresh, color: colors.border },
          ]}
        />
      </View>
      <View style={styles.legendWrap}>
        <Legend color={colors.success} label={`${cardStats.mastered} dikuasai`} />
        <Legend color={colors.warning} label={`${cardStats.learning} sedang dipelajari`} />
        <Legend color={colors.border} label={`${cardStats.fresh} baru`} />
      </View>
    </AppCard>
  );
}

function Legend({ color, label }: { color: string; label: string }): React.JSX.Element {
  return (
    <View style={styles.legend}>
      <View style={[styles.legendDot, { backgroundColor: color }]} />
      <AppText variant="caption" color={colors.muted}>
        {label}
      </AppText>
    </View>
  );
}

function DeckList({
  decks,
  onOpenDeck,
}: {
  decks: DeckProgress[];
  onOpenDeck: (deckId: string) => void;
}): React.JSX.Element {
  return (
    <AppCard padding={0}>
      {decks.map((deck, index) => (
        <View key={deck.deckId}>
          {index > 0 ? <View style={styles.divider} /> : null}
          <Pressable
            accessibilityRole="button"
            onPress={() => onOpenDeck(deck.deckId)}
            style={({ pressed }) => ({
              padding: space.lg,
              backgroundColor: pressed ? colors.surface2 : 'transparent',
            })}
          >
            <View style={styles.deckRow}>
              <AppIconBadge name="cards" />
              <View style={styles.deckText}>
                <AppText variant="bodyLarge" weight="semibold" numberOfLines={1}>
                  {deck.name}
                </AppText>
                <AppText variant="caption" color={colors.muted} style={styles.deckMeta}>
                  {deck.mastered} dari {deck.total} kartu dikuasai
                </AppText>
              </View>
              <AppText variant="label" color={colors.ink}>
                {Math.round(deck.mastery * 100)}%
              </AppText>
              <AppIcon name="caretRight" size={16} color={colors.muted} />
            </View>
            <View style={styles.deckBar}>
              <AppProgressBar value={deck.mastery} />
            </View>
          </Pressable>
        </View>
      ))}
    </AppCard>
  );
}

function HistoryList({ activity }: { activity: ReviewActivity }): React.JSX.Element {
  return (
    <AppCard padding={0}>
      {activity.recentDays.map((day, index) => (
        <View key={day.day.getTime()}>
          {index > 0 ? <View style={styles.divider} /> : null}
          <View style={styles.historyRow}>
            <View style={styles.historyText}>
              <AppText variant="bodyLarge" weight="semibold">
                {formatDayLabel(day.day)}
              </AppText>
              <AppText variant="caption" color={colors.muted} style={styles.historyMeta}>
                {day.reviews} ulasan
              </AppText>
            </View>
            <AppText variant="caption" weight="semibold" color={colors.success}>
              {day.ingat} Ingat
            </AppText>
          </View>
        </View>
      ))}
    </AppCard>
  );
}

function ProgressSkeleton(): React.JSX.Element {
  return (
    <View>
      <View style={[styles.skeleton, { height: 150 }]} />
      <View style={[styles.skeleton, { height: 76, marginTop: space.lg }]} />
      <View style={[styles.skeleton, { height: 260, marginTop: space.lg }]} />
      <View style={[styles.skeleton, { height: 112, marginTop: space.lg }]} />
    </View>
  );
}

function signedPoints(delta: number): string {
  const points = Math.round(delta * 100);
  return points >= 0 ? `+${points}` : `${points}`;
}

const styles = StyleSheet.create({
  content: {
    paddingBottom: space.xxl,
  },
  center: {
    flex: 1,
    justifyContent: 'center',
  },
  gap: {
    marginTop: space.lg,
  },
  gapLarge: {
    marginTop: space.xl,
  },
  gapSmall: {
    marginTop: space.md,
  },
  retentionRow: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    gap: space.sm,
  },
  retentionValue: {
    lineHeight: 38,
  },
  retentionLabel: {
    marginBottom: 5,
  },
  retentionBar: {
    marginTop: space.lg,
  },
  retentionHelper: {
    marginTop: space.md,
  },
  metricCard: {
    paddingVertical: space.lg,
    backgroundColor: colors.surface,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: colors.border,
    flexDirection: 'row',
    alignItems: 'center',
  },
  metric: {
    flex: 1,
    alignItems: 'center',
  },
  metricLabel: {
    marginTop: space.xs,
  },
  metricDivider: {
    width: 1,
    height: 32,
    backgroundColor: colors.border,
  },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  chart: {
    marginTop: space.lg,
  },
  chartEmpty: {
    marginTop: space.sm,
  },
  masteryBar: {
    marginTop: space.md,
  },
  legendWrap: {
    marginTop: space.md,
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: space.lg,
  },
  legend: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: space.sm,
  },
  legendDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
  },
  divider: {
    height: 1,
    backgroundColor: colors.border,
  },
  deckRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: space.md,
  },
  deckText: {
    flex: 1,
  },
  deckMeta: {
    marginTop: space.xs,
  },
  deckBar: {
    marginTop: space.md,
  },
  historyRow: {
    padding: space.lg,
    flexDirection: 'row',
    alignItems: 'center',
  },
  historyText: {
    flex: 1,
  },
  historyMeta: {
    marginTop: space.xs,
  },
  skeleton: {
    backgroundColor: colors.surface2,
    borderRadius: 12,
  },
  periodList: {
    marginTop: space.lg,
    gap: space.sm,
  },
  periodRow: {
    minHeight: 64,
    paddingHorizontal: space.lg,
    paddingVertical: space.md,
    borderRadius: 12,
    borderWidth: 1,
    flexDirection: 'row',
    alignItems: 'center',
    gap: space.md,
  },
  periodText: {
    flex: 1,
  },
  periodSub: {
    marginTop: space.xs,
  },
});
