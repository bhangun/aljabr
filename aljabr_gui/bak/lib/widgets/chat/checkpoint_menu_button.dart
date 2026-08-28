import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/checkpoint.dart';
import '../../providers/chat_providers.dart';
import '../../providers/checkpoint_providers.dart';
import '../../providers/session_providers.dart';
import '../../theme/app_colors.dart';

/// History icon button in the chat header. Opens a menu of [Checkpoint]s
/// taken during the session; restoring one truncates the transcript back
/// to that point after a confirmation dialog (destructive action).
class CheckpointMenuButton extends ConsumerWidget {
  const CheckpointMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkpoints = ref.watch(checkpointsProvider);

    return PopupMenuButton<Checkpoint>(
      tooltip: 'Session history',
      color: AppTheme.panelAlt,
      offset: const Offset(0, 36),
      icon: const Icon(Icons.history, size: 18, color: AppTheme.textSecondary),
      itemBuilder: (context) => [
        const PopupMenuItem<Checkpoint>(
          enabled: false,
          child: Text(
            'CHECKPOINTS',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (final cp in checkpoints)
          PopupMenuItem<Checkpoint>(
            value: cp,
            child: Row(
              children: [
                const Icon(
                  Icons.fiber_manual_record,
                  size: 8,
                  color: AppTheme.accentBlue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cp.label,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _relativeTime(cp.createdAt),
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
      onSelected: (cp) => _confirmRestore(context, ref, cp),
    );
  }

  void _confirmRestore(BuildContext context, WidgetRef ref, Checkpoint cp) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.panelAlt,
        title: const Text(
          'Restore checkpoint?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'This will discard everything after "${cp.label}", including any messages, '
          'tool calls, and file changes made since then. This can\'t be undone.',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () {
              final sessionId = ref.read(activeSessionIdProvider);
              ref
                  .read(chatTranscriptProvider(sessionId).notifier)
                  .restoreToCheckpoint(cp.entryCutoff, cp.label);
              Navigator.of(dialogContext).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.accentAmber,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  static String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}
