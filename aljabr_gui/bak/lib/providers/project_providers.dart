import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../data/grpc_client.dart';
import '../src/generated/wayang.pb.dart' as grpc;

/// All known projects fetched from the Quarkus gRPC backend
class ProjectListNotifier extends StateNotifier<List<Project>> {
  ProjectListNotifier() : super(const []) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      final req = grpc.ListProjectsRequest(includeArchived: false);
      final res = await grpcClient.projectClient.listProjects(req);
      
      final loadedProjects = res.projects.map((p) => Project(
        id: p.id,
        name: p.name,
        rootPath: p.basePath,
        branch: 'main', // Hardcoded branch since it's not tracked yet
      )).toList();
      
      if (mounted) state = loadedProjects;
    } catch (e) {
      // In a real app we'd handle the error state here
      logInfo"Failed to load projects via gRPC: $e");
    }
  }
}

final projectListProvider =
    StateNotifierProvider<ProjectListNotifier, List<Project>>(
  (ref) => ProjectListNotifier(),
);

/// Id of the project currently focused in the sidebar/header switcher.
class ActiveProjectNotifier extends StateNotifier<String> {
  ActiveProjectNotifier() : super('wayang-platform');
  void select(String id) => state = id;
}

final activeProjectIdProvider =
    StateNotifierProvider<ActiveProjectNotifier, String>(
  (ref) => ActiveProjectNotifier(),
);

/// Convenience derived provider for the full [Project] object.
final activeProjectProvider = Provider<Project>((ref) {
  final id = ref.watch(activeProjectIdProvider);
  final projects = ref.watch(projectListProvider);
  return projects.firstWhere((p) => p.id == id, orElse: () => projects.first);
});
