import 'package:flutter_riverpod/legacy.dart';

class ActiveFileNotifier extends StateNotifier<String> {
  ActiveFileNotifier() : super('');
  void select(String path) => state = path;
}

final activeFileProvider = StateNotifierProvider<ActiveFileNotifier, String>(
  (ref) => ActiveFileNotifier(),
);
