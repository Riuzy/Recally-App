import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../study/data/card_repository.dart';

/// Menambah kartu baru atau mengubah kartu yang ada.
///
/// Mengembalikan `true` bila ada perubahan yang tersimpan.
Future<bool?> showCardFormSheet(
  BuildContext context, {
  required String deckId,
  CardRow? card,
}) {
  return showAppSheet<bool>(
    context: context,
    builder: (_) => _CardFormSheet(deckId: deckId, card: card),
  );
}

class _CardFormSheet extends ConsumerStatefulWidget {
  const _CardFormSheet({required this.deckId, this.card});

  final String deckId;
  final CardRow? card;

  @override
  ConsumerState<_CardFormSheet> createState() => _CardFormSheetState();
}

class _CardFormSheetState extends ConsumerState<_CardFormSheet> {
  late final TextEditingController _front = TextEditingController(
    text: widget.card?.front ?? '',
  );
  late final TextEditingController _back = TextEditingController(
    text: widget.card?.back ?? '',
  );

  String? _frontError;
  String? _backError;
  bool _saving = false;

  bool get _isEditing => widget.card != null;

  @override
  void dispose() {
    _front.dispose();
    _back.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final front = _front.text.trim();
    final back = _back.text.trim();

    setState(() {
      _frontError = front.isEmpty ? 'Sisi depan tidak boleh kosong.' : null;
      _backError = back.isEmpty ? 'Sisi belakang tidak boleh kosong.' : null;
    });
    if (front.isEmpty || back.isEmpty) return;

    setState(() => _saving = true);

    final repository = ref.read(cardRepositoryProvider);
    if (_isEditing) {
      await repository.updateContent(
        id: widget.card!.id,
        front: front,
        back: back,
      );
    } else {
      await repository.create(deckId: widget.deckId, front: front, back: back);
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final confirmed = await showAppConfirmSheet(
      context,
      title: 'Hapus kartu?',
      message:
          'Kartu ini akan hilang dari deck. Riwayat ulangannya tetap disimpan '
          'supaya sinkronisasi tetap konsisten.',
    );
    if (!confirmed || !mounted) return;

    await ref.read(cardRepositoryProvider).softDelete(widget.card!.id);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colors = context.colors;

    return AnimatedPadding(
      duration: theme.motionFast,
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? 'Ubah kartu' : 'Kartu baru',
              style: AppTypography.h3.copyWith(color: colors.ink),
            ),
            SizedBox(height: theme.space5),
            AppTextField(
              label: 'Depan',
              hint: 'Pertanyaan atau kata yang ingin diingat',
              controller: _front,
              autofocus: !_isEditing,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              errorText: _frontError,
              onChanged: (_) {
                if (_frontError != null) setState(() => _frontError = null);
              },
            ),
            SizedBox(height: theme.space4),
            AppTextField(
              label: 'Belakang',
              hint: 'Jawaban atau penjelasan',
              controller: _back,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              errorText: _backError,
              onChanged: (_) {
                if (_backError != null) setState(() => _backError = null);
              },
            ),
            SizedBox(height: theme.space6),
            AppButton(
              label: _isEditing ? 'Simpan perubahan' : 'Tambah kartu',
              onPressed: _save,
              isLoading: _saving,
            ),
            if (_isEditing) ...[
              SizedBox(height: theme.space2),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
                child: Text(
                  'Hapus kartu',
                  style: AppTypography.label.copyWith(color: colors.danger),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
