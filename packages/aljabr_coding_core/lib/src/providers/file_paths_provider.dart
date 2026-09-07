import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/file_node.dart';

final filePathsProvider = StateProvider<List<String>>((ref) => const <String>[]);

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
