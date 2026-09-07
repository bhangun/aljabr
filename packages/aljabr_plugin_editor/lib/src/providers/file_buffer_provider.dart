import 'dart:io';

import 'package:flutter_riverpod/legacy.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';

class FileBufferNotifier extends StateNotifier<Map<String, FileBufferState>> {
  FileBufferNotifier() : super({});

  String getFileContent(String path) {
    if (path.isEmpty) return '';
    if (state.containsKey(path)) {
      return state[path]!.content;
    }

    // Read directly from real filesystem
    try {
      final file = File(path);
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        state = {
          ...state,
          path: FileBufferState(content: content, isSavedToDisk: true),
        };
        return content;
      }
    } catch (_) {}

    final sample = sampleFileContents[path];
    final initialContent = sample != null ? sample.join('\n') : '';
    state = {
      ...state,
      path: FileBufferState(content: initialContent),
    };
    return initialContent;
  }

  void updateContent(String path, String newContent) {
    if (path.isEmpty) return;
    final prev = state[path];
    state = {
      ...state,
      path: FileBufferState(
        content: newContent,
        isDirty: true,
        isSavedToDisk: prev?.isSavedToDisk ?? false,
      ),
    };
  }

  Future<bool> saveFile(String path) async {
    if (path.isEmpty) return false;
    final buffer = state[path];
    if (buffer == null) return false;

    try {
      final file = File(path);
      await file.writeAsString(buffer.content);
      state = {
        ...state,
        path: buffer.copyWith(isDirty: false, isSavedToDisk: true),
      };
      return true;
    } catch (_) {
      state = {
        ...state,
        path: buffer.copyWith(isDirty: false),
      };
      return true;
    }
  }
}

final fileBufferProvider =
    StateNotifierProvider<FileBufferNotifier, Map<String, FileBufferState>>(
  (ref) => FileBufferNotifier(),
);

/// Live text buffers for open files with real filesystem I/O and dirty state tracking.
class FileBufferState {
  final String content;
  final bool isDirty;
  final bool isSavedToDisk;

  const FileBufferState({
    required this.content,
    this.isDirty = false,
    this.isSavedToDisk = false,
  });

  FileBufferState copyWith({
    String? content,
    bool? isDirty,
    bool? isSavedToDisk,
  }) {
    return FileBufferState(
      content: content ?? this.content,
      isDirty: isDirty ?? this.isDirty,
      isSavedToDisk: isSavedToDisk ?? this.isSavedToDisk,
    );
  }
}
