import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/composer_context.dart';
import '../providers/composer_provider.dart';

class ContextChips extends ConsumerWidget {
  const ContextChips({super.key, required this.contexts});

  final List<ComposerContext> contexts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (contexts.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        scrollDirection: Axis.horizontal,
        itemCount: contexts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, index) {
          final ctx = contexts[index];
          return InputChip(
            avatar: Icon(_iconFor(ctx.type), size: 14),
            label: Text(ctx.displayLabel),
            onDeleted: () =>
                ref.read(composerProvider.notifier).removeContext(ctx.id),
            onPressed: () =>
                ref.read(composerProvider.notifier).inspectContext(ctx.id),
          );
        },
      ),
    );
  }

  IconData _iconFor(ComposerContextType t) {
    switch (t) {
      case ComposerContextType.file:
        return Icons.description_outlined;
      case ComposerContextType.selection:
        return Icons.select_all;
      case ComposerContextType.folder:
        return Icons.folder_outlined;
      case ComposerContextType.symbol:
        return Icons.code;
      case ComposerContextType.changeSet:
        return Icons.change_history;
      case ComposerContextType.execution:
        return Icons.play_circle_outline;
      case ComposerContextType.test:
        return Icons.science_outlined;
      case ComposerContextType.terminal:
        return Icons.terminal;
    }
  }
}
