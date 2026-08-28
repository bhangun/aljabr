import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../providers/agent_runtime_provider.dart';

class SendButton extends ConsumerWidget {
  final bool hasText;
  final VoidCallback onPressed;

  const SendButton({
    super.key,
    required this.hasText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRunning = ref.watch(agentRunningProvider);
    final isActive = hasText || isRunning;

    void handlePress() {
      if (isRunning) {
        ref.read(agentRunningProvider.notifier).stop();
      } else {
        onPressed();
      }
    }

    return Material(
      color: isActive ? AppTheme.accentBlue : AppTheme.border,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: isActive ? handlePress : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isRunning
                ? const Icon(
                    Icons.pause,
                    key: ValueKey('pause'),
                    size: 16,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.arrow_upward,
                    key: const ValueKey('send'),
                    size: 16,
                    color: hasText ? Colors.white : AppTheme.textMuted,
                  ),
          ),
        ),
      ),
    );
  }
}
