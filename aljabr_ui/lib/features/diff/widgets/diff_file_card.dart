import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chat/models/file_diff.dart';
import '../providers/diff_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/common/status_badge.dart';
import 'diff_hunk_card.dart';

/// A single file's diff: collapsible header (path, change-type badge,
/// +/- stat chip, Accept all / Reject all) with each hunk reviewable
/// independently when expanded.
class DiffFileCard extends ConsumerWidget {
  final String sessionId;
  final FileDiff diff;
  const DiffFileCard({super.key, required this.sessionId, required this.diff});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expandedFiles = ref.watch(expandedDiffFilesProvider);
    final expanded = expandedFiles.contains(diff.path);
    final notifier = ref.read(fileDiffsProvider(sessionId).notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.panelAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () =>
                ref.read(expandedDiffFilesProvider.notifier).toggle(diff.path),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    expanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
                    size: 16,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: diff.changeType.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      diff.changeType.badge,
                      style: TextStyle(
                          color: diff.changeType.color,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      diff.path,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 12.8,
                          fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DiffStatChip(
                      additions: diff.additions, deletions: diff.deletions),
                  const SizedBox(width: 10),
                  if (diff.pendingCount == 0)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.check_circle,
                          size: 14, color: AppTheme.accentGreen),
                    ),
                  _MiniButton(
                    label: 'Reject all',
                    color: const Color(0xFFE0554C),
                    onTap: () => notifier.setAllHunksInFile(
                        diff.path, HunkStatus.rejected),
                  ),
                  const SizedBox(width: 6),
                  _MiniButton(
                    label: 'Accept all',
                    color: AppTheme.accentGreen,
                    onTap: () => notifier.setAllHunksInFile(
                        diff.path, HunkStatus.accepted),
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  for (final hunk in diff.hunks)
                    DiffHunkCard(
                        sessionId: sessionId, filePath: diff.path, hunk: hunk),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MiniButton(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 10.5, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
