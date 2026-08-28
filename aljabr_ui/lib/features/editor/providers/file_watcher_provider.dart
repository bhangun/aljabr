// providers/explorer_providers.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../project/providers/active_project_provider.dart';
import 'file_tree_provider.dart';

class FileWatcherNotifier extends StateNotifier<void> {
  final Ref ref;
  StreamSubscription? _subscription;

  FileWatcherNotifier(this.ref) : super(null) {
    final project = ref.read(activeProjectProvider);
    if (project != null && project.rootPath.isNotEmpty) {
      final dir = Directory(project.rootPath);
      if (dir.existsSync()) {
        _subscription = dir.watch(events: FileSystemEvent.all).listen((event) {
          ref.invalidate(fileTreeProvider);
        });
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// Add this provider to start watching when the app runs
final fileWatcherProvider = Provider<void>((ref) {
  final project = ref.watch(activeProjectProvider);
  if (project == null || project.rootPath.isEmpty) return;
  final dir = Directory(project.rootPath);
  if (!dir.existsSync()) return;

  final subscription = dir.watch(events: FileSystemEvent.all).listen((_) {
    ref.invalidate(fileTreeProvider);
  });
  ref.onDispose(subscription.cancel);
});
