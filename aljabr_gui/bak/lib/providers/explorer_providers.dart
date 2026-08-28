import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_node.dart';

/// Mock project tree for the active project. In a real app this would be
/// fetched from the workspace; kept static here since the demo has one
/// project's worth of files to browse.
final fileTreeProvider = Provider<FileNode>((ref) {
  return const FileNode.folder('wayang-platform', '', [
    FileNode.folder('src', 'src', [
      FileNode.folder('main', 'src/main', [
        FileNode.folder('java', 'src/main/java', [
          FileNode.folder('com', 'src/main/java/com', [
            FileNode.folder('wayang', 'src/main/java/com/wayang', [
              FileNode.file('SessionResource.java',
                  'src/main/java/com/wayang/SessionResource.java'),
              FileNode.file(
                  'GollekService.java', 'src/main/java/com/wayang/GollekService.java'),
            ]),
          ]),
        ]),
        FileNode.folder('resources', 'src/main/resources', [
          FileNode.file(
            'application.properties',
            'src/main/resources/application.properties',
            hasChanges: true,
          ),
          FileNode.folder('db', 'src/main/resources/db', [
            FileNode.folder('migration', 'src/main/resources/db/migration', [
              FileNode.file(
                'V1__init.sql',
                'src/main/resources/db/migration/V1__init.sql',
              ),
              FileNode.file(
                'V2__add_index.sql',
                'src/main/resources/db/migration/V2__add_index.sql',
                hasChanges: true,
              ),
            ]),
          ]),
        ]),
      ]),
      FileNode.folder('test', 'src/test', [
        FileNode.file(
            'SessionResourceTest.java', 'src/test/SessionResourceTest.java'),
      ]),
    ]),
    FileNode.file('docker-compose.yml', 'docker-compose.yml', hasChanges: true),
    FileNode.file('pom.xml', 'pom.xml'),
    FileNode.file('README.md', 'README.md'),
  ]);
});

/// Which folder paths are expanded in the tree.
class ExpandedFoldersNotifier extends StateNotifier<Set<String>> {
  ExpandedFoldersNotifier()
      : super({
          'src',
          'src/main',
          'src/main/resources',
        });

  void toggle(String path) {
    final next = {...state};
    if (!next.add(path)) next.remove(path);
    state = next;
  }
}

final expandedFoldersProvider =
    StateNotifierProvider<ExpandedFoldersNotifier, Set<String>>(
  (ref) => ExpandedFoldersNotifier(),
);

/// Whether the explorer column is shown next to the editor tab content.
class ExplorerVisibleNotifier extends StateNotifier<bool> {
  ExplorerVisibleNotifier() : super(true);
  void toggle() => state = !state;
}

final explorerVisibleProvider =
    StateNotifierProvider<ExplorerVisibleNotifier, bool>(
  (ref) => ExplorerVisibleNotifier(),
);

/// Flattens a [FileNode] tree into a list of file paths (directories
/// excluded) — used to power `@file` autocomplete in the composer.
List<String> flattenFilePaths(FileNode node) {
  final result = <String>[];
  for (final child in node.children) {
    if (child.isDirectory) {
      result.addAll(flattenFilePaths(child));
    } else {
      result.add(child.path);
    }
  }
  return result;
}

final filePathsProvider = Provider<List<String>>((ref) {
  return flattenFilePaths(ref.watch(fileTreeProvider));
});
