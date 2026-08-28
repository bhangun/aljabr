

/// A key for a context value.
class ContextKey<T> {
  /// The ID of the context key.
  final String id;

  /// Creates a new [ContextKey] instance.
  const ContextKey(this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ContextKey<T> && id == other.id);

  @override
  int get hashCode => Object.hash(T, id);

  @override
  String toString() => 'ContextKey<$T>($id)';
}

/// Core context keys.
abstract final class CoreContextKeys {
  /// The ID of the workspace.
  static const workspaceId = ContextKey<String>('aljabr.workspace.id');
  /// The name of the workspace.
  static const workspaceName = ContextKey<String>('aljabr.workspace.name');
  /// The ID of the active view.
  static const activeViewId = ContextKey<String>('aljabr.workbench.activeViewId');
  /// The path of the active file.
  static const activeFilePath = ContextKey<String>('aljabr.editor.activeFilePath');
  /// The path of the file.
  static const filePath = ContextKey<String>('aljabr.file.path');
  /// The language of the editor.
  static const editorLanguage = ContextKey<String>('aljabr.editor.language');
  /// The language of the file.
  static const language = ContextKey<String>('aljabr.file.language');
  /// The text selected in the editor.
  static const selectionText = ContextKey<String>('aljabr.editor.selectionText');
  /// Whether there is text selected in the editor.
  static const hasSelection = ContextKey<bool>('aljabr.editor.hasSelection');
  /// Whether the chat is general.
  static const isGeneralChat = ContextKey<bool>('aljabr.chat.isGeneral');
  /// The branch of the git repository.
  static const gitBranch = ContextKey<String>('aljabr.git.branch');
}
