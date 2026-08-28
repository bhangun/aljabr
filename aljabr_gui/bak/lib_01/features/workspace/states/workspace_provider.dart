import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../coding_agent.dart';
import '../../chat/models/session.dart';
import '../../../core/utils/extensions.dart';
import '../workspace.dart';

class WorkspaceNotifier extends StateNotifier<WorkspaceState> {
  WorkspaceNotifier(this._ref) : super(const WorkspaceState()) {
    _loadWorkspaces();
  }

  final Ref _ref;

  Future<void> _loadWorkspaces() async {
    final storage = _ref.read(localStorageDatasourceProvider);
    final result = storage.loadWorkspaces();

    result.fold(
      onSuccess: (workspaces) {
        state = state.copyWith(workspaces: workspaces);
        if (workspaces.isNotEmpty && state.currentWorkspaceId == null) {
          state = state.copyWith(currentWorkspaceId: workspaces.first.id);
        }
      },
      onFailure: (_) {},
    );
  }

  Future<void> createWorkspace({
    required String name,
    String? description,
    String? icon,
  }) async {
    final workspace = Workspace(
      id: generateId(),
      name: name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: description,
      icon: icon,
    );

    final storage = _ref.read(localStorageDatasourceProvider);
    final result = await storage.saveWorkspace(workspace);

    result.fold(
      onSuccess: (_) {
        state = state.copyWith(
          workspaces: [...state.workspaces, workspace],
          currentWorkspaceId: workspace.id,
        );
      },
      onFailure: (_) {},
    );
  }

  Future<void> updateWorkspace(Workspace workspace) async {
    final storage = _ref.read(localStorageDatasourceProvider);
    final result = await storage.saveWorkspace(workspace);

    result.fold(
      onSuccess: (_) {
        state = state.copyWith(
          workspaces: state.workspaces
              .map((w) => w.id == workspace.id ? workspace : w)
              .toList(),
        );
      },
      onFailure: (_) {},
    );
  }

  Future<void> deleteWorkspace(String id) async {
    final storage = _ref.read(localStorageDatasourceProvider);
    final result = await storage.deleteWorkspace(id);

    result.fold(
      onSuccess: (_) {
        state = state.copyWith(
          workspaces: state.workspaces.where((w) => w.id != id).toList(),
          currentWorkspaceId: state.currentWorkspaceId == id
              ? (state.workspaces.isNotEmpty ? state.workspaces.first.id : null)
              : state.currentWorkspaceId,
        );
      },
      onFailure: (_) {},
    );
  }

  void switchWorkspace(String id) {
    if (state.workspaces.any((w) => w.id == id)) {
      state = state.copyWith(currentWorkspaceId: id);
    }
  }

  void addSessionToWorkspace(String workspaceId, Session session) {
    final workspace = state.workspaces.firstWhere((w) => w.id == workspaceId);
    final updated = workspace.copyWith(
      sessions: [...workspace.sessions, session],
    );
    updateWorkspace(updated);
  }

  void removeSessionFromWorkspace(String workspaceId, String sessionId) {
    final workspace = state.workspaces.firstWhere((w) => w.id == workspaceId);
    final updated = workspace.copyWith(
      sessions: workspace.sessions.where((s) => s.id != sessionId).toList(),
    );
    updateWorkspace(updated);
  }
}

final workspaceProvider =
    StateNotifierProvider<WorkspaceNotifier, WorkspaceState>((ref) {
      return WorkspaceNotifier(ref);
    });
