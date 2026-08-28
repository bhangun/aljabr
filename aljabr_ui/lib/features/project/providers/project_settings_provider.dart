// project_details_screen.dart
import 'package:flutter_riverpod/legacy.dart';

import '../models/project_settings.dart';
import '../models/security.dart';

final projectSettingsProvider =
    StateNotifierProvider<ProjectSettingsNotifier, ProjectSettings>((ref) {
  return ProjectSettingsNotifier();
});

class ProjectSettingsNotifier extends StateNotifier<ProjectSettings> {
  ProjectSettingsNotifier()
      : super(
          const ProjectSettings(
            projectName: 'wayang-platform',
            folders: ['wayang-platform/'],
            securityPreset: SecurityPreset.custom,
            outsideFoldersFileAccess: FileAccessPolicy.alwaysAsk,
            terminalCommandAutoExecution: TerminalExecutionPolicy.requireReview,
            enableSandboxMode: false,
            artifactReviewPolicy: ArtifactReviewPolicy.alwaysAsk,
            localPermissions: [],
          ),
        );

  void addFolder(String folderPath) {
    final newFolders = List<String>.from(state.folders)..add(folderPath);
    state = state.copyWith(folders: newFolders);
  }

  void removeFolder(String folderPath) {
    final newFolders = state.folders.where((f) => f != folderPath).toList();
    state = state.copyWith(folders: newFolders);
  }

  void updateSecurityPreset(SecurityPreset preset) {
    state = state.copyWith(securityPreset: preset);
  }

  void updateFileAccessPolicy(FileAccessPolicy policy) {
    state = state.copyWith(outsideFoldersFileAccess: policy);
  }

  void updateTerminalExecution(TerminalExecutionPolicy policy) {
    state = state.copyWith(terminalCommandAutoExecution: policy);
  }

  void updateSandboxMode(bool enabled) {
    state = state.copyWith(enableSandboxMode: enabled);
  }

  void updateArtifactReviewPolicy(ArtifactReviewPolicy policy) {
    state = state.copyWith(artifactReviewPolicy: policy);
  }

  void updateProjectName(String name) {
    state = state.copyWith(projectName: name);
  }
}
