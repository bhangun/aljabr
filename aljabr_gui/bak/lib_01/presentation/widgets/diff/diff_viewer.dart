import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/chat/models/file_diff.dart';
import '../../../features/chat/states/chat_provider.dart';
import '../shared/shared_widgets.dart';

class DiffPanel extends ConsumerWidget {
  const DiffPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diff = ref.watch(selectedDiffProvider);

    if (diff == null) {
      return const EmptyState(
        icon: Icons.difference_outlined,
        message: 'No diff selected',
        subtitle: 'Proposed changes will appear here',
      );
    }

    return DiffViewer(diff: diff);
  }
}

class DiffViewer extends ConsumerWidget {
  const DiffViewer({super.key, required this.diff});
  final FileDiff diff;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _DiffHeader(diff: diff),
        const CodexDivider(),
        Expanded(child: _DiffContent(diff: diff)),
        const CodexDivider(),
        _DiffActions(diff: diff),
      ],
    );
  }
}

class _DiffHeader extends StatelessWidget {
  const _DiffHeader({required this.diff});
  final FileDiff diff;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.difference, size: 15, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              diff.fileName,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          StatusBadge('+${diff.addedLines}', color: AppTheme.success),
          const SizedBox(width: 6),
          StatusBadge('-${diff.removedLines}', color: AppTheme.error),
        ],
      ),
    );
  }
}

class _DiffContent extends StatelessWidget {
  const _DiffContent({required this.diff});
  final FileDiff diff;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: diff.lines
              .map((line) => _DiffLineWidget(line: line))
              .toList(),
        ),
      ),
    );
  }
}

class _DiffLineWidget extends StatelessWidget {
  const _DiffLineWidget({super.key, required this.line});
  final DiffLine line;

  @override
  Widget build(BuildContext context) {
    final isSeparator =
        line.type == DiffLineType.context && line.content == '...';

    if (isSeparator) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        color: AppTheme.surfaceElevated,
        child: const Text(
          '  ···',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 12,
            fontFamily: 'JetBrains Mono',
          ),
        ),
      );
    }

    final (bg, prefix, textColor) = switch (line.type) {
      DiffLineType.added => (
        AppTheme.diffAddedLine,
        '+ ',
        AppTheme.diffAddedText,
      ),
      DiffLineType.removed => (
        AppTheme.diffRemovedLine,
        '- ',
        AppTheme.diffRemovedText,
      ),
      DiffLineType.context => (
        Colors.transparent,
        '  ',
        AppTheme.textSecondary,
      ),
    };

    return Container(
      width: double.infinity,
      color: bg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line numbers
          SizedBox(
            width: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      line.oldLineNumber?.toString() ?? '',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontFamily: 'JetBrains Mono',
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 30,
                    child: Text(
                      line.newLineNumber?.toString() ?? '',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontFamily: 'JetBrains Mono',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Prefix (+/-)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              prefix,
              style: TextStyle(
                color: textColor,
                fontSize: 12.5,
                fontFamily: 'JetBrains Mono',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 2, bottom: 2),
              child: Text(
                line.content,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12.5,
                  fontFamily: 'JetBrains Mono',
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiffActions extends ConsumerWidget {
  const _DiffActions({required this.diff});
  final FileDiff diff;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CodexButton(
            label: 'Reject',
            icon: Icons.close,
            variant: ButtonVariant.secondary,
            onPressed: () => ref.read(chatProvider.notifier).rejectDiff(diff),
          ),
          const Spacer(),
          CodexButton(
            label: 'Apply changes',
            icon: Icons.check,
            variant: ButtonVariant.primary,
            onPressed: () => ref.read(chatProvider.notifier).applyDiff(diff),
          ),
        ],
      ),
    );
  }
}
