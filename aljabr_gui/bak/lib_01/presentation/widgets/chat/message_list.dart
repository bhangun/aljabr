import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/extensions.dart';
import '../../../features/chat/models/file_diff.dart';
import '../../../features/chat/models/file_reference.dart';
import '../../../features/chat/models/message.dart';
import '../../../features/chat/states/chat_provider.dart';
import '../shared/shared_widgets.dart';

class MessageList extends ConsumerStatefulWidget {
  const MessageList({super.key});

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  final _scrollController = ScrollController();
  int _lastMessageCount = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottomIfNeeded(int count) {
    if (count == _lastMessageCount) return;
    _lastMessageCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider.select((s) => s.messages));
    // Also rebuild-scroll while the last message streams in.
    final lastContentLength = messages.isEmpty
        ? 0
        : messages.last.content.length;

    if (messages.isEmpty) {
      return const EmptyState(
        icon: Icons.code,
        message: 'Start a conversation',
        subtitle:
            'Ask anything about your code, paste files, or describe what you want to build.',
      );
    }

    _scrollToBottomIfNeeded(messages.length * 100000 + lastContentLength);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: messages.length,
      itemBuilder: (_, i) =>
          MessageBubble(message: messages[i], isLast: i == messages.length - 1),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, this.isLast = false});
  final Message message;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: switch (message.role) {
        MessageRole.user => _UserBubble(message: message),
        MessageRole.assistant => _AssistantBubble(
          message: message,
          isLast: isLast,
        ),
        MessageRole.system => const SizedBox.shrink(),
      },
    );
  }
}

// ── User Bubble ───────────────────────────────────────────────────────────────

class _UserBubble extends ConsumerStatefulWidget {
  const _UserBubble({required this.message});
  final Message message;

  @override
  ConsumerState<_UserBubble> createState() => _UserBubbleState();
}

class _UserBubbleState extends ConsumerState<_UserBubble> {
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.message.content);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editingId = ref.watch(editingMessageIdProvider);
    final isEditing = editingId == widget.message.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.message.attachedFiles.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            alignment: WrapAlignment.end,
            children: widget.message.attachedFiles
                .map((f) => _FileChip(file: f))
                .toList(),
          ),
        if (widget.message.attachedFiles.isNotEmpty) const SizedBox(height: 6),
        if (isEditing)
          _EditingBubble(
            controller: _editController,
            onCancel: () =>
                ref.read(chatProvider.notifier).cancelEditingMessage(),
            onSave: () {
              ref
                  .read(chatProvider.notifier)
                  .editAndResend(widget.message.id, _editController.text);
            },
          )
        else
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onDoubleTap: () {
                _editController.text = widget.message.content;
                ref
                    .read(chatProvider.notifier)
                    .beginEditingMessage(widget.message.id);
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxW = math.min(constraints.maxWidth * 0.72, 760.0).toDouble();
                  return Container(
                    constraints: BoxConstraints(maxWidth: maxW),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.12),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(6),
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      border: Border.all(
                        color: AppTheme.accent.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      widget.message.content,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.message.wasEdited) ...[
              const Text(
                'edited · ',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 10.5),
              ),
            ],
            Text(
              widget.message.createdAt.toTimestamp(),
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10.5),
            ),
            if (!isEditing) ...[
              const SizedBox(width: 6),
              _SmallIconAction(
                icon: Icons.edit_outlined,
                tooltip: 'Edit & resend',
                onTap: () {
                  _editController.text = widget.message.content;
                  ref
                      .read(chatProvider.notifier)
                      .beginEditingMessage(widget.message.id);
                },
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _EditingBubble extends StatelessWidget {
  const _EditingBubble({
    required this.controller,
    required this.onCancel,
    required this.onSave,
  });
  final TextEditingController controller;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 640, minWidth: 320),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            maxLines: null,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CodexButton(
                label: 'Cancel',
                variant: ButtonVariant.ghost,
                small: true,
                onPressed: onCancel,
              ),
              const SizedBox(width: 6),
              CodexButton(
                label: 'Save & resend',
                icon: Icons.send,
                small: true,
                onPressed: onSave,
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Resending will discard the replies that came after this message.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

// ── Assistant Bubble ──────────────────────────────────────────────────────────

class _AssistantBubble extends ConsumerWidget {
  const _AssistantBubble({required this.message, required this.isLast});
  final Message message;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 13,
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Claude',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            if (message.isStreaming) const PulsingDots(),
            if (!message.isStreaming)
              Text(
                message.createdAt.toTimestamp(),
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10.5,
                ),
              ),
            if (!message.isStreaming && message.tokenCount != null) ...[
              const Text(
                ' · ',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 10.5),
              ),
              Text(
                '~${message.tokenCount} tok',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10.5,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (message.hasError)
          _ErrorCard(message: message.errorMessage ?? message.content)
        else if (message.content.isEmpty && message.isStreaming)
          const Padding(
            padding: EdgeInsets.only(left: 30),
            child: PulsingDots(),
          )
        else
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Container(
              constraints: const BoxConstraints(minWidth: 160),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border, width: 0.5),
                boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0,2))],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MarkdownContent(content: message.content),
                  if (message.diffs.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _DiffList(diffs: message.diffs),
                  ],
                  if (!message.isStreaming) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _CopyButton(content: message.content),
                        const SizedBox(width: 14),
                        if (!isLoading)
                          _SmallIconAction(
                            icon: Icons.replay,
                            tooltip: 'Regenerate',
                            onTap: () => ref
                                .read(chatProvider.notifier)
                                .regenerateMessage(message.id),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
    );
  }
}

// ── Markdown renderer ─────────────────────────────────────────────────────────

class _MarkdownContent extends StatelessWidget {
  const _MarkdownContent({required this.content});
  final String content;

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: content,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          height: 1.6,
        ),
        h1: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        h2: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        h3: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        code: const TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 12.5,
          color: AppTheme.accent,
          backgroundColor: Color(0xFF1A2030),
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFF0D1117),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: AppTheme.accent, width: 3)),
          color: AppTheme.accent.withOpacity(0.05),
        ),
        listBullet: const TextStyle(color: AppTheme.textSecondary),
        strong: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        em: const TextStyle(
          color: AppTheme.textSecondary,
          fontStyle: FontStyle.italic,
        ),
        a: const TextStyle(
          color: AppTheme.accent,
          decoration: TextDecoration.underline,
        ),
        tableBody: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
        tableHead: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        tableBorder: TableBorder.all(color: AppTheme.border, width: 0.5),
      ),
      builders: {'code': _CodeBuilder()},
    );
  }
}

class _CodeBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(element, TextStyle? preferredStyle) {
    final String code = element.textContent;
    final String? lang = element.attributes['class']?.replaceFirst(
      'language-',
      '',
    );

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: HighlightView(
            code,
            language: lang ?? 'plaintext',
            theme: atomOneDarkTheme,
            textStyle: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 12.5,
              height: 1.6,
            ),
            padding: const EdgeInsets.all(12),
          ),
        ),
        Positioned(top: 6, right: 6, child: Row(children: [ _CopyIconButton(text: code), const SizedBox(width: 6), _RunIconButton(text: code, lang: lang), ])),
      ],
    );
  }
}

class _CopyIconButton extends StatefulWidget {
  const _CopyIconButton({required this.text});
  final String text;

  @override
  State<_CopyIconButton> createState() => _CopyIconButtonState();
}

class _CopyIconButtonState extends State<_CopyIconButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: widget.text));
        setState(() => _copied = true);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _copied = false);
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated.withOpacity(0.9),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(
          _copied ? Icons.check : Icons.copy,
          size: 13,
          color: _copied ? AppTheme.success : AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _RunIconButton extends StatefulWidget {
  const _RunIconButton({required this.text, this.lang});
  final String text;
  final String? lang;

  @override
  State<_RunIconButton> createState() => _RunIconButtonState();
}

class _RunIconButtonState extends State<_RunIconButton> {
  bool _ran = false;

  @override
  Widget build(BuildContext context) {
    final runnable = (widget.lang ?? '').toLowerCase();
    // Allow 'run' for common scripting languages (copy to clipboard as helper).
    final enabled = ['python', 'dart', 'javascript', 'js', 'bash', 'sh'].contains(runnable);

    return GestureDetector(
      onTap: enabled
          ? () async {
              await Clipboard.setData(ClipboardData(text: widget.text));
              setState(() => _ran = true);
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) setState(() => _ran = false);
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: enabled ? AppTheme.accent.withOpacity(0.12) : AppTheme.surfaceElevated.withOpacity(0.9),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(
          _ran ? Icons.check : Icons.play_arrow,
          size: 13,
          color: enabled ? AppTheme.accent : AppTheme.textMuted,
        ),
      ),
    );
  }
}

// ── Diff list inside message ──────────────────────────────────────────────────

class _DiffList extends ConsumerWidget {
  const _DiffList({required this.diffs});
  final List<FileDiff> diffs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Proposed changes (${diffs.length})',
          icon: Icons.difference,
          trailing: diffs.length > 1
              ? GestureDetector(
                  onTap: () =>
                      ref.read(chatProvider.notifier).applyAllDiffs(diffs),
                  child: const Text(
                    'Apply all',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
        ),
        ...diffs.map(
          (d) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _DiffSummaryCard(
              diff: d,
              onView: () => ref.read(chatProvider.notifier).selectDiff(d),
              onApply: () => ref.read(chatProvider.notifier).applyDiff(d),
            ),
          ),
        ),
      ],
    );
  }
}

String _buildUnifiedDiff(FileDiff diff) {
  final buf = StringBuffer();
  buf.writeln('--- a/${diff.fileName}');
  buf.writeln('+++ b/${diff.fileName}');
  buf.writeln('');
  for (final line in diff.lines) {
    switch (line.type) {
      case DiffLineType.added:
        buf.writeln('+${line.content}');
        break;
      case DiffLineType.removed:
        buf.writeln('-${line.content}');
        break;
      case DiffLineType.context:
        buf.writeln(' ${line.content}');
        break;
    }
  }
  return buf.toString();
}

class _DiffSummaryCard extends StatelessWidget {
  const _DiffSummaryCard({
    required this.diff,
    required this.onView,
    required this.onApply,
  });
  final FileDiff diff;
  final VoidCallback onView;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.description_outlined,
            size: 15,
            color: AppTheme.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diff.fileName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    StatusBadge('+${diff.addedLines}', color: AppTheme.success),
                    const SizedBox(width: 5),
                    StatusBadge('-${diff.removedLines}', color: AppTheme.error),
                  ],
                ),
              ],
            ),
          ),
          CodexButton(
            label: 'View',
            onPressed: onView,
            variant: ButtonVariant.ghost,
            small: true,
          ),
          const SizedBox(width: 6),
          CodexButton(
            label: 'Apply',
            icon: Icons.check,
            onPressed: onApply,
            small: true,
          ),
          const SizedBox(width: 6),
          CodexButton(
            label: 'Export',
            icon: Icons.ios_share_outlined,
            onPressed: () async {
              final patch = _buildUnifiedDiff(diff);
              await Clipboard.setData(ClipboardData(text: patch));
              // show feedback
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Diff copied to clipboard')));
            },
            variant: ButtonVariant.ghost,
            small: true,
          ),
        ],
      ),
    );
  }
}

// ── File chip ─────────────────────────────────────────────────────────────────

class _FileChip extends StatelessWidget {
  const _FileChip({required this.file});
  final FileReference file;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.insert_drive_file_outlined,
            size: 12,
            color: AppTheme.textMuted,
          ),
          const SizedBox(width: 4),
          Text(
            file.name,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends ConsumerWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(left: 30),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.error.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 15, color: AppTheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.error, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          CodexButton(
            label: 'Retry',
            small: true,
            variant: ButtonVariant.secondary,
            onPressed: () => ref.read(chatProvider.notifier).retryLastMessage(),
          ),
        ],
      ),
    );
  }
}

class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.content});
  final String content;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: widget.content));
        setState(() => _copied = true);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _copied = false);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _copied ? Icons.check : Icons.copy,
            size: 12,
            color: AppTheme.textMuted,
          ),
          const SizedBox(width: 4),
          Text(
            _copied ? 'Copied!' : 'Copy',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SmallIconAction extends StatelessWidget {
  const _SmallIconAction({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Icon(icon, size: 13, color: AppTheme.textMuted),
      ),
    );
  }
}
