import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';

class ForkButton extends ConsumerWidget {
  const ForkButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeId = ref.watch(activeSessionIdProvider);
    return Tooltip(
      message: 'Fork this session',
      child: IconButton(
        onPressed: activeId.isEmpty
            ? null
            : () => ref.read(sessionListProvider.notifier).forkSession(activeId),
        icon: const Icon(Icons.call_split,
            size: 17, color: AppTheme.textSecondary),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }
}
