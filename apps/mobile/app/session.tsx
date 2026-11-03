import { useLocalSearchParams, useRouter } from 'expo-router';
import { useEffect, useReducer, useRef, useState } from 'react';
import {
  ActivityIndicator,
  Keyboard,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  TextInput,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { AppBanner } from '../src/components/AppBanner';
import { AppButton } from '../src/components/AppButton';
import { AppCard } from '../src/components/AppCard';
import { AppChip } from '../src/components/AppChip';
import { AppEmptyState } from '../src/components/AppEmptyState';
import { AppIcon, type IconName } from '../src/components/AppIcon';
import { AppListGroup, AppListRow } from '../src/components/AppList';
import { AppIconButton } from '../src/components/AppPage';
import { AppProgressBar } from '../src/components/AppProgressBar';
import { AppSheet } from '../src/components/AppSheet';
import { AppText } from '../src/components/AppText';
import { AppTextField } from '../src/components/AppTextField';
import { useDb } from '../src/db/provider';
import type { CardRow } from '../src/db/schema';
import { useDbQuery } from '../src/db/useDbQuery';
import { getDeckById } from '../src/features/decks/deckRepository';
import {
  applyReview,
  getCardsByIds,
  getDueCards,
  getNextDueCard,
} from '../src/features/study/cardRepository';
import { getStreak } from '../src/features/study/reviewRepository';
import { RecallRating, ratingLabel } from '../src/features/study/srsEngine';
import { StudySession, type StudyMode } from '../src/features/study/studySession';
import { formatDueLabel } from '../src/format/indonesianDate';
import { colors, radius, space } from '../src/theme/tokens';

export default function StudySessionScreen(): React.JSX.Element {
  const params = useLocalSearchParams<{ cards?: string }>();
  const cardsKey = typeof params.cards === 'string' ? params.cards : '';

  // A different card list means a brand-new session; remount resets all state.
  return <StudySessionView key={cardsKey} cardsKey={cardsKey} />;
}

function StudySessionView({ cardsKey }: { cardsKey: string }): React.JSX.Element {
  const router = useRouter();
  const db = useDb();
  const insets = useSafeAreaInsets();

  const [session, setSession] = useState<StudySession | null>(null);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [saveError, setSaveError] = useState<string | null>(null);
  const [answerText, setAnswerText] = useState('');
  const [modeVisible, setModeVisible] = useState(false);
  const [reloadToken, setReloadToken] = useState(0);
  const [, forceRender] = useReducer((value: number) => value + 1, 0);

  const inputRef = useRef<React.ComponentRef<typeof TextInput>>(null);
  const scrollRef = useRef<React.ComponentRef<typeof ScrollView>>(null);

  useEffect(() => {
    let alive = true;

    const load = cardsKey
      ? getCardsByIds(
          db,
          cardsKey.split(',').filter((value) => value.length > 0),
        )
      : getDueCards(db);

    load
      .then((cards) => {
        if (!alive) return;
        setSession(new StudySession(cards));
        setAnswerText('');
        setLoadError(null);
        setLoading(false);
        requestAnimationFrame(() => scrollRef.current?.scrollTo({ y: 0 }));
      })
      .catch(() => {
        if (!alive) return;
        setLoading(false);
        setLoadError('Sesi gagal dimuat. Periksa lagi sebentar.');
      });

    return () => {
      alive = false;
    };
  }, [db, cardsKey, reloadToken]);

  const retryLoad = () => {
    setSession(null);
    setLoading(true);
    setLoadError(null);
    setSaveError(null);
    setReloadToken((value) => value + 1);
  };

  const close = () => {
    if (router.canGoBack()) router.back();
    else router.replace('/');
  };

  const focusAnswer = () => {
    setTimeout(() => inputRef.current?.focus(), 80);
  };

  const submitAnswer = () => {
    if (!session) return;
    session.submitAnswer(answerText);
    setAnswerText('');
    Keyboard.dismiss();
    forceRender();
  };

  const reveal = () => {
    if (!session) return;
    session.reveal();
    Keyboard.dismiss();
    forceRender();
  };

  const grade = async (rating: RecallRating) => {
    if (!session || saving || session.isFinished) return;

    setSaving(true);
    setSaveError(null);
    try {
      await applyReview(db, { card: session.current.card, rating });
      session.grade(rating);
      setAnswerText('');
      setSaving(false);
      forceRender();

      if (!session.isFinished && session.getStep() === 'jawab') {
        if (session.getMode() === 'tulis') focusAnswer();
      } else if (session.isFinished) {
        scrollRef.current?.scrollTo({ y: 0 });
      }
    } catch {
      setSaving(false);
      setSaveError('Nilai gagal disimpan. Coba pilih sekali lagi.');
    }
  };

  const setMode = (mode: StudyMode) => {
    if (!session) return;
    session.setMode(mode);
    setModeVisible(false);
    forceRender();
    if (mode === 'tulis' && session.getStep() === 'jawab') focusAnswer();
    else if (mode === 'hafalan') Keyboard.dismiss();
  };

  const deckId = session?.current?.card.deckId;
  const deck = useDbQuery(
    (database) =>
      deckId ? getDeckById(database, deckId) : Promise.resolve(null),
    [deckId],
  );

  let body: React.ReactNode;
  if (loading) {
    body = (
      <View style={styles.center}>
        <ActivityIndicator color={colors.accent} />
      </View>
    );
  } else if (loadError) {
    body = (
      <View style={[styles.center, styles.padded]}>
        <AppBanner
          tone="danger"
          message={loadError}
          actionLabel="Coba lagi"
          onAction={retryLoad}
        />
        <View style={styles.gap}>
          <AppButton label="Tutup" variant="secondary" onPress={close} />
        </View>
      </View>
    );
  } else if (!session || session.isEmpty) {
    body = (
      <AppEmptyState
        icon="cards"
        title="Tidak ada kartu untuk diulang"
        message="Semua kartu sudah terjadwal. Kembali lagi nanti."
        action={
          <AppButton
            label="Kembali ke Hari Ini"
            variant="secondary"
            expand={false}
            onPress={close}
          />
        }
      />
    );
  } else if (session.isFinished) {
    body = (
      <StudySummary
        session={session}
        onDone={() => router.replace('/')}
        onRepeatLapsed={(ids) =>
          router.replace({
            pathname: '/session',
            params: { cards: ids.join(',') },
          })
        }
      />
    );
  } else {
    const showingAnswer = session.getStep() === 'nilai';
    const card = session.current.card;

    body = (
      <View style={styles.flex}>
        <View style={styles.topBar}>
          <AppIconButton label="Tutup sesi" onPress={close}>
            <AppIcon name="x" size={22} color={colors.ink} />
          </AppIconButton>
          <AppText variant="label" color={colors.muted} style={styles.topLabel}>
            Kartu {session.position} dari {session.total}
          </AppText>
          <Pressable
            accessibilityRole="button"
            accessibilityLabel="Mode belajar"
            onPress={() => setModeVisible(true)}
            style={styles.modeButton}
          >
            <AppText variant="label" weight="semibold" color={colors.inkSoft}>
              Mode
            </AppText>
          </Pressable>
        </View>
        <View style={styles.progress}>
          <AppProgressBar value={session.progress} />
        </View>

        <ScrollView
          ref={scrollRef}
          showsVerticalScrollIndicator={false}
          contentContainerStyle={styles.scrollContent}
          keyboardShouldPersistTaps="handled"
          keyboardDismissMode="interactive"
        >
          {deck.data ? (
            <View style={styles.deckChip}>
              <AppChip label={deck.data.name} />
            </View>
          ) : null}

          {showingAnswer ? (
            <GradingCard
              session={session}
              card={card}
              saving={saving}
              saveError={saveError}
              onGrade={grade}
            />
          ) : (
            <QuestionCard
              session={session}
              card={card}
              answerText={answerText}
              onChangeAnswer={setAnswerText}
              inputRef={inputRef}
            />
          )}
        </ScrollView>

        {!showingAnswer ? (
          <View style={[styles.actions, { paddingBottom: space.lg + insets.bottom }]}>
            {session.getMode() === 'tulis' ? (
              <>
                <AppButton
                  label="Periksa jawaban"
                  onPress={answerText.trim().length > 0 ? submitAnswer : undefined}
                />
                <AppButton
                  label="Lihat jawaban"
                  variant="text"
                  onPress={reveal}
                />
                <Pressable
                  accessibilityRole="button"
                  onPress={() => setModeVisible(true)}
                  style={styles.modeHint}
                >
                  <AppText variant="caption" color={colors.muted}>
                    Mode: Tulis jawaban
                  </AppText>
                  <AppIcon name="caretRight" size={12} color={colors.muted} />
                </Pressable>
              </>
            ) : (
              <>
                <AppButton label="Lihat jawaban" onPress={reveal} />
                <AppButton
                  label="Tulis jawaban"
                  variant="text"
                  onPress={() => setMode('tulis')}
                />
              </>
            )}
          </View>
        ) : null}
      </View>
    );
  }

  return (
    <KeyboardAvoidingView
      style={styles.root}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <View style={{ flex: 1, paddingTop: insets.top }}>{body}</View>

      <AppSheet visible={modeVisible} onClose={() => setModeVisible(false)}>
        <AppText variant="h3" weight="semibold">
          Mode belajar
        </AppText>
        <View style={styles.modeList}>
          <AppListGroup>
            <AppListRow
              title="Tulis jawaban"
              subtitle="Ketik jawaban sebelum jawaban benar dibuka."
              trailing={
                session?.getMode() === 'tulis' ? (
                  <AppIcon name="check" size={20} color={colors.accentStrong} />
                ) : undefined
              }
              onPress={() => setMode('tulis')}
            />
            <AppListRow
              title="Hafalan"
              subtitle="Balik kartu tanpa mengetik, lalu nilai ingatanmu."
              trailing={
                session?.getMode() === 'hafalan' ? (
                  <AppIcon name="check" size={20} color={colors.accentStrong} />
                ) : undefined
              }
              onPress={() => setMode('hafalan')}
            />
          </AppListGroup>
        </View>
      </AppSheet>
    </KeyboardAvoidingView>
  );
}

function QuestionCard({
  session,
  card,
  answerText,
  onChangeAnswer,
  inputRef,
}: {
  session: StudySession;
  card: CardRow;
  answerText: string;
  onChangeAnswer: (value: string) => void;
  inputRef: React.RefObject<React.ComponentRef<typeof TextInput> | null>;
}): React.JSX.Element {
  return (
    <AppCard>
      <AppText variant="overline" color={colors.muted}>
        PERTANYAAN
      </AppText>
      <AppText variant="h2" style={styles.question}>
        {card.front}
      </AppText>
      <View style={styles.answerField}>
        {session.getMode() === 'tulis' ? (
          <AppTextField
            label="Jawabanmu"
            hint="Tulis jawaban dengan kata-katamu sendiri."
            value={answerText}
            onChangeText={onChangeAnswer}
            inputRef={inputRef}
            multiline
            multilineRows={3}
            autoFocus
            autoCapitalize="sentences"
          />
        ) : (
          <AppText variant="body" color={colors.muted}>
            Pikirkan jawabannya, lalu balik kartu.
          </AppText>
        )}
      </View>
    </AppCard>
  );
}

function GradingCard({
  session,
  card,
  saving,
  saveError,
  onGrade,
}: {
  session: StudySession;
  card: CardRow;
  saving: boolean;
  saveError: string | null;
  onGrade: (rating: RecallRating) => void;
}): React.JSX.Element {
  return (
    <View>
      <AppText variant="overline" color={colors.muted}>
        PERTANYAAN
      </AppText>
      <AppText variant="h3" style={styles.gradingQuestion}>
        {card.front}
      </AppText>

      {session.getMode() === 'tulis' ? (
        <View style={styles.panelGap}>
          <AnswerPanel label="Jawabanmu" text={session.current.answer} />
        </View>
      ) : null}
      <View style={styles.panelGap}>
        <AnswerPanel label="Jawaban benar" text={card.back} correct />
      </View>

      <AppText
        variant="label"
        color={colors.ink}
        style={styles.confidence}
      >
        Seberapa yakin kamu?
      </AppText>
      <GradeButtons enabled={!saving} onGrade={onGrade} />
      {saving ? (
        <AppText variant="caption" color={colors.muted} style={styles.saving}>
          Menyimpan nilai…
        </AppText>
      ) : null}
      {saveError ? (
        <View style={styles.saving}>
          <AppBanner tone="danger" message={saveError} />
        </View>
      ) : null}
      <AppText variant="caption" color={colors.muted} style={styles.scheduleHint}>
        Jadwal berikutnya dihitung otomatis dari pilihanmu.
      </AppText>
    </View>
  );
}

function AnswerPanel({
  label,
  text,
  correct = false,
}: {
  label: string;
  text: string;
  correct?: boolean;
}): React.JSX.Element {
  return (
    <View
      style={[
        styles.panel,
        { backgroundColor: correct ? colors.surface : colors.surface2 },
      ]}
    >
      {correct ? <View style={styles.correctBar} /> : null}
      <View style={styles.panelContent}>
        <AppText variant="caption" color={colors.muted}>
          {label}
        </AppText>
        <AppText variant="body" style={styles.panelText}>
          {text}
        </AppText>
      </View>
    </View>
  );
}

function GradeButtons({
  enabled,
  onGrade,
}: {
  enabled: boolean;
  onGrade: (rating: RecallRating) => void;
}): React.JSX.Element {
  return (
    <View style={styles.gradeRow}>
      <GradeButton
        label={ratingLabel(RecallRating.Lupa)}
        helper="Ulang lagi"
        icon="x"
        foreground={colors.danger}
        background={colors.dangerSoft}
        enabled={enabled}
        onPress={() => onGrade(RecallRating.Lupa)}
      />
      <GradeButton
        label={ratingLabel(RecallRating.Ragu)}
        helper="Ulang segera"
        icon="question"
        foreground={colors.warning}
        background={colors.warningSoft}
        enabled={enabled}
        onPress={() => onGrade(RecallRating.Ragu)}
      />
      <GradeButton
        label={ratingLabel(RecallRating.Ingat)}
        helper="Ulang nanti"
        icon="check"
        foreground={colors.success}
        background={colors.successSoft}
        enabled={enabled}
        onPress={() => onGrade(RecallRating.Ingat)}
      />
    </View>
  );
}

function GradeButton({
  label,
  helper,
  icon,
  foreground,
  background,
  enabled,
  onPress,
}: {
  label: string;
  helper: string;
  icon: IconName;
  foreground: string;
  background: string;
  enabled: boolean;
  onPress: () => void;
}): React.JSX.Element {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={`${label}, ${helper}`}
      accessibilityState={{ disabled: !enabled }}
      disabled={!enabled}
      onPress={onPress}
      style={({ pressed }) => [
        styles.gradeButton,
        {
          backgroundColor: background,
          borderColor: `${foreground}47`,
          opacity: enabled ? (pressed ? 0.8 : 1) : 0.6,
        },
      ]}
    >
      <AppIcon name={icon} size={20} color={foreground} />
      <AppText variant="label" color={foreground} style={styles.gradeLabel}>
        {label}
      </AppText>
      <AppText
        variant="caption"
        color={foreground}
        numberOfLines={1}
        style={styles.gradeHelper}
      >
        {helper}
      </AppText>
    </Pressable>
  );
}

function StudySummary({
  session,
  onDone,
  onRepeatLapsed,
}: {
  session: StudySession;
  onDone: () => void;
  onRepeatLapsed: (ids: string[]) => void;
}): React.JSX.Element {
  const streak = useDbQuery((db) => getStreak(db));
  const nextDue = useDbQuery((db) => getNextDueCard(db));
  const lapsed = session.lapsedCards;

  return (
    <ScrollView
      showsVerticalScrollIndicator={false}
      contentContainerStyle={styles.summary}
    >
      <View style={styles.summaryIcon}>
        <AppIcon name="checkCircle" size={32} color={colors.accent} />
      </View>
      <AppText variant="h1" align="center" style={styles.summaryTitle}>
        Sesi selesai.
      </AppText>
      <AppText
        variant="body"
        color={colors.muted}
        align="center"
        style={styles.summaryMessage}
      >
        Kamu menyelesaikan {session.answeredCount} kartu. Teruskan besok agar
        ingatan tetap kuat.
      </AppText>

      <View style={styles.summaryGap}>
        <AppCard style={styles.countCard}>
          <Count label="Ingat" value={session.countOf(RecallRating.Ingat)} color={colors.success} />
          <Divider />
          <Count label="Ragu" value={session.countOf(RecallRating.Ragu)} color={colors.warning} />
          <Divider />
          <Count label="Lupa" value={session.countOf(RecallRating.Lupa)} color={colors.danger} />
        </AppCard>
      </View>

      {(streak.data ?? 0) > 0 ? (
        <View style={styles.streakPill}>
          <AppIcon name="flame" size={18} color={colors.warning} />
          <View>
            <AppText variant="label">{streak.data} hari beruntun</AppText>
            <AppText variant="caption" color={colors.muted}>
              Konsistensi mengalahkan durasi.
            </AppText>
          </View>
        </View>
      ) : null}

      <View style={styles.summaryGap}>
        <AppCard padding={space.lg}>
          <View style={styles.nextRow}>
            <View style={styles.nextIcon}>
              <AppIcon name="clock" size={18} color={colors.muted} />
            </View>
            <View style={styles.nextText}>
              <AppText variant="caption" color={colors.muted}>
                Jadwal berikutnya
              </AppText>
              <AppText variant="bodyLarge" weight="semibold" style={styles.nextValue}>
                {nextDue.loading
                  ? 'Memuat…'
                  : nextDue.error
                    ? 'Tidak tersedia'
                    : nextDue.data
                      ? formatDueLabel(nextDue.data.dueAt)
                      : 'Belum ada jadwal'}
              </AppText>
            </View>
          </View>
        </AppCard>
      </View>

      <View style={styles.summaryActions}>
        <AppButton label="Kembali ke Hari Ini" onPress={onDone} />
        {lapsed.length > 0 ? (
          <AppButton
            label="Ulangi kartu yang lupa"
            variant="secondary"
            onPress={() => onRepeatLapsed(lapsed.map((card) => card.id))}
            style={styles.repeatButton}
          />
        ) : null}
      </View>
    </ScrollView>
  );
}

function Count({
  label,
  value,
  color,
}: {
  label: string;
  value: number;
  color: string;
}): React.JSX.Element {
  return (
    <View style={styles.countColumn}>
      <AppText variant="h1" color={color} style={styles.countValue}>
        {value}
      </AppText>
      <AppText variant="caption" color={colors.muted}>
        {label}
      </AppText>
    </View>
  );
}

function Divider(): React.JSX.Element {
  return <View style={styles.countDivider} />;
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: colors.canvas,
  },
  flex: {
    flex: 1,
  },
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  padded: {
    padding: space.xl,
  },
  gap: {
    marginTop: space.lg,
  },
  topBar: {
    height: 48,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: space.sm,
  },
  topLabel: {
    flex: 1,
    textAlign: 'center',
  },
  modeButton: {
    minWidth: 56,
    minHeight: 44,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: space.sm,
  },
  progress: {
    paddingHorizontal: space.xl,
    paddingTop: space.sm,
  },
  scrollContent: {
    paddingHorizontal: space.xl,
    paddingTop: space.lg,
    paddingBottom: space.xxl,
  },
  deckChip: {
    alignItems: 'flex-start',
    marginBottom: space.lg,
  },
  question: {
    marginTop: space.md,
  },
  answerField: {
    marginTop: space.xl,
  },
  gradingQuestion: {
    marginTop: space.sm,
  },
  panelGap: {
    marginTop: space.xl,
  },
  panel: {
    flexDirection: 'row',
    borderRadius: radius.card,
    borderWidth: 1,
    borderColor: colors.border,
    overflow: 'hidden',
  },
  correctBar: {
    width: 2,
    backgroundColor: colors.accent,
  },
  panelContent: {
    flex: 1,
    padding: space.lg,
  },
  panelText: {
    marginTop: space.sm,
  },
  confidence: {
    marginTop: space.xxl,
  },
  gradeRow: {
    flexDirection: 'row',
    gap: space.sm,
    marginTop: space.md,
  },
  gradeButton: {
    flex: 1,
    height: 92,
    borderRadius: radius.control,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: space.sm,
    paddingVertical: space.md,
  },
  gradeLabel: {
    marginTop: space.xs,
  },
  gradeHelper: {
    marginTop: 2,
    opacity: 0.78,
  },
  saving: {
    marginTop: space.md,
  },
  scheduleHint: {
    marginTop: space.md,
  },
  actions: {
    paddingHorizontal: space.xl,
    paddingTop: space.md,
    gap: space.xs,
  },
  modeHint: {
    minHeight: 36,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 2,
    paddingHorizontal: space.sm,
  },
  modeList: {
    marginTop: space.lg,
  },
  summary: {
    paddingHorizontal: space.xl,
    paddingTop: space.xxxl,
    paddingBottom: space.xxxl,
  },
  summaryIcon: {
    width: 72,
    height: 72,
    borderRadius: 36,
    backgroundColor: colors.accentSoft,
    alignItems: 'center',
    justifyContent: 'center',
    alignSelf: 'center',
  },
  summaryTitle: {
    marginTop: space.xl,
  },
  summaryMessage: {
    marginTop: space.sm,
  },
  summaryGap: {
    marginTop: space.xxl,
  },
  countCard: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  countColumn: {
    flex: 1,
    alignItems: 'center',
  },
  countValue: {
    lineHeight: 26,
  },
  countDivider: {
    width: 1,
    height: 40,
    backgroundColor: colors.border,
  },
  streakPill: {
    marginTop: space.lg,
    alignSelf: 'center',
    flexDirection: 'row',
    alignItems: 'center',
    gap: space.sm,
    paddingHorizontal: space.lg,
    paddingVertical: space.md,
    backgroundColor: colors.surface2,
    borderRadius: radius.control,
  },
  nextRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  nextIcon: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: colors.surface2,
    alignItems: 'center',
    justifyContent: 'center',
  },
  nextText: {
    flex: 1,
    marginLeft: space.md,
  },
  nextValue: {
    marginTop: space.xs,
  },
  summaryActions: {
    marginTop: space.xxl,
  },
  repeatButton: {
    marginTop: space.sm,
  },
});
