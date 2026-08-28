class FileOpenedEvent {
  final String path;
  final String? language;

  const FileOpenedEvent({required this.path, this.language});
}

class WorkspaceChangedEvent {
  final String workspacePath;
  final String workspaceName;

  const WorkspaceChangedEvent({
    required this.workspacePath,
    required this.workspaceName,
  });
}

class AgentSessionCreatedEvent {
  final String sessionId;
  final String? title;

  const AgentSessionCreatedEvent({
    required this.sessionId,
    this.title,
  });
}

class BackendStatusChangedEvent {
  final String serverName;
  final String status;
  final int? port;

  const BackendStatusChangedEvent({
    required this.serverName,
    required this.status,
    this.port,
  });
}
