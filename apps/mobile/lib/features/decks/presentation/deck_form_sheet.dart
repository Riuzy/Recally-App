import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../data/deck_repository.dart';

/// Membuat deck baru (mengembalikan id) atau mengubah deck (mengembalikan id
/// yang sama). `null` berarti pengguna menutup sheet tanpa menyimpan.
Future<String?> showDeckFormSheet(BuildContext context, {Deck? deck}) {
  return showAppSheet<String>(
    context: context,
    builder: (_) => _DeckFormSheet(deck: deck),
  );
}

class _DeckFormSheet extends ConsumerStatefulWidget {
  const _DeckFormSheet({this.deck});

  final Deck? deck;

  @override
  ConsumerState<_DeckFormSheet> createState() => _DeckFormSheetState();
}

class _DeckFormSheetState extends ConsumerState<_DeckFormSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.deck?.name ?? '',
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.deck?.description ?? '',
  );

  String? _nameError;
  bool _saving = false;

  bool get _isEditing => widget.deck != null;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Nama deck tidak boleh kosong.');
      return;
    }
    if (name.length > 120) {
      setState(() => _nameError = 'Nama deck maksimal 120 karakter.');
      return;
    }

    setState(() {
      _nameError = null;
      _saving = true;
    });

    final description = _description.text.trim();
    final repository = ref.read(deckRepositoryProvider);

    final id = _isEditing
        ? widget.deck!.id
        : await repository.create(
            name: name,
            description: description.isEmpty ? null : description,
          );

    if (_isEditing) {
      await repository.update(
        id: id,
        name: name,
        description: description.isEmpty ? null : description,
      );
    }

    if (mounted) Navigator.of(context).pop(id);
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
              _isEditing ? 'Ubah deck' : 'Deck baru',
              style: AppTypography.h3.copyWith(color: colors.ink),
            ),
            SizedBox(height: theme.space5),
            AppTextField(
              label: 'Nama deck',
              hint: 'Misal: Kosakata JLPT N4',
              controller: _name,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              errorText: _nameError,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            SizedBox(height: theme.space4),
            AppTextField(
              label: 'Deskripsi (opsional)',
              hint: 'Catatan singkat tentang deck ini',
              controller: _description,
              minLines: 2,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: theme.space6),
            AppButton(
              label: _isEditing ? 'Simpan perubahan' : 'Buat deck',
              onPressed: _save,
              isLoading: _saving,
            ),
          ],
        ),
      ),
    );
  }
}
