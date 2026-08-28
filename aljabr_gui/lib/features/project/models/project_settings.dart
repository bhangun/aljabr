import 'security.dart';

class ProjectSettings {
  final String projectName;
  final List<String> folders;
  final SecurityPreset securityPreset;
  final FileAccessPolicy outsideFoldersFileAccess;
  final TerminalExecutionPolicy terminalCommandAutoExecution;
  final bool enableSandboxMode;
  final ArtifactReviewPolicy artifactReviewPolicy;
  final List<LocalPermission> localPermissions;

  const ProjectSettings({
    required this.projectName,
    required this.folders,
    required this.securityPreset,
    required this.outsideFoldersFileAccess,
    required this.terminalCommandAutoExecution,
    required this.enableSandboxMode,
    required this.artifactReviewPolicy,
    required this.localPermissions,
  });

  ProjectSettings copyWith({
    String? projectName,
    List<String>? folders,
    SecurityPreset? securityPreset,
    FileAccessPolicy? outsideFoldersFileAccess,
    TerminalExecutionPolicy? terminalCommandAutoExecution,
    bool? enableSandboxMode,
    ArtifactReviewPolicy? artifactReviewPolicy,
    List<LocalPermission>? localPermissions,
  }) {
    return ProjectSettings(
      projectName: projectName ?? this.projectName,
      folders: folders ?? this.folders,
      securityPreset: securityPreset ?? this.securityPreset,
      outsideFoldersFileAccess:
          outsideFoldersFileAccess ?? this.outsideFoldersFileAccess,
      terminalCommandAutoExecution:
          terminalCommandAutoExecution ?? this.terminalCommandAutoExecution,
      enableSandboxMode: enableSandboxMode ?? this.enableSandboxMode,
      artifactReviewPolicy: artifactReviewPolicy ?? this.artifactReviewPolicy,
      localPermissions: localPermissions ?? this.localPermissions,
    );
  }
}
