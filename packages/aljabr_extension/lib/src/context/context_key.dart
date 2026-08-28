class ContextKey<T> {
  final String id;

  const ContextKey(this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ContextKey && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ContextKey($id)';
}

abstract final class CoreContextKeys {
  static const filePath = ContextKey<String>('aljabr.file.path');
  static const workspaceName = ContextKey<String>('aljabr.workspace.name');
  static const selectionText = ContextKey<String>('aljabr.editor.selectionText');
  static const language = ContextKey<String>('aljabr.file.language');
  static const isGeneralChat = ContextKey<bool>('aljabr.chat.isGeneral');
  static const gitBranch = ContextKey<String>('aljabr.git.branch');
}
