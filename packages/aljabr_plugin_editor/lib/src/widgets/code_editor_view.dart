import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:highlight/languages/all.dart' show allLanguages;
import 'package:highlight/highlight.dart' as hl;
import '../providers/file_buffer_provider.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';

/// A syntax-highlighted code editor with line numbers, undo/redo, and find/replace.
class CodeEditorView extends ConsumerStatefulWidget {
  const CodeEditorView({super.key});

  @override
  ConsumerState<CodeEditorView> createState() => CodeEditorViewState();
}

class CodeEditorViewState extends ConsumerState<CodeEditorView> {
  late CodeController _controller;
  final FocusNode _focusNode = FocusNode();
  String? _loadedPath;
  bool _showFindBar = false;
  final TextEditingController _findController = TextEditingController();
  final TextEditingController _replaceController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isProgrammaticChange = false;

  // --- Public methods for parent widget ---
  void saveCurrentFile() async {
    if (_loadedPath != null) {
      final success =
          await ref.read(fileBufferProvider.notifier).saveFile(_loadedPath!);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved ${_loadedPath!.split('/').last}'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void toggleFindBar() {
    setState(() {
      _showFindBar = !_showFindBar;
      if (!_showFindBar) {
        _findController.clear();
        _replaceController.clear();
      }
    });
  }

  void undo() => _controller.historyController.undo();
  void redo() => _controller.historyController.redo();
  // -----------------------------------------

  @override
  void initState() {
    super.initState();
    _controller = CodeController(
      text: '',
      language: null,
    );
    _controller.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onContentChanged);
    _controller.dispose();
    _focusNode.dispose();
    _findController.dispose();
    _replaceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    if (_isProgrammaticChange) return;
    final activePath = ref.read(activeFileProvider);
    if (_loadedPath == activePath) {
      ref
          .read(fileBufferProvider.notifier)
          .updateContent(activePath, _controller.text);
    }
  }

  void _loadContent(String path, String content) {
    _isProgrammaticChange = true;
    final language = _getHighlightLanguage(path);
    _loadedPath = path;
    _controller.text = content;
    _controller.language = language;
    _controller.selection = const TextSelection.collapsed(offset: 0);
    _isProgrammaticChange = false;
  }

  hl.Mode? _getHighlightLanguage(String path) {
    final langName = languageForPath(path);
    final modeMap = {
      'dart': 'dart',
      'javascript': 'javascript',
      'typescript': 'typescript',
      'java': 'java',
      'python': 'python',
      'go': 'go',
      'rust': 'rust',
      'kotlin': 'kotlin',
      'c': 'c',
      'cpp': 'cpp',
      'csharp': 'csharp',
      'html': 'html',
      'css': 'css',
      'xml': 'xml',
      'json': 'json',
      'yaml': 'yaml',
      'sql': 'sql',
      'shell': 'shell',
      'markdown': 'markdown',
      'text': 'plaintext',
    };
    final modeKey = modeMap[langName] ?? 'plaintext';
    try {
      return allLanguages[modeKey];
    } catch (_) {
      return null;
    }
  }

  void _performFind(String query) {
    setState(() {});
  }

  void _performReplaceAll(String find, String replace) {
    if (find.isEmpty) return;
    final updated = _controller.text.replaceAll(
      RegExp(RegExp.escape(find), caseSensitive: false),
      replace,
    );
    if (updated != _controller.text) {
      _controller.value = _controller.value.copyWith(
        text: updated,
        selection: TextSelection.collapsed(offset: updated.length),
        composing: TextRange.empty,
      );
    }
  }

  void _performReplaceNext(String find, String replace) {
    if (find.isEmpty) return;
    final match = RegExp(RegExp.escape(find), caseSensitive: false)
        .firstMatch(_controller.text);
    if (match == null) return;
    final updated = _controller.text.replaceRange(
      match.start,
      match.end,
      replace,
    );
    _controller.value = _controller.value.copyWith(
      text: updated,
      selection: TextSelection.collapsed(
        offset: match.start + replace.length,
      ),
      composing: TextRange.empty,
    );
  }

  int _findCount(String query) {
    if (query.isEmpty) return 0;
    return RegExp(RegExp.escape(query), caseSensitive: false)
        .allMatches(_controller.text)
        .length;
  }

  int _getCursorLine() {
    final text = _controller.text;
    final offset = _controller.selection.baseOffset;
    if (offset < 0 || offset > text.length) return 1;
    return text.substring(0, offset).split('\n').length;
  }

  int _getCursorColumn() {
    final text = _controller.text;
    final offset = _controller.selection.baseOffset;
    if (offset < 0 || offset > text.length) return 1;
    final lines = text.substring(0, offset).split('\n');
    return lines.isEmpty ? 1 : lines.last.length + 1;
  }

  /// Theme styles for the code editor (dark GitHub-like theme)
  Map<String, TextStyle> _getThemeStyles() {
    return {
      'root': const TextStyle(
          color: Color(0xFFE6EDF3), backgroundColor: Color(0xFF0D1117)),
      'comment': const TextStyle(
          color: Color(0xFF8B949E), fontStyle: FontStyle.italic),
      'string': const TextStyle(color: Color(0xFFA5D6FF)),
      'number': const TextStyle(color: Color(0xFF79C0FF)),
      'keyword': const TextStyle(color: Color(0xFFFF7B72)),
      'built_in': const TextStyle(color: Color(0xFF79C0FF)),
      'function': const TextStyle(color: Color(0xFFD2A8FF)),
      'title': const TextStyle(color: Color(0xFFD2A8FF)),
      'params': const TextStyle(color: Color(0xFFE6EDF3)),
      'class': const TextStyle(color: Color(0xFFD2A8FF)),
      'symbol': const TextStyle(color: Color(0xFF79C0FF)),
      'literal': const TextStyle(color: Color(0xFF79C0FF)),
      'meta': const TextStyle(color: Color(0xFF8B949E)),
      'tag': const TextStyle(color: Color(0xFFFF7B72)),
      'attribute': const TextStyle(color: Color(0xFFA5D6FF)),
      'operator': const TextStyle(color: Color(0xFFFF7B72)),
      'regexp': const TextStyle(color: Color(0xFFA5D6FF)),
      'variable': const TextStyle(color: Color(0xFFFFA657)),
    };
  }

  @override
  Widget build(BuildContext context) {
    final activePath = ref.watch(activeFileProvider);
    final bufferMap = ref.watch(fileBufferProvider);
    final currentBuffer = bufferMap[activePath];
    final isDirty = currentBuffer?.isDirty ?? false;

    if (_loadedPath != activePath) {
      final content = activePath.isNotEmpty
          ? ref.read(fileBufferProvider.notifier).getFileContent(activePath)
          : '';
      _loadContent(activePath, content);
    }

    if (activePath.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.code_outlined, size: 40, color: Color(0xFF8B949E)),
            SizedBox(height: 12),
            Text(
              'No File Open',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE6EDF3),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Select a file from the explorer on the left to edit',
              style: TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Find/Replace Bar
        if (_showFindBar)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF161B22),
              border: Border(bottom: BorderSide(color: Color(0xFF30363D))),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.search,
                        size: 16, color: Color(0xFF8B949E)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _findController,
                        autofocus: true,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFFE6EDF3)),
                        decoration: const InputDecoration(
                          hintText: 'Find...',
                          hintStyle:
                              TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (query) => _performFind(query),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.find_replace,
                        size: 16, color: Color(0xFF8B949E)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _replaceController,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFFE6EDF3)),
                        decoration: const InputDecoration(
                          hintText: 'Replace...',
                          hintStyle:
                              TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close,
                          size: 14, color: Color(0xFF8B949E)),
                      onPressed: toggleFindBar,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (_findController.text.isNotEmpty)
                      Text(
                        '${_findCount(_findController.text)} matches',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF8B949E)),
                      ),
                    const Spacer(),
                    if (_findController.text.isNotEmpty) ...[
                      TextButton(
                        onPressed: () => _performReplaceNext(
                          _findController.text,
                          _replaceController.text,
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          backgroundColor: const Color(0xFF238636),
                          foregroundColor: Colors.white,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Replace',
                            style: TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () => _performReplaceAll(
                          _findController.text,
                          _replaceController.text,
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          backgroundColor: const Color(0xFF238636),
                          foregroundColor: Colors.white,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Replace All',
                            style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

        // Editor with CodeController
        Expanded(
          child: Container(
            color: const Color(0xFF0D1117),
            child: CodeTheme(
              data: CodeThemeData(
                styles: _getThemeStyles(),
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: CodeField(
                  controller: _controller,
                  focusNode: _focusNode,
                  background: const Color(0xFF0D1117),
                  gutterStyle: const GutterStyle(
                    width: 48,
                    background: Color(0xFF0D1117),
                    textStyle: TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                  minLines: null,
                  maxLines: null,
                  expands: true,
                ),
              ),
            ),
          ),
        ),

        // Status Bar
        Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF161B22),
            border: Border(top: BorderSide(color: Color(0xFF30363D))),
          ),
          child: Row(
            children: [
              if (isDirty) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.orange),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Modified',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                'Ln ${_getCursorLine()}, Col ${_getCursorColumn()}',
                style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Color(0xFF8B949E)),
              ),
              const Spacer(),
              Text(
                languageForPath(activePath).toUpperCase(),
                style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B949E)),
              ),
              const SizedBox(width: 12),
              const Text(
                'UTF-8',
                style: TextStyle(fontSize: 10.5, color: Color(0xFF8B949E)),
              ),
              const SizedBox(width: 12),
              const Text(
                'Spaces: 2',
                style: TextStyle(fontSize: 10.5, color: Color(0xFF8B949E)),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: saveCurrentFile,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDirty
                        ? const Color(0xFF238636).withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isDirty
                          ? const Color(0xFF238636).withValues(alpha: 0.4)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    'Save (⌘S)',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isDirty
                          ? const Color(0xFF238636)
                          : const Color(0xFF8B949E),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
