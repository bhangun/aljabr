class WorkspaceInfo {
  final String id;
  final String name;
  final String path;
  final String branch;
  final bool isGit;

  const WorkspaceInfo({
    required this.id,
    required this.name,
    required this.path,
    this.branch = 'main',
    this.isGit = true,
  });

  WorkspaceInfo copyWith({
    String? id,
    String? name,
    String? path,
    String? branch,
    bool? isGit,
  }) {
    return WorkspaceInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      branch: branch ?? this.branch,
      isGit: isGit ?? this.isGit,
    );
  }
}

class FileNode {
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime? modifiedAt;
  final List<FileNode> children;

  const FileNode({
    required this.name,
    required this.path,
    this.isDirectory = false,
    this.size = 0,
    this.modifiedAt,
    this.children = const [],
  });

  String get extension => name.contains('.') ? name.split('.').last.toLowerCase() : '';
}
