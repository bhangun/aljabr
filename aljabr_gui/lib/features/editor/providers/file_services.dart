import 'dart:io';

import '../../chat/models/file_node.dart';

const ignoredDirectories = {
  '.git',
  '.dart_tool',
  'node_modules',
  'target',
  '.idea',
  '.vscode',
  'build',
  '.gradle',
  '.gemini',
  '.m2',
  '__pycache__',
};

Future<FileNode> scanDirectoryAsync(Directory dir, int maxDepth) async {
  final name = dir.path.split(Platform.pathSeparator).last;
  if (maxDepth <= 0) {
    return FileNode.folder(name, dir.path, const []);
  }

  final children = <FileNode>[];
  try {
    final entities = await dir.list(followLinks: false).toList();
    final dirs = <Directory>[];
    final files = <File>[];

    for (final entity in entities) {
      final baseName = entity.path.split(Platform.pathSeparator).last;
      if (baseName.startsWith('.') &&
          baseName != '.env' &&
          baseName != '.gitignore') {
        continue;
      }
      if (ignoredDirectories.contains(baseName)) continue;
      if (entity is Directory) {
        dirs.add(entity);
      } else if (entity is File) {
        files.add(entity);
      }
    }

    dirs.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    // Scan subdirectories concurrently (still async, yields control)
    final futureChildren = <Future<FileNode>>[];
    for (final d in dirs.take(50)) {
      futureChildren.add(scanDirectoryAsync(d, maxDepth - 1));
    }
    children.addAll(await Future.wait(futureChildren));

    // Add files (limit to 100 per folder to keep it snappy)
    for (final f in files.take(100)) {
      final fName = f.path.split(Platform.pathSeparator).last;
      children.add(FileNode.file(fName, f.path));
    }
  } catch (_) {}
  return FileNode.folder(name, dir.path, children);
}

FileNode scanDirectory(Directory dir, int currentDepth, int maxDepth) {
  final name = dir.path.split(Platform.pathSeparator).last;
  if (currentDepth >= maxDepth) {
    return FileNode.folder(name, dir.path, const []);
  }

  final children = <FileNode>[];
  try {
    final entities = dir.listSync(followLinks: false);
    final dirs = <Directory>[];
    final files = <File>[];

    for (final entity in entities) {
      final baseName = entity.path.split(Platform.pathSeparator).last;
      if (baseName.startsWith('.') &&
          baseName != '.env' &&
          baseName != '.gitignore') {
        continue;
      }
      if (ignoredDirectories.contains(baseName)) {
        continue;
      }

      if (entity is Directory) {
        dirs.add(entity);
      } else if (entity is File) {
        files.add(entity);
      }
    }

    dirs.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    // Cap at 100 entries per level to stay snappy
    for (final d in dirs.take(50)) {
      children.add(scanDirectory(d, currentDepth + 1, maxDepth));
    }
    for (final f in files.take(100)) {
      final fName = f.path.split(Platform.pathSeparator).last;
      children.add(FileNode.file(fName, f.path));
    }
  } catch (_) {}

  return FileNode.folder(name, dir.path, children);
}
