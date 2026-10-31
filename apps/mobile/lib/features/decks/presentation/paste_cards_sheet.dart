import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../study/data/card_repository.dart';
import '../domain/card_import.dart';

/// Membuat banyak kartu sekaligus dari teks "depan;belakang".
///
/// Mengembalikan jumlah kartu yang dibuat, atau `null` bila dibatalkan.
Future<int?> showPasteCardsSheet(
  BuildContext context, {
  required String deckId,
}) {
  return showAppSheet<int>(
    context: context,
    builder: (_) => _PasteCardsSheet(deckId: deckId),
  );
}

class _PasteCardsSheet extends ConsumerStatefulWidget {
  const _PasteCardsSheet({required this.deckId});

  final String deckId;

  @override
  ConsumerState<_PasteCardsSheet> createState() => _PasteCardsSheetState();
}

class _PasteCardsSheetState extends ConsumerState<_PasteCardsSheet> {
  final TextEditingController _controller = TextEditingController();
  ParsedCards _parsed = parseCardLines('');
  bool _saving = false;

  bool get _canSave => _parsed.cards.isNotEmpty && !_parsed.hasInvalid;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);

    final created = await ref
        .read(cardRepositoryProvider)
        .createMany(deckId: widget.deckId, cards: _parsed.cards);

    if (mounted) Navigator.of(context).pop(created);
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
              'Tempel banyak kartu',
              style: AppTypography.h3.copyWith(color: colors.ink),
            ),
            SizedBox(height: theme.space2),
            Text(
              'Satu kartu per baris, pisahkan depan dan belakang dengan titik '
              'koma.',
              style: AppTypography.body.copyWith(color: colors.inkSoft),
            ),
            SizedBox(height: theme.space4),
            AppTextField(
              label: 'Daftar kartu',
              hint: 'pagi;morning\nmalam;night',
              controller: _controller,
              minLines: 6,
              maxLines: 8,
              helperText: 'Contoh: arigatou;terima kasih',
              onChanged: (value) {
                setState(() => _parsed = parseCardLines(value));
              },
            ),
            if (_parsed.hasInvalid) ...[
              SizedBox(height: theme.space4),
              AppBanner(
                tone: AppBannerTone.danger,
                message:
                    'Baris ${_parsed.invalidLines.join(', ')} tidak valid. '
                    'Gunakan format depan;belakang tanpa sisi kosong.',
              ),
            ],
            if (_parsed.cards.isNotEmpty) ...[
              SizedBox(height: theme.space4),
              Text(
                '${_parsed.cards.length} kartu siap ditambahkan.',
                style: AppTypography.label.copyWith(color: colors.inkSoft),
              ),
            ],
            SizedBox(height: theme.space6),
            AppButton(
              label: _parsed.cards.isEmpty
                  ? 'Tambah kartu'
                  : 'Tambah ${_parsed.cards.length} kartu',
              onPressed: _canSave ? _save : null,
              isLoading: _saving,
            ),
          ],
        ),
      ),
    );
  }
}
