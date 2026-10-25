import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/widgets/widgets.dart';

/// Tab "Hari Ini".
///
/// Untuk sementara kosong: daftar kartu jatuh tempo baru diisi pada tahap
/// sesi belajar (Milestone 1.4).
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Hari ini',
      subtitle: 'Belajar sedikit, ingat lebih lama.',
      child: AppEmptyState(
        icon: PhosphorIconsRegular.cards,
        title: 'Belum ada kartu jatuh tempo',
        message:
            'Buat deck dan tambahkan kartu. Kartu yang sudah waktunya diulang '
            'akan muncul di sini.',
        action: AppButton(
          label: 'Buka Deck',
          variant: AppButtonVariant.secondary,
          expand: false,
          onPressed: () => context.go('/decks'),
        ),
      ),
    );
  }
}
