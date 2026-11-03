import { useState } from 'react';
import { ActivityIndicator, ScrollView, StyleSheet, View } from 'react-native';

import { AppBanner, type AppBannerTone } from '../../src/components/AppBanner';
import { AppCard } from '../../src/components/AppCard';
import { AppIcon } from '../../src/components/AppIcon';
import { AppIconBadge, AppListGroup, AppListRow } from '../../src/components/AppList';
import { AppPage } from '../../src/components/AppPage';
import { AppConfirmSheet } from '../../src/components/AppSheet';
import { AppText } from '../../src/components/AppText';
import { useDb } from '../../src/db/provider';
import { demoSeedEnabled, seedDemoData } from '../../src/features/dev/demoSeed';
import { colors, radius, space } from '../../src/theme/tokens';

export default function SettingsScreen(): React.JSX.Element {
  const db = useDb();
  const [seeding, setSeeding] = useState(false);
  const [confirmVisible, setConfirmVisible] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [tone, setTone] = useState<AppBannerTone>('success');

  const seed = async () => {
    setConfirmVisible(false);
    setSeeding(true);
    setMessage(null);

    try {
      const created = await seedDemoData(db);
      setSeeding(false);
      setTone(created ? 'success' : 'info');
      setMessage(
        created
          ? 'Data contoh siap. Buka tab Deck, Hari Ini, atau Progres.'
          : 'Data contoh sudah ada, tidak ada yang ditambahkan.',
      );
    } catch (cause) {
      setSeeding(false);
      setTone('danger');
      setMessage('Gagal membuat data contoh. Coba lagi.');
      if (__DEV__) {
        console.warn('Demo seed failed', cause);
      }
    }
  };

  return (
    <AppPage title="Pengaturan">
      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.content}
      >
        <AppText variant="overline" color={colors.muted}>
          AKUN
        </AppText>
        <View style={styles.sectionGap}>
          <AppCard>
            <View style={styles.accountRow}>
              <View style={styles.accountIcon}>
                <AppIcon name="cloudArrowUp" size={22} color={colors.accent} />
              </View>
              <View style={styles.accountText}>
                <AppText variant="body" weight="semibold">
                  Sinkronisasi
                </AppText>
                <AppText variant="caption" color={colors.muted} style={styles.accountMeta}>
                  Login opsional. Aplikasi tetap berjalan penuh tanpa akun dan
                  tanpa koneksi.
                </AppText>
              </View>
            </View>
          </AppCard>
        </View>

        {demoSeedEnabled ? (
          <>
            <AppText variant="overline" color={colors.muted} style={styles.section}>
              PENGEMBANG
            </AppText>
            <View style={styles.sectionGap}>
              <AppListGroup>
                <AppListRow
                  title="Isi data contoh"
                  subtitle={'Deck "Biologi Sel" dengan 12 kartu dan riwayat 7 hari untuk mencoba sesi dan Progres.'}
                  leading={<AppIconBadge name="cards" />}
                  trailing={
                    seeding ? (
                      <ActivityIndicator size="small" color={colors.accent} />
                    ) : undefined
                  }
                  showChevron={!seeding}
                  onPress={seeding ? undefined : () => setConfirmVisible(true)}
                />
              </AppListGroup>
            </View>
            {message ? (
              <View style={styles.bannerGap}>
                <AppBanner message={message} tone={tone} />
              </View>
            ) : null}
          </>
        ) : null}

        <AppText variant="overline" color={colors.muted} style={styles.section}>
          TENTANG
        </AppText>
        <View style={styles.sectionGap}>
          <AppCard>
            <AppText variant="body" weight="semibold">
              Recally
            </AppText>
            <AppText variant="caption" color={colors.muted} style={styles.aboutMeta}>
              Versi 1.0.0 · Local-first spaced repetition
            </AppText>
          </AppCard>
        </View>
      </ScrollView>

      <AppConfirmSheet
        visible={confirmVisible}
        title="Isi data contoh?"
        message={'Deck "Biologi Sel" berisi 12 kartu dan riwayat 7 hari akan ditambahkan. Data ini hanya untuk mencoba aplikasi.'}
        confirmLabel="Isi data"
        destructive={false}
        onCancel={() => setConfirmVisible(false)}
        onConfirm={seed}
      />
    </AppPage>
  );
}

const styles = StyleSheet.create({
  content: {
    paddingBottom: space.xxl,
  },
  section: {
    marginTop: space.xxxl,
  },
  sectionGap: {
    marginTop: space.md,
  },
  accountRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  accountIcon: {
    width: 44,
    height: 44,
    borderRadius: radius.card,
    backgroundColor: colors.accentSoft,
    alignItems: 'center',
    justifyContent: 'center',
  },
  accountText: {
    flex: 1,
    marginLeft: space.lg,
  },
  accountMeta: {
    marginTop: space.xs,
  },
  bannerGap: {
    marginTop: space.md,
  },
  aboutMeta: {
    marginTop: space.xs,
  },
});
