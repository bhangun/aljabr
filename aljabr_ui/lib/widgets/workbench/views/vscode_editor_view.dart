import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import 'package:aljabr_plugin_editor/aljabr_plugin_editor.dart';
import '../../../providers/module_manager_provider.dart';
import '../../../theme/app_colors.dart';

class VsCodeEditorView extends ConsumerStatefulWidget {
  const VsCodeEditorView({super.key});

  @override
  ConsumerState<VsCodeEditorView> createState() => _VsCodeEditorViewState();
}

class _VsCodeEditorViewState extends ConsumerState<VsCodeEditorView> {
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
        setState(() {
          _cursorLine = line;
          _cursorCol = col;
        });
      }
    }

    final path = _loadedPath;
    if (path != null && path.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _loadedPath == path) {
          ref.read(fileBufferProvider.notifier).updateContent(path, text);
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
    final workbench = ref.watch(workbenchControllerProvider);

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

    return Container(
      color: AppTheme.panel,
      child: Column(
        children: [
          // VS Code Tab Bar & Split Actions
          Container(
            height: 38,
            color: AppTheme.surface,
            child: Row(
              children: [
                const Expanded(child: FileTabsBar()),
                // Right editor action toolbar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Split Editor Right (⌘\\)',
                        icon: const Icon(Icons.vertical_split_outlined,
                            size: 16, color: AppTheme.textSecondary),
                        splashRadius: 14,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: () {
                          workbench.splitView(
                            'aljabr.editor.main',
                            direction: SplitDirection.horizontal,
                            placement: SplitPlacement.after,
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'Split Editor Down',
                        icon: const Icon(Icons.horizontal_split_outlined,
                            size: 16, color: AppTheme.textSecondary),
                        splashRadius: 14,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: () {
                          workbench.splitView(
                            'aljabr.editor.main',
                            direction: SplitDirection.vertical,
                            placement: SplitPlacement.after,
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'Save File (⌘S)',
                        icon: Icon(
                          isDirty ? Icons.circle : Icons.save_outlined,
                          size: isDirty ? 10 : 16,
                          color: isDirty ? AppTheme.accentAmber : AppTheme.textSecondary,
                        ),
                        splashRadius: 14,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: _saveCurrentFile,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // VS Code Breadcrumbs Bar
          _buildBreadcrumbsBar(activePath),
          const Divider(height: 1, color: AppTheme.border),

          // Editor Body: Line numbers + Code area + Minimap preview
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLineNumbersGutter(),
                const VerticalDivider(width: 1, color: AppTheme.border),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                // Minimap simulation bar
                _buildMinimapPreview(),
              ],
            ),
          ),

          const Divider(height: 1, color: AppTheme.border),
          _buildEditorStatusBar(activePath, isDirty),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbsBar(String path) {
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: AppTheme.panelAlt.withValues(alpha: 0.6),
      child: Row(
        children: [
          for (int i = 0; i < segments.length; i++) ...[
            if (i > 0) ...[
              const Icon(Icons.chevron_right, size: 13, color: AppTheme.textMuted),
              const SizedBox(width: 2),
            ],
            Text(
              segments[i],
              style: TextStyle(
                fontSize: 11,
                color: i == segments.length - 1
                    ? AppTheme.textPrimary
                    : AppTheme.textMuted,
                fontWeight: i == segments.length - 1
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 2),
          ],
        ],
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

  Widget _buildMinimapPreview() {
    return Container(
      width: 44,
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.2),
        border: const Border(left: BorderSide(color: AppTheme.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          16,
          (i) => Container(
            height: 3,
            margin: const EdgeInsets.only(bottom: 4),
            width: (i % 3 == 0) ? 32 : (i % 2 == 0) ? 24 : 16,
            color: AppTheme.textMuted.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }

  Widget _buildEditorStatusBar(String path, bool isDirty) {
    return Container(
      height: 22,
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          if (isDirty)
            const Text(
              '● Modified',
              style: TextStyle(
                color: AppTheme.accentAmber,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          const Spacer(),
          Text(
            'Ln $_cursorLine, Col $_cursorCol',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(width: 14),
          const Text(
            'Spaces: 2',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(width: 14),
          const Text(
            'UTF-8',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(width: 14),
          Text(
            _languageModeFor(path),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _languageModeFor(String path) {
    if (path.endsWith('.dart')) return 'Dart';
    if (path.endsWith('.json')) return 'JSON';
    if (path.endsWith('.yaml') || path.endsWith('.yml')) return 'YAML';
    if (path.endsWith('.md')) return 'Markdown';
    if (path.endsWith('.ts') || path.endsWith('.js')) return 'TypeScript';
    if (path.endsWith('.py')) return 'Python';
    if (path.endsWith('.rs')) return 'Rust';
    if (path.endsWith('.go')) return 'Go';
    if (path.endsWith('.html')) return 'HTML';
    if (path.endsWith('.css')) return 'CSS';
    return 'Plain Text';
  }

  Widget _buildEmptyState() {
    return Container(
      color: AppTheme.panel,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.code_rounded, size: 54, color: AppTheme.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 14),
            const Text(
              'Aljabr IDE — No Open Editor',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select a file from the explorer (⌘E) or press ⌘P to open files',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}
