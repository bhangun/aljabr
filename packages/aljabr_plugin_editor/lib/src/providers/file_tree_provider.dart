import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import 'file_services.dart';

final fileTreeProvider = FutureProvider<FileNode>((ref) async {
  final project = ref.watch(activeProjectProvider);
  if (project == null || project.rootPath.isEmpty) {
    return const FileNode.folder('No Project Open', '', []);
  }
  final dir = Directory(project.rootPath);
  if (!dir.existsSync()) {
    return FileNode.folder(project.name, project.rootPath, const []);
  }
  return await scanDirectoryAsync(dir, 4);
});
