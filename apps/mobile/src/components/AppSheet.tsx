import { Modal, Pressable, ScrollView, StyleSheet, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { colors, radius, space } from '../theme/tokens';
import { AppButton } from './AppButton';
import { AppText } from './AppText';

export interface AppSheetProps {
  visible: boolean;
  onClose: () => void;
  children: React.ReactNode;
  dismissible?: boolean;
}

/**
 * White bottom sheet with a 24px top radius and thin handle. Content scrolls
 * when it grows, so forms stay usable with the keyboard open.
 */
export function AppSheet({
  visible,
  onClose,
  children,
  dismissible = true,
}: AppSheetProps): React.JSX.Element {
  const insets = useSafeAreaInsets();

  return (
    <Modal
      animationType="fade"
      transparent
      statusBarTranslucent
      visible={visible}
      onRequestClose={onClose}
    >
      <View style={styles.root}>
        <Pressable
          accessibilityRole="button"
          accessibilityLabel="Tutup"
          style={styles.backdrop}
          onPress={dismissible ? onClose : undefined}
        />
        <View style={[styles.sheet, { paddingBottom: space.xl + insets.bottom }]}>
          <View style={styles.handle} />
          <ScrollView
            bounces={false}
            keyboardShouldPersistTaps="handled"
            contentContainerStyle={styles.content}
            showsVerticalScrollIndicator={false}
          >
            {children}
          </ScrollView>
        </View>
      </View>
    </Modal>
  );
}

export interface AppConfirmSheetProps {
  visible: boolean;
  title: string;
  message: string;
  confirmLabel?: string;
  cancelLabel?: string;
  destructive?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}

/** Destructive confirmation inside a themed bottom sheet. */
export function AppConfirmSheet({
  visible,
  title,
  message,
  confirmLabel = 'Hapus',
  cancelLabel = 'Batal',
  destructive = true,
  onConfirm,
  onCancel,
}: AppConfirmSheetProps): React.JSX.Element {
  return (
    <AppSheet visible={visible} onClose={onCancel}>
      <AppText variant="h3" weight="semibold">
        {title}
      </AppText>
      <AppText variant="body" color={colors.inkSoft} style={styles.message}>
        {message}
      </AppText>
      <View style={styles.actions}>
        <AppButton
          label={confirmLabel}
          variant={destructive ? 'danger' : 'primary'}
          onPress={onConfirm}
        />
        <AppButton label={cancelLabel} variant="secondary" onPress={onCancel} />
      </View>
    </AppSheet>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    justifyContent: 'flex-end',
  },
  backdrop: {
    position: 'absolute',
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    backgroundColor: colors.overlay,
  },
  sheet: {
    maxHeight: '88%',
    backgroundColor: colors.surface,
    borderTopLeftRadius: radius.sheet,
    borderTopRightRadius: radius.sheet,
    borderTopWidth: 1,
    borderColor: colors.border,
    paddingTop: space.md,
    paddingHorizontal: space.xl,
  },
  handle: {
    width: 36,
    height: 4,
    borderRadius: 2,
    backgroundColor: colors.border,
    alignSelf: 'center',
  },
  content: {
    paddingTop: space.lg,
    paddingBottom: space.xs,
  },
  message: {
    marginTop: space.sm,
  },
  actions: {
    marginTop: space.xxl,
    gap: space.sm,
  },
});
