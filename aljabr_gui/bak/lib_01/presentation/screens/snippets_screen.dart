import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../features/chat/models/prompt_snippet.dart';
import '../providers/snippets_provider.dart';
import '../widgets/shared/shared_widgets.dart';

class SnippetsScreen extends ConsumerWidget {
  const SnippetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snippets = ref.watch(snippetsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textPrimary,
        title: const Text(
          'Prompt snippets',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            tooltip: 'New snippet',
            onPressed: () => _showEditor(context, ref),
          ),
        ],
      ),
      body: snippets.isEmpty
          ? const EmptyState(
              icon: Icons.bolt_outlined,
              message: 'No snippets yet',
              subtitle:
                  'Snippets let you trigger reusable prompts with /shortcut',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: snippets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _SnippetCard(
                snippet: snippets[i],
                onEdit: () => _showEditor(context, ref, snippets[i]),
                onDelete: () => ref
                    .read(snippetsProvider.notifier)
                    .deleteSnippet(snippets[i].id),
              ),
            ),
    );
  }

  void _showEditor(
    BuildContext context,
    WidgetRef ref, [
    PromptSnippet? existing,
  ]) {
    showDialog(
      context: context,
      builder: (_) => _SnippetEditorDialog(existing: existing),
    );
  }
}

class _SnippetCard extends StatelessWidget {
  const _SnippetCard({
    required this.snippet,
    required this.onEdit,
    required this.onDelete,
  });
  final PromptSnippet snippet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  snippet.title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (snippet.shortcut != null)
                StatusBadge(snippet.shortcut!, color: AppTheme.accent),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 16),
                color: AppTheme.textMuted,
                onPressed: onEdit,
                splashRadius: 14,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 16),
                color: AppTheme.error,
                onPressed: onDelete,
                splashRadius: 14,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            snippet.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SnippetEditorDialog extends ConsumerStatefulWidget {
  const _SnippetEditorDialog({this.existing});
  final PromptSnippet? existing;

  @override
  ConsumerState<_SnippetEditorDialog> createState() =>
      _SnippetEditorDialogState();
}

class _SnippetEditorDialogState extends ConsumerState<_SnippetEditorDialog> {
  late TextEditingController _titleCtrl;
  late TextEditingController _shortcutCtrl;
  late TextEditingController _contentCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _shortcutCtrl = TextEditingController(
      text: e?.shortcut?.replaceFirst('/', '') ?? '',
    );
    _contentCtrl = TextEditingController(text: e?.content ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _shortcutCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    final rawShortcut = _shortcutCtrl.text.trim();
    final shortcut = rawShortcut.isEmpty
        ? null
        : '/${rawShortcut.replaceFirst('/', '')}';

    if (widget.existing != null) {
      ref
          .read(snippetsProvider.notifier)
          .updateSnippet(
            widget.existing!.copyWith(
              title: title,
              content: content,
              shortcut: shortcut,
            ),
          );
    } else {
      ref
          .read(snippetsProvider.notifier)
          .addSnippet(title: title, content: content, shortcut: shortcut);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      title: Text(
        widget.existing == null ? 'New snippet' : 'Edit snippet',
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Title',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _shortcutCtrl,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Shortcut (optional)',
                prefixText: '/',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentCtrl,
              maxLines: 5,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Prompt content',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        CodexButton(label: 'Save', onPressed: _save),
      ],
    );
  }
}
