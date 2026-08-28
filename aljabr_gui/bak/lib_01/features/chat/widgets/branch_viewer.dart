import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../coding_agent.dart';
import '../models/branch.dart';

/// Widget for viewing and managing branches
class BranchViewer extends ConsumerWidget {
  const BranchViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeSessionProvider);
    if (session == null || session is! BranchingSession) {
      return const SizedBox.shrink();
    }

    final branchingSession = session as BranchingSession;
    final branches = branchingSession.branches;

    if (branches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceElevated,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Branches',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...branches.map(
                  (branch) => _BranchChip(
                    branch: branch,
                    isActive: branch.id == branchingSession.currentBranchId,
                    onTap: () {
                      // Switch to branch
                      ref.read(chatProvider.notifier).switchBranch(branch.id);
                    },
                    onDelete: () {
                      // Delete branch
                      ref.read(chatProvider.notifier).deleteBranch(branch.id);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchChip extends StatelessWidget {
  const _BranchChip({
    required this.branch,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  final Branch branch;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accent.withOpacity(0.15)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? AppTheme.accent : AppTheme.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? Icons.play_arrow : Icons.disabled_by_default,
                size: 14,
                color: isActive ? AppTheme.accent : AppTheme.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                branch.metadata['title'] ??
                    'Branch ${branch.id.substring(0, 6)}',
                style: TextStyle(
                  color: isActive ? AppTheme.accent : AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${branch.messageCount} msgs)',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
              ),
              if (!isActive) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.close,
                    size: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
