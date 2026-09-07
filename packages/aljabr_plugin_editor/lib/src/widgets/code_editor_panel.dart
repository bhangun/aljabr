import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import '../providers/file_buffer_provider.dart';
import '../providers/open_file_provider.dart';
import 'file_tabs_bar.dart';

class CodeEditorPanel extends ConsumerStatefulWidget {
  const CodeEditorPanel({super.key});

  @override
  ConsumerState<CodeEditorPanel> createState() => _CodeEditorPanelState();
}

class _CodeEditorPanelState extends ConsumerState<CodeEditorPanel> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _loadedPath;
  int _cursorLine = 1;
  int _cursorCol = 1;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text;
    final selection = _textController.selection;

    if (selection.isValid) {
      final beforeCursor =
          text.substring(0, selection.baseOffset.clamp(0, text.length));
      final lines = beforeCursor.split('\n');
      final line = lines.length;
      final col = lines.last.length + 1;
      if (line != _cursorLine || col != _cursorCol) {
        _cursorLine = line;
        _cursorCol = col;
      }
    }

    final path = _loadedPath;
    if (path != null && path.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _loadedPath == path) {
          ref.read(fileBufferProvider.notifier).updateContent(path, text);
          setState(() {});
        }
      });
    }
  }

  void _saveCurrentFile() {
    if (_loadedPath != null && _loadedPath!.isNotEmpty) {
      ref.read(fileBufferProvider.notifier).saveFile(_loadedPath!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved ${_loadedPath!.split('/').last}'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePath = ref.watch(activeFileProvider);
    final openFiles = ref.watch(openFilesProvider);

    ref.listen<String>(activeFileProvider, (prev, next) {
      if (next.isNotEmpty && next != _loadedPath) {
        _loadedPath = next;
        final content =
            ref.read(fileBufferProvider.notifier).getFileContent(next);
        if (_textController.text != content) {
          _textController.text = content;
        }
        _cursorLine = 1;
        _cursorCol = 1;
      }
    });

    final buffers = ref.watch(fileBufferProvider);
    if (activePath != _loadedPath) {
      _loadedPath = activePath;
      final existing = buffers[activePath]?.content;
      if (existing != null && _textController.text != existing) {
        _textController.text = existing;
      }
    }

    if (activePath.isEmpty || openFiles.isEmpty) {
      return _buildEmptyState();
    }

    final buffer = buffers[activePath];
    final isDirty = buffer?.isDirty ?? false;

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyS):
            const _SaveIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
            const _SaveIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _SaveIntent: CallbackAction<_SaveIntent>(
            onInvoke: (_) => _saveCurrentFile(),
          ),
        },
        child: Container(
          color: AppTheme.panel,
          child: Column(
            children: [
              const FileTabsBar(),
              const Divider(height: 1, color: AppTheme.border),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Line numbers gutter
                    _buildLineNumbersGutter(),
                    const VerticalDivider(width: 1, color: AppTheme.border),
                    // Code editor textarea
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          maxLines: null,
                          expands: true,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            height: 1.45,
                            color: AppTheme.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppTheme.border),
              _buildStatusBar(activePath, isDirty),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineNumbersGutter() {
    final lineCount = '\n'.allMatches(_textController.text).length + 1;
    return Container(
      width: 48,
      color: AppTheme.surface.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: ListView.builder(
        itemCount: lineCount,
        itemBuilder: (context, index) {
          final lineNum = index + 1;
          final isCurrent = lineNum == _cursorLine;
          return Text(
            '$lineNum',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              height: 1.45,
              color: isCurrent
                  ? AppTheme.textPrimary
                  : AppTheme.textMuted.withValues(alpha: 0.5),
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBar(String path, bool isDirty) {
    return Container(
      height: 24,
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (isDirty)
            const Text(
              '● Modified',
              style: TextStyle(
                  color: Colors.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          const Spacer(),
          Text(
            'Ln $_cursorLine, Col $_cursorCol',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(width: 16),
          const Text(
            'Spaces: 2',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(width: 16),
          const Text(
            'UTF-8',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: _saveCurrentFile,
            child: const Text(
              'Save (⌘S)',
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: AppTheme.panel,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.code_rounded, size: 48, color: AppTheme.textMuted),
            SizedBox(height: 12),
            Text(
              'No File Open',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Select a file from the explorer on the left to edit',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}
