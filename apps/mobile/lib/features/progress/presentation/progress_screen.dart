import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/widgets/widgets.dart';

/// Tab "Progres". Statistik dikerjakan pada Milestone 2.1.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Progres',
      child: AppEmptyState(
        icon: PhosphorIconsRegular.chartLine,
        title: 'Belum ada data',
        message:
            'Statistik muncul setelah kamu menyelesaikan sesi belajar pertama.',
      ),
    );
  }
}
