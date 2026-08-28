import '../models/composer_context.dart';

/// Lightweight service that suggests contexts based on editor/workspace state.
/// This is a stubbed implementation; integrate with editor providers for real data.
class ComposerContextService {
  List<ComposerContext> suggest(
      {EditorContext? editor, WorkspaceState? workspace}) {
    final result = <ComposerContext>[];

    if (editor?.selection != null) {
      final sel = editor!.selection!;
      result.add(ComposerContext(
        id: 'selection:${sel.filePath}:${sel.startLine}-${sel.endLine}',
        type: ComposerContextType.selection,
        label: sel.filePath,
        path: sel.filePath,
        startLine: sel.startLine,
        endLine: sel.endLine,
      ));
      return result;
    }

    if (editor != null) {
      result.add(ComposerContext(
        id: 'file:${editor.filePath}',
        type: ComposerContextType.file,
        label: editor.filePath.split('/').last,
        path: editor.filePath,
      ));
    }

    return result;
  }
}

// Minimal stubs so this file compiles in isolation. Replace with real editor/workspace models.
class EditorContext {
  final String filePath;
  final EditorSelection? selection;
  EditorContext(this.filePath, {this.selection});
}

class EditorSelection {
  final int startLine;
  final int endLine;
  final String filePath;
  EditorSelection(this.filePath, this.startLine, this.endLine);
}

class WorkspaceState {
  // add fields as needed
}
