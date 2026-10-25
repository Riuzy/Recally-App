import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/widgets/widgets.dart';

/// Tab "Deck". CRUD deck dikerjakan pada Milestone 1.3.
class DecksScreen extends StatelessWidget {
  const DecksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: 'Deck',
      child: AppEmptyState(
        icon: PhosphorIconsRegular.stack,
        title: 'Belum ada deck',
        message: 'Deck akan muncul di sini setelah kamu membuatnya.',
      ),
    );
  }
}
