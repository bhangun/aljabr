// widgets/editor/diff/diff_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import '../providers/diff_providers.dart';
import 'diff_file_card.dart';

/// The "Diff" tab: summary bar (files changed, total +/-, pending review
/// count) with a unified/split view toggle, then a scrollable list of
/// collapsible per-file diffs whose hunks can be accepted or rejected.
class DiffPanel extends ConsumerWidget {
  const DiffPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = ref.watch(activeSessionIdProvider);
    final diffs = ref.watch(fileDiffsProvider(sessionId));
    final (additions, deletions) = ref.watch(diffSummaryProvider(sessionId));
    final pending = ref.watch(pendingHunkCountProvider(sessionId));
    final viewMode = ref.watch(diffViewModeProvider);

    if (diffs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.difference_outlined,
              size: 48,
              color: AppTheme.textMuted,
            ),
            Gap(16),
            Text(
              'No changes yet',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 16,
              ),
            ),
            Gap(8),
            Text(
              'Changes made by the agent will appear here',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final allReviewed = pending == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Text(
                '${diffs.length} files changed',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(10),
              DiffStatChip(additions: additions, deletions: deletions),
              const Gap(10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: allReviewed
                      ? AppTheme.accentGreen.withValues(alpha: 0.15)
                      : AppTheme.accentAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      allReviewed ? Icons.check_circle : Icons.pending,
                      size: 12,
                      color: allReviewed
                          ? AppTheme.accentGreen
                          : AppTheme.accentAmber,
                    ),
                    const Gap(4),
                    Text(
                      allReviewed ? 'All reviewed' : '$pending pending',
                      style: TextStyle(
                        color: allReviewed
                            ? AppTheme.accentGreen
                            : AppTheme.accentAmber,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Tooltip(
                message: 'Revert all changes',
                child: IconButton(
                  onPressed: () => _confirmRevertAll(context, ref, sessionId),
                  icon: const Icon(
                    Icons.restore,
                    size: 17,
                    color: AppTheme.textSecondary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 30, minHeight: 30),
                ),
              ),
              const Gap(4),
              _ViewModeToggle(
                mode: viewMode,
                onChanged: (m) =>
                    ref.read(diffViewModeProvider.notifier).select(m),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppTheme.border),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: diffs.length,
            itemBuilder: (context, i) => DiffFileCard(
              sessionId: sessionId,
              diff: diffs[i],
            ),
          ),
        ),
      ],
    );
  }
}

void _confirmRevertAll(BuildContext context, WidgetRef ref, String sessionId) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppTheme.panelAlt,
      title: const Text(
        'Revert all changes?',
        style: TextStyle(color: AppTheme.textPrimary),
      ),
      content: const Text(
        'This marks every hunk in every file as rejected, including any you already accepted. '
        'You can still review and accept them again afterward.',
        style: TextStyle(
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
            ref.read(fileDiffsProvider(sessionId).notifier).revertAll();
            Navigator.of(dialogContext).pop();
          },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE0554C),
          ),
          child: const Text('Revert all'),
        ),
      ],
    ),
  );
}

class _ViewModeToggle extends StatelessWidget {
  final DiffViewMode mode;
  final ValueChanged<DiffViewMode> onChanged;
  const _ViewModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppTheme.panelAlt,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: 'Unified',
            selected: mode == DiffViewMode.unified,
            onTap: () => onChanged(DiffViewMode.unified),
          ),
          _Segment(
            label: 'Split',
            selected: mode == DiffViewMode.split,
            onTap: () => onChanged(DiffViewMode.split),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppTheme.sidebarSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.textPrimary : AppTheme.textMuted,
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
