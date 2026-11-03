import { useState } from 'react';
import { View } from 'react-native';

import { AppBanner } from '../../components/AppBanner';
import { AppButton } from '../../components/AppButton';
import { AppSheet } from '../../components/AppSheet';
import { AppText } from '../../components/AppText';
import { AppTextField } from '../../components/AppTextField';
import { useDb } from '../../db/provider';
import { colors, space } from '../../theme/tokens';
import { createManyCards } from '../study/cardRepository';
import { parseCardLines } from './cardImport';

export interface PasteCardsSheetProps {
  visible: boolean;
  deckId: string;
  onClose: () => void;
  onSaved?: (created: number) => void;
}

export function PasteCardsSheet({
  visible,
  deckId,
  onClose,
  onSaved,
}: PasteCardsSheetProps): React.JSX.Element {
  const db = useDb();
  const [text, setText] = useState('');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const parsed = parseCardLines(text);
  const canSave = parsed.cards.length > 0 && !parsed.hasInvalid;

  const close = () => {
    setText('');
    setSaving(false);
    setError(null);
    onClose();
  };

  const save = async () => {
    if (!canSave) return;
    setSaving(true);
    setError(null);
    try {
      const created = await createManyCards(db, {
        deckId,
        cards: parsed.cards,
      });
      setSaving(false);
      onSaved?.(created);
      close();
    } catch {
      setSaving(false);
      setError('Kartu gagal ditambahkan. Coba lagi.');
    }
  };

  return (
    <AppSheet visible={visible} onClose={close}>
      <AppText variant="h3" weight="semibold">
        Tempel banyak kartu
      </AppText>
      <AppText variant="body" color={colors.inkSoft} style={{ marginTop: space.sm }}>
        Satu kartu per baris, pisahkan depan dan belakang dengan titik koma.
      </AppText>
      <View style={{ marginTop: space.lg }}>
        <AppTextField
          label="Daftar kartu"
          hint={'pagi;morning\nmalam;night'}
          value={text}
          onChangeText={setText}
          multiline
          multilineRows={6}
          helperText="Contoh: arigatou;terima kasih"
          autoCapitalize="none"
          autoCorrect={false}
        />
      </View>
      {parsed.hasInvalid ? (
        <View style={{ marginTop: space.lg }}>
          <AppBanner
            tone="danger"
            message={`Baris ${parsed.invalidLines.join(', ')} tidak valid. Gunakan format depan;belakang tanpa sisi kosong.`}
          />
        </View>
      ) : null}
      {parsed.cards.length > 0 ? (
        <AppText
          variant="label"
          color={colors.inkSoft}
          style={{ marginTop: space.lg }}
        >
          {parsed.cards.length} kartu siap ditambahkan.
        </AppText>
      ) : null}
      {error ? (
        <View style={{ marginTop: space.lg }}>
          <AppBanner tone="danger" message={error} />
        </View>
      ) : null}
      <View style={{ marginTop: space.xxl }}>
        <AppButton
          label={
            parsed.cards.length === 0
              ? 'Tambah kartu'
              : `Tambah ${parsed.cards.length} kartu`
          }
          onPress={canSave ? save : undefined}
          loading={saving}
        />
      </View>
    </AppSheet>
  );
}
