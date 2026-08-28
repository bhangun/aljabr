import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../models/chat_entry.dart';

/// Fixed bar shown above the input field whenever there are queued or
/// pending messages. Lets the user force-send all, send one by one, or
/// see how many jobs are currently running in the backend.
class QueueStatusWidget extends StatelessWidget {
  final List<ChatEntry> pendingEntries;
  final int queueSize;
  final int activeJobs;
  final VoidCallback onForceProcessAll;
  final Function(String entryId) onForceProcessSingle;
  final VoidCallback onClearQueue;

  const QueueStatusWidget({
    super.key,
    required this.pendingEntries,
    required this.queueSize,
    required this.activeJobs,
    required this.onForceProcessAll,
    required this.onForceProcessSingle,
    required this.onClearQueue,
  });

  @override
  Widget build(BuildContext context) {
    final pendingCount = pendingEntries.length;
    if (pendingCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.panelAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF4A3A1A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.schedule_send_rounded,
                  size: 15, color: Color(0xFFE6A817)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$pendingCount prompt${pendingCount == 1 ? '' : 's'} queued (auto-sends when agent finishes)',
                  style: const TextStyle(
                    color: Color(0xFFE6A817),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Process all button
              _SmallButton(
                label: 'Send now',
                icon: Icons.flash_on_rounded,
                onTap: onForceProcessAll,
              ),
            ],
          ),

          // ── Individual pending chips ────────────────────────────────────
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (int i = 0; i < pendingCount && i < 5; i++)
                _PendingChip(
                  label: pendingEntries[i].text.isNotEmpty
                      ? (pendingEntries[i].text.length > 25
                          ? '${pendingEntries[i].text.substring(0, 25)}...'
                          : pendingEntries[i].text)
                      : 'Attachment',
                  onSend: () => onForceProcessSingle(pendingEntries[i].id),
                ),
              if (pendingCount > 5)
                Text(
                  '+ ${pendingCount - 5} more',
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _SmallButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF4A3A1A),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: const Color(0xFFE6A817)),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFFE6A817),
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _PendingChip extends StatelessWidget {
  final String label;
  final VoidCallback onSend;
  const _PendingChip({required this.label, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSend,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.chip,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.send_outlined,
                size: 11, color: AppTheme.textMuted),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
