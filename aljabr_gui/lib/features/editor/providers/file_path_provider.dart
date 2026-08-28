import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../chat/models/file_node.dart';
import 'file_tree_provider.dart';

// providers/explorer_providers.dart

final filePathsProvider = Provider<List<String>>((ref) {
  final asyncTree = ref.watch(fileTreeProvider);
  // While loading or error, return an empty list (autocomplete gracefully degrades)
  return asyncTree.when(
    data: (tree) => flattenFilePaths(tree),
    loading: () => const <String>[],
    error: (_, __) => const <String>[],
  );
});

/// Flattens a [FileNode] tree into a list of file paths (directories excluded)
/// — used to power `@file` autocomplete in the composer.
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
