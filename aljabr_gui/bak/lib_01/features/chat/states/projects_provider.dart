import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/utils/result.dart';
import '../../../presentation/providers/infrastructure_providers.dart';
import '../models/project.dart';

class ProjectsState {
  const ProjectsState({
    this.projects = const [],
    this.activeProjectId,
  });

  final List<Project> projects;
  final String? activeProjectId;

  Project? get activeProject {
    if (activeProjectId == null) return null;
    try {
      return projects.firstWhere((p) => p.id == activeProjectId);
    } catch (_) {
      return null;
    }
  }

  ProjectsState copyWith({
    List<Project>? projects,
    String? activeProjectId,
  }) => ProjectsState(
    projects: projects ?? this.projects,
    activeProjectId: activeProjectId ?? this.activeProjectId,
  );
}

class ProjectsNotifier extends StateNotifier<ProjectsState> {
  ProjectsNotifier(this._ref) : super(const ProjectsState()) {
    loadProjects();
  }

  final Ref _ref;

  Future<void> loadProjects() async {
    final result = await _ref.read(projectRepositoryProvider).getProjects();
    result.fold(
      onSuccess: (projects) {
        state = state.copyWith(projects: projects);
        if (state.activeProjectId == null) {
          if (projects.isNotEmpty) {
            setActiveProject(projects.first.id);
          } else {
            createProject(name: 'Default Project');
          }
        }
      },
      onFailure: (_) {},
    );
  }

  Future<Project> createProject({required String name, String? path}) async {
    final result = await _ref.read(projectRepositoryProvider).createProject(name: name, path: path);
    return result.fold(
      onSuccess: (p) {
        state = state.copyWith(
          projects: [p, ...state.projects],
          activeProjectId: p.id,
        );
        return p;
      },
      onFailure: (e) => throw Exception(e.message),
    );
  }

  Future<void> updateProject(Project project) async {
    await _ref.read(projectRepositoryProvider).updateProject(project);
    state = state.copyWith(
      projects: state.projects.map((p) => p.id == project.id ? project : p).toList(),
    );
  }

  Future<void> deleteProject(String id) async {
    await _ref.read(projectRepositoryProvider).deleteProject(id);
    final nextProjects = state.projects.where((p) => p.id != id).toList();
    state = state.copyWith(
      projects: nextProjects,
      activeProjectId: state.activeProjectId == id
          ? (nextProjects.isNotEmpty ? nextProjects.first.id : null)
          : state.activeProjectId,
    );
  }

  void setActiveProject(String id) {
    if (state.activeProjectId != id) {
      state = state.copyWith(activeProjectId: id);
    }
  }
}

final projectsProvider = StateNotifierProvider<ProjectsNotifier, ProjectsState>((ref) {
  return ProjectsNotifier(ref);
});

final activeProjectProvider = Provider<Project?>((ref) {
  return ref.watch(projectsProvider).activeProject;
});
