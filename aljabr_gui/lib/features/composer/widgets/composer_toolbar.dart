import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/composer_state.dart';
import 'mode_selector.dart';
import '../providers/composer_provider.dart';
import 'agent_preview_dialog.dart';

class ComposerToolbar extends ConsumerWidget {
  const ComposerToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(composerProvider);
    return Row(
      children: [
        const ModeSelector(),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () {
            // Attach current suggested contexts
            ref.read(composerProvider.notifier).suggestContextsFromEditor();
          },
          icon: const Icon(Icons.attach_file),
          label: const Text('Attach'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () {
            // Open agent preview modal
            showDialog(
              context: context,
              builder: (ctx) => const AgentPreviewDialog(),
            );
          },
          icon: const Icon(Icons.smart_toy_outlined),
          label: const Text('Agent'),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: state.status == ComposerStatus.submitting
              ? null
              : () => ref.read(composerProvider.notifier).submit(),
          child: const Text('Send'),
        ),
      ],
    );
  }
}
