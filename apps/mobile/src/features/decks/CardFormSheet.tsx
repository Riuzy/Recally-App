import { useState } from 'react';
import { View } from 'react-native';

import { AppButton } from '../../components/AppButton';
import { AppSheet } from '../../components/AppSheet';
import { AppText } from '../../components/AppText';
import { AppTextField } from '../../components/AppTextField';
import { useDb } from '../../db/provider';
import type { CardRow } from '../../db/schema';
import { colors, space } from '../../theme/tokens';
import {
  createCard,
  softDeleteCard,
  updateCardContent,
} from '../study/cardRepository';

export interface CardFormSheetProps {
  visible: boolean;
  deckId: string;
  card?: CardRow | null;
  onClose: () => void;
  onSaved?: () => void;
}

export function CardFormSheet({
  visible,
  deckId,
  card,
  onClose,
  onSaved,
}: CardFormSheetProps): React.JSX.Element {
  const db = useDb();
  const [front, setFront] = useState(card?.front ?? '');
  const [back, setBack] = useState(card?.back ?? '');
  const [frontError, setFrontError] = useState<string | null>(null);
  const [backError, setBackError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [confirmingDelete, setConfirmingDelete] = useState(false);

  const [instance, setInstance] = useState(`${deckId}:${card?.id ?? 'new'}`);
  const nextInstance = `${deckId}:${card?.id ?? 'new'}`;
  if (instance !== nextInstance) {
    setInstance(nextInstance);
    setFront(card?.front ?? '');
    setBack(card?.back ?? '');
    setFrontError(null);
    setBackError(null);
    setSaving(false);
    setConfirmingDelete(false);
  }

  const editing = Boolean(card);

  const close = () => {
    setConfirmingDelete(false);
    if (!editing) {
      setFront('');
      setBack('');
      setFrontError(null);
      setBackError(null);
      setSaving(false);
    }
    onClose();
  };

  const save = async () => {
    const frontText = front.trim();
    const backText = back.trim();
    setFrontError(frontText.length === 0 ? 'Sisi depan tidak boleh kosong.' : null);
    setBackError(backText.length === 0 ? 'Sisi belakang tidak boleh kosong.' : null);
    if (frontText.length === 0 || backText.length === 0) return;

    setSaving(true);
    try {
      if (editing) {
        await updateCardContent(db, {
          id: card!.id,
          front: frontText,
          back: backText,
        });
      } else {
        await createCard(db, { deckId, front: frontText, back: backText });
      }
      setSaving(false);
      onSaved?.();
      close();
    } catch {
      setSaving(false);
      setFrontError('Kartu gagal disimpan. Coba lagi.');
    }
  };

  const remove = async () => {
    setSaving(true);
    try {
      await softDeleteCard(db, card!.id);
      setSaving(false);
      onSaved?.();
      close();
    } catch {
      setSaving(false);
      setConfirmingDelete(false);
      setFrontError('Kartu gagal dihapus. Coba lagi.');
    }
  };

  if (confirmingDelete) {
    return (
      <AppSheet visible={visible} onClose={close}>
        <AppText variant="h3" weight="semibold">
          Hapus kartu?
        </AppText>
        <AppText variant="body" color={colors.inkSoft} style={{ marginTop: space.sm }}>
          Kartu ini akan hilang dari deck. Riwayat ulangannya tetap disimpan
          supaya sinkronisasi tetap konsisten.
        </AppText>
        <View style={{ marginTop: space.xxl, gap: space.sm }}>
          <AppButton label="Hapus" variant="danger" onPress={remove} loading={saving} />
          <AppButton
            label="Batal"
            variant="secondary"
            onPress={() => setConfirmingDelete(false)}
          />
        </View>
      </AppSheet>
    );
  }

  return (
    <AppSheet visible={visible} onClose={close}>
      <AppText variant="h3" weight="semibold">
        {editing ? 'Ubah kartu' : 'Kartu baru'}
      </AppText>
      <View style={{ marginTop: space.xl, gap: space.lg }}>
        <AppTextField
          label="Depan"
          hint="Pertanyaan atau kata yang ingin diingat"
          value={front}
          onChangeText={(value) => {
            setFront(value);
            if (frontError) setFrontError(null);
          }}
          autoFocus={!editing}
          multiline
          multilineRows={3}
          autoCapitalize="sentences"
          errorText={frontError ?? undefined}
        />
        <AppTextField
          label="Belakang"
          hint="Jawaban atau penjelasan"
          value={back}
          onChangeText={(value) => {
            setBack(value);
            if (backError) setBackError(null);
          }}
          multiline
          multilineRows={3}
          autoCapitalize="sentences"
          errorText={backError ?? undefined}
        />
      </View>
      <View style={{ marginTop: space.xxl }}>
        <AppButton
          label={editing ? 'Simpan perubahan' : 'Tambah kartu'}
          onPress={save}
          loading={saving}
        />
      </View>
      {editing ? (
        <AppButton
          label="Hapus kartu"
          variant="text"
          onPress={() => setConfirmingDelete(true)}
          style={{ marginTop: space.sm }}
        />
      ) : null}
    </AppSheet>
  );
}
