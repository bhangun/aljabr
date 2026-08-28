import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/composer_provider.dart';

enum CodeBlockAction { copy, insert, replaceSelection }

class CodeBlockActions extends ConsumerWidget {
  final String code;
  final String targetPath;
  final int? startLine;
  final int? endLine;

  const CodeBlockActions(
      {super.key,
      required this.code,
      required this.targetPath,
      this.startLine,
      this.endLine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Copy',
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () => _copy(context),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _insert(ref, context),
                child: const Text('Insert at cursor'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: startLine != null && endLine != null
                    ? () => _replace(ref, context)
                    : null,
                child: const Text('Replace selection'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: Theme.of(context).colorScheme.surface,
          child: SelectableText(code),
        ),
      ],
    );
  }

  void _copy(BuildContext context) {
    // copy to clipboard
    // Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard (simulated)')));
  }

  void _insert(WidgetRef ref, BuildContext context) {
    ref
        .read(composerProvider.notifier)
        .insertCode(targetPath, code, line: startLine);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Inserted code (demo)')));
  }

  void _replace(WidgetRef ref, BuildContext context) {
    if (startLine != null && endLine != null) {
      ref
          .read(composerProvider.notifier)
          .replaceSelection(targetPath, startLine!, endLine!, code);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Replaced selection (demo)')));
    }
  }
}
