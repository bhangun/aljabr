import 'package:equatable/equatable.dart';

import '../chat/models/session.dart';

/// A workspace containing multiple sessions
class Workspace extends Equatable {
  const Workspace({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.sessions = const [],
    this.description,
    this.tags = const [],
    this.isPinned = false,
    this.icon,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Session> sessions;
  final String? description;
  final List<String> tags;
  final bool isPinned;
  final String? icon;

  int get sessionCount => sessions.length;

  Session? get lastActiveSession {
    if (sessions.isEmpty) return null;
    return sessions.reduce((a, b) => a.updatedAt.isAfter(b.updatedAt) ? a : b);
  }

  Workspace copyWith({
    String? name,
    DateTime? updatedAt,
    List<Session>? sessions,
    String? description,
    List<String>? tags,
    bool? isPinned,
    String? icon,
  }) {
    return Workspace(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      sessions: sessions ?? this.sessions,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      icon: icon ?? this.icon,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    createdAt,
    updatedAt,
    sessions.length,
    isPinned,
  ];
}

/// Workspace provider
class WorkspaceState {
  const WorkspaceState({
    this.workspaces = const [],
    this.currentWorkspaceId,
    this.isLoading = false,
    this.error,
  });

  final List<Workspace> workspaces;
  final String? currentWorkspaceId;
  final bool isLoading;
  final String? error;

  Workspace? get currentWorkspace {
    if (currentWorkspaceId == null) return null;
    try {
      return workspaces.firstWhere((w) => w.id == currentWorkspaceId);
    } catch (_) {
      return null;
    }
  }

  WorkspaceState copyWith({
    List<Workspace>? workspaces,
    String? currentWorkspaceId,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return WorkspaceState(
      workspaces: workspaces ?? this.workspaces,
      currentWorkspaceId: currentWorkspaceId ?? this.currentWorkspaceId,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
