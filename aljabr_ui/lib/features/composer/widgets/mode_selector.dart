import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/composer_state.dart';
import '../providers/composer_provider.dart';

class ModeSelector extends ConsumerWidget {
  const ModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(composerProvider);
    return DropdownButton<ComposerMode>(
      value: state.mode,
      items: ComposerMode.values
          .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
          .toList(),
      onChanged: (m) {
        if (m != null) {
          ref.read(composerProvider.notifier).setMode(m);
        }
      },
    );
  }
}
