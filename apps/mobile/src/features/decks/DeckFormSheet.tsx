import { useState } from 'react';
import { View } from 'react-native';

import { AppButton } from '../../components/AppButton';
import { AppSheet } from '../../components/AppSheet';
import { AppText } from '../../components/AppText';
import { AppTextField } from '../../components/AppTextField';
import type { Deck } from '../../db/schema';
import { useDb } from '../../db/provider';
import { space } from '../../theme/tokens';
import { createDeck, updateDeck } from './deckRepository';

export interface DeckFormSheetProps {
  visible: boolean;
  deck?: Deck | null;
  onClose: () => void;
  onSaved?: (id: string) => void;
}

export function DeckFormSheet({
  visible,
  deck,
  onClose,
  onSaved,
}: DeckFormSheetProps): React.JSX.Element {
  const db = useDb();
  const [name, setName] = useState(deck?.name ?? '');
  const [description, setDescription] = useState(deck?.description ?? '');
  const [nameError, setNameError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  // Reset local state whenever the sheet is reopened for a different deck.
  const [instance, setInstance] = useState(deck?.id ?? 'new');
  const nextInstance = deck?.id ?? 'new';
  if (instance !== nextInstance) {
    setInstance(nextInstance);
    setName(deck?.name ?? '');
    setDescription(deck?.description ?? '');
    setNameError(null);
    setSaving(false);
  }

  const editing = Boolean(deck);

  const close = () => {
    if (!editing) {
      setName('');
      setDescription('');
      setNameError(null);
      setSaving(false);
    }
    onClose();
  };

  const save = async () => {
    const trimmed = name.trim();
    if (trimmed.length === 0) {
      setNameError('Nama deck tidak boleh kosong.');
      return;
    }
    if (trimmed.length > 120) {
      setNameError('Nama deck maksimal 120 karakter.');
      return;
    }

    setNameError(null);
    setSaving(true);
    try {
      const value = description.trim();
      const id = editing
        ? deck!.id
        : await createDeck(db, {
            name: trimmed,
            description: value.length === 0 ? null : value,
          });

      if (editing) {
        await updateDeck(db, {
          id,
          name: trimmed,
          description: value.length === 0 ? null : value,
        });
      }

      setSaving(false);
      onSaved?.(id);
      close();
    } catch {
      setSaving(false);
      setNameError('Deck gagal disimpan. Coba lagi.');
    }
  };

  return (
    <AppSheet visible={visible} onClose={onClose}>
      <AppText variant="h3" weight="semibold">
        {editing ? 'Ubah deck' : 'Deck baru'}
      </AppText>
      <View style={{ marginTop: space.xl, gap: space.lg }}>
        <AppTextField
          label="Nama deck"
          hint="Misal: Kosakata JLPT N4"
          value={name}
          onChangeText={(value) => {
            setName(value);
            if (nameError) setNameError(null);
          }}
          autoFocus={!editing}
          autoCapitalize="sentences"
          returnKeyType="next"
          errorText={nameError ?? undefined}
        />
        <AppTextField
          label="Deskripsi (opsional)"
          hint="Catatan singkat tentang deck ini"
          value={description}
          onChangeText={setDescription}
          multiline
          multilineRows={3}
          autoCapitalize="sentences"
        />
      </View>
      <View style={{ marginTop: space.xxl }}>
        <AppButton
          label={editing ? 'Simpan perubahan' : 'Buat deck'}
          onPress={save}
          loading={saving}
        />
      </View>
    </AppSheet>
  );
}
