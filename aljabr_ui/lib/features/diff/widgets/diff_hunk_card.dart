import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chat/models/file_diff.dart';
import '../providers/diff_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/language.dart';
import 'change_explanation_card.dart';
import 'diff_line_row.dart';
import 'split_diff_row.dart';

/// One reviewable hunk within a file: `@@ ... @@` header, per-hunk
/// Accept/Reject controls, and its lines rendered in unified or split mode.
/// Rejected hunks dim and strike through so the reviewer can see at a
/// glance what won't ship.
class DiffHunkCard extends ConsumerWidget {
  final String sessionId;
  final String filePath;
  final DiffHunk hunk;

  const DiffHunkCard(
      {super.key,
      required this.sessionId,
      required this.filePath,
      required this.hunk});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(diffViewModeProvider);
    final rejected = hunk.status == HunkStatus.rejected;
    final language = languageForPath(filePath);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(
              color: AppTheme.panel,
              borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hunk.header,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppTheme.accentBlue,
                        fontFamily: 'monospace',
                        fontSize: 12),
                  ),
                ),
                _HunkActions(
                    sessionId: sessionId, filePath: filePath, hunk: hunk),
              ],
            ),
          ),
          Opacity(
            opacity: rejected ? 0.45 : 1,
            child: Column(
              children: [
                for (final line in hunk.lines)
                  viewMode == DiffViewMode.unified
                      ? DiffLineRow(line: line, language: language)
                      : SplitDiffRow(line: line, language: language),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HunkActions extends ConsumerWidget {
  final String sessionId;
  final String filePath;
  final DiffHunk hunk;
  const _HunkActions(
      {required this.sessionId, required this.filePath, required this.hunk});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(fileDiffsProvider(sessionId).notifier);

    if (hunk.status != HunkStatus.pending) {
      final color = hunk.status.color;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hunk.status == HunkStatus.accepted
                ? Icons.check_circle
                : Icons.cancel,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(hunk.status.label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          InkWell(
            onTap: () =>
                notifier.setHunkStatus(filePath, hunk.id, HunkStatus.pending),
            child: const Icon(Icons.undo, size: 13, color: AppTheme.textMuted),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionIcon(
          icon: Icons.help_outline_rounded,
          color: AppTheme.accentBlue,
          tooltip: 'Explain this change',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => ChangeExplanationDialog(
                filePath: filePath,
                hunk: hunk,
              ),
            );
          },
        ),
        const SizedBox(width: 4),
        _ActionIcon(
          icon: Icons.close,
          color: const Color(0xFFE0554C),
          tooltip: 'Reject hunk',
          onTap: () =>
              notifier.setHunkStatus(filePath, hunk.id, HunkStatus.rejected),
        ),
        const SizedBox(width: 4),
        _ActionIcon(
          icon: Icons.check,
          color: AppTheme.accentGreen,
          tooltip: 'Accept hunk',
          onTap: () =>
              notifier.setHunkStatus(filePath, hunk.id, HunkStatus.accepted),
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 12, color: color),
        ),
      ),
    );
  }
}
