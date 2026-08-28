import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/project.dart';
import 'project_list_provider.dart';

class ActiveProjectNotifier extends StateNotifier<String?> {
  ActiveProjectNotifier() : super(null);
  void select(String id) => state = id;
  void setId(String? id) => state = id;
}

final activeProjectIdProvider =
    StateNotifierProvider<ActiveProjectNotifier, String?>(
  (ref) => ActiveProjectNotifier(),
);

/// Convenience derived provider for the full [Project] object.
final activeProjectProvider = Provider<Project?>((ref) {
  final id = ref.watch(activeProjectIdProvider);
  if (id == null) return null;
  final projects = ref.watch(projectListProvider);
  if (projects.isEmpty) return null;
  return projects.firstWhere((p) => p.id == id, orElse: () => projects.first);
});
