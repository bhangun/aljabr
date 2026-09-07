import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';

class OpenIdeButton extends ConsumerWidget {
  const OpenIdeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(editorVisibleProvider);

    return OutlinedButton.icon(
      onPressed: () => ref.read(editorVisibleProvider.notifier).toggle(),
      icon: Icon(Icons.bolt, size: 15, color: isOpen ? AppTheme.accent : AppTheme.accentBlue),
      label: Text(
        isOpen ? 'Close IDE' : 'Open IDE',
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12.5),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: isOpen ? AppTheme.accent.withValues(alpha: 0.5) : AppTheme.border),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
