/// One node in the project file tree — either a directory with children
/// or a leaf file. Paths are `/`-joined relative to the project root and
/// double as the key used by [sampleFileContents] / open-file tabs.
class FileNode {
  final String name;
  final String path;
  final bool isDirectory;
  final List<FileNode> children;
  final bool hasChanges; // true if the diff panel has pending hunks for it

  const FileNode.folder(this.name, this.path, this.children)
      : isDirectory = true,
        hasChanges = false;

  const FileNode.file(this.name, this.path, {this.hasChanges = false})
      : isDirectory = false,
        children = const [];
}
