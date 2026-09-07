// agent_settings_screen.dart
import 'package:flutter_riverpod/legacy.dart';

import '../models/agent_settings.dart';
import '../models/security.dart';

final agentSettingsProvider =
    StateNotifierProvider<AgentSettingsNotifier, AgentSettings>((ref) {
  return AgentSettingsNotifier();
});

class AgentSettingsNotifier extends StateNotifier<AgentSettings> {
  AgentSettingsNotifier()
      : super(
          const AgentSettings(
            securityPreset: SecurityPreset.custom,
            outsideFoldersFileAccess: FileAccessPolicy.alwaysAsk,
            terminalCommandAutoExecution: TerminalExecutionPolicy.requireReview,
            enableSandboxMode: false,
            artifactReviewPolicy: ArtifactReviewPolicy.alwaysAsk,
          ),
        );

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
}

// ============ MODELS ============

// ============ MAIN WIDGET ============

// ============ SECURITY PRESET SECTION ============

// ============ OUTSIDE FOLDERS SECTION ============

// ============ TERMINAL EXECUTION SECTION ============

// ============ FILE ACCESS RULES SECTION ============

// ============ NETWORK ACCESS RULES SECTION ============

// ============ PROVIDE FEEDBACK BUTTON ============

// ============ HELPER WIDGETS ============
