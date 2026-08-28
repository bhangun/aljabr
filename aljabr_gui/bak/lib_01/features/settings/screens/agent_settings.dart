// agent_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============ PROVIDERS ============
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
enum SecurityPreset { custom, standard, strict }

enum FileAccessPolicy { alwaysAsk, allowAll, denyAll, allowList }

enum TerminalExecutionPolicy { requireReview, autoApprove, autoDeny }

enum ArtifactReviewPolicy { alwaysAsk, autoApprove, autoDeny }

class AgentSettings {
  final SecurityPreset securityPreset;
  final FileAccessPolicy outsideFoldersFileAccess;
  final TerminalExecutionPolicy terminalCommandAutoExecution;
  final bool enableSandboxMode;
  final ArtifactReviewPolicy artifactReviewPolicy;

  const AgentSettings({
    required this.securityPreset,
    required this.outsideFoldersFileAccess,
    required this.terminalCommandAutoExecution,
    required this.enableSandboxMode,
    required this.artifactReviewPolicy,
  });

  AgentSettings copyWith({
    SecurityPreset? securityPreset,
    FileAccessPolicy? outsideFoldersFileAccess,
    TerminalExecutionPolicy? terminalCommandAutoExecution,
    bool? enableSandboxMode,
    ArtifactReviewPolicy? artifactReviewPolicy,
  }) {
    return AgentSettings(
      securityPreset: securityPreset ?? this.securityPreset,
      outsideFoldersFileAccess:
          outsideFoldersFileAccess ?? this.outsideFoldersFileAccess,
      terminalCommandAutoExecution:
          terminalCommandAutoExecution ?? this.terminalCommandAutoExecution,
      enableSandboxMode: enableSandboxMode ?? this.enableSandboxMode,
      artifactReviewPolicy: artifactReviewPolicy ?? this.artifactReviewPolicy,
    );
  }
}

// ============ MAIN WIDGET ============
class AgentSettingsScreen extends ConsumerStatefulWidget {
  const AgentSettingsScreen({super.key});

  @override
  ConsumerState<AgentSettingsScreen> createState() =>
      _AgentSettingsScreenState();
}

class _AgentSettingsScreenState extends ConsumerState<AgentSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Settings'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SecurityPresetSection(),
            SizedBox(height: 24),
            OutsideFoldersSection(),
            SizedBox(height: 24),
            TerminalExecutionSection(),
            SizedBox(height: 24),
            SandboxModeSection(),
            SizedBox(height: 24),
            ArtifactReviewSection(),
            SizedBox(height: 24),
            LocalPermissionsSection(),
            SizedBox(height: 24),
            FileAccessRulesSection(),
            SizedBox(height: 24),
            NetworkAccessRulesSection(),
            SizedBox(height: 32),
            ProvideFeedbackButton(),
          ],
        ),
      ),
    );
  }
}

// ============ SECURITY PRESET SECTION ============
class SecurityPresetSection extends ConsumerWidget {
  const SecurityPresetSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(agentSettingsProvider);

    return _buildSection(
      title: 'Security Preset',
      subtitle:
          'Choose a predefined security preset for the agent. This controls terminal auto-execution policy, and file access policy.',
      child: Column(
        children: [
          _buildRadioOption(
            value: SecurityPreset.custom,
            groupValue: settings.securityPreset,
            label: 'Custom',
            onChanged: (value) {
              ref
                  .read(agentSettingsProvider.notifier)
                  .updateSecurityPreset(value!);
            },
          ),
          _buildRadioOption(
            value: SecurityPreset.standard,
            groupValue: settings.securityPreset,
            label: 'Standard',
            onChanged: (value) {
              ref
                  .read(agentSettingsProvider.notifier)
                  .updateSecurityPreset(value!);
            },
          ),
          _buildRadioOption(
            value: SecurityPreset.strict,
            groupValue: settings.securityPreset,
            label: 'Strict',
            onChanged: (value) {
              ref
                  .read(agentSettingsProvider.notifier)
                  .updateSecurityPreset(value!);
            },
          ),
        ],
      ),
    );
  }
}

// ============ OUTSIDE FOLDERS SECTION ============
class OutsideFoldersSection extends ConsumerWidget {
  const OutsideFoldersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(agentSettingsProvider);

    return _buildSection(
      title: 'Outside of Folders File Access Policy',
      subtitle:
          'Configures how the agent tries to access files outside of its working folders.',
      child: Column(
        children: [
          _buildRadioOption(
            value: FileAccessPolicy.alwaysAsk,
            groupValue: settings.outsideFoldersFileAccess,
            label: 'Always Ask',
            onChanged: (value) {
              ref
                  .read(agentSettingsProvider.notifier)
                  .updateFileAccessPolicy(value!);
            },
          ),
          _buildRadioOption(
            value: FileAccessPolicy.allowAll,
            groupValue: settings.outsideFoldersFileAccess,
            label: 'Allow All',
            onChanged: (value) {
              ref
                  .read(agentSettingsProvider.notifier)
                  .updateFileAccessPolicy(value!);
            },
          ),
          _buildRadioOption(
            value: FileAccessPolicy.denyAll,
            groupValue: settings.outsideFoldersFileAccess,
            label: 'Deny All',
            onChanged: (value) {
              ref
                  .read(agentSettingsProvider.notifier)
                  .updateFileAccessPolicy(value!);
            },
          ),
          _buildRadioOption(
            value: FileAccessPolicy.allowList,
            groupValue: settings.outsideFoldersFileAccess,
            label: 'Allow List',
            onChanged: (value) {
              ref
                  .read(agentSettingsProvider.notifier)
                  .updateFileAccessPolicy(value!);
            },
          ),
        ],
      ),
    );
  }
}

// ============ TERMINAL EXECUTION SECTION ============
class TerminalExecutionSection extends ConsumerWidget {
  const TerminalExecutionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(agentSettingsProvider);

    return _buildSection(
      title: 'Terminal Command Auto Execution',
      subtitle:
          'Controls whether terminal commands require your approval before running.',
      child: Column(
        children: [
          _buildRadioOption(
            value: TerminalExecutionPolicy.requireReview,
            groupValue: settings.terminalCommandAutoExecution,
            label: 'Require Review',
            onChanged: (value) {
              ref
                  .read(agentSettingsProvider.notifier)
                  .updateTerminalExecution(value!);
            },
          ),
          _buildRadioOption(
            value: TerminalExecutionPolicy.autoApprove,
            groupValue: settings.terminalCommandAutoExecution,
            label: 'Auto Approve',
            onChanged: (value) {
              ref
                  .read(agentSettingsProvider.notifier)
                  .updateTerminalExecution(value!);
            },
          ),
          _buildRadioOption(
            value: TerminalExecutionPolicy.autoDeny,
            groupValue: settings.terminalCommandAutoExecution,
            label: 'Auto Deny',
            onChanged: (value) {
              ref
                  .read(agentSettingsProvider.notifier)
                  .updateTerminalExecution(value!);
            },
          ),
        ],
      ),
    );
  }
}

// ============ SANDBOX MODE SECTION ============
class SandboxModeSection extends ConsumerWidget {
  const SandboxModeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(agentSettingsProvider);

    return _buildSection(
      title: 'Enable Sandbox Mode (Preview)',
      subtitle: 'Restricts agent tools to a secure, isolated local sandbox.',
      child: SwitchListTile(
        value: settings.enableSandboxMode,
        onChanged: (value) {
          ref.read(agentSettingsProvider.notifier).updateSandboxMode(value);
        },
        title: const Text('Enable Sandbox Mode'),
        subtitle: const Text('Preview feature - may have limitations'),
        activeColor: Colors.blue,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

// ============ ARTIFACT REVIEW SECTION ============
class ArtifactReviewSection extends ConsumerWidget {
  const ArtifactReviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(agentSettingsProvider);

    return _buildSection(
      title: 'Artifact Review Policy',
      subtitle:
          "Specifies Agent's behavior when asking for review on artifacts, which are documents it creates to enable a richer conversation experience.",
      child: Column(
        children: [
          _buildRadioOption(
            value: ArtifactReviewPolicy.alwaysAsk,
            groupValue: settings.artifactReviewPolicy,
            label: 'Always Ask',
            onChanged: (value) {
              ref
                  .read(agentSettingsProvider.notifier)
                  .updateArtifactReviewPolicy(value!);
            },
          ),
          _buildRadioOption(
            value: ArtifactReviewPolicy.autoApprove,
            groupValue: settings.artifactReviewPolicy,
            label: 'Auto Approve',
            onChanged: (value) {
              ref
                  .read(agentSettingsProvider.notifier)
                  .updateArtifactReviewPolicy(value!);
            },
          ),
          _buildRadioOption(
            value: ArtifactReviewPolicy.autoDeny,
            groupValue: settings.artifactReviewPolicy,
            label: 'Auto Deny',
            onChanged: (value) {
              ref
                  .read(agentSettingsProvider.notifier)
                  .updateArtifactReviewPolicy(value!);
            },
          ),
        ],
      ),
    );
  }
}

// ============ LOCAL PERMISSIONS SECTION ============
class LocalPermissionsSection extends StatelessWidget {
  const LocalPermissionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildSection(
      title: 'Local Permissions',
      subtitle:
          'Inherits from global settings. Local permissions have higher priority. Learn more.',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: const Text(
          'No local permissions configured',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }
}

// ============ FILE ACCESS RULES SECTION ============
class FileAccessRulesSection extends StatelessWidget {
  const FileAccessRulesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildSection(
      title: 'File Access Rules',
      subtitle: 'Configure allowed and denied paths for file reads and writes.',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ElevatedButton.icon(
          onPressed: () {
            // Navigate to file access rules configuration
          },
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Open'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            elevation: 0,
            minimumSize: const Size(80, 36),
          ),
        ),
      ),
    );
  }
}

// ============ NETWORK ACCESS RULES SECTION ============
class NetworkAccessRulesSection extends StatelessWidget {
  const NetworkAccessRulesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildSection(
      title: 'Network Access Rules',
      subtitle: 'Configure allowed and denied URLs for reading.',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ElevatedButton.icon(
          onPressed: () {
            // Navigate to network access rules configuration
          },
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Open'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            elevation: 0,
            minimumSize: const Size(80, 36),
          ),
        ),
      ),
    );
  }
}

// ============ PROVIDE FEEDBACK BUTTON ============
class ProvideFeedbackButton extends StatelessWidget {
  const ProvideFeedbackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () {
          // Navigate to feedback
        },
        icon: const Icon(Icons.feedback_outlined, size: 18),
        label: const Text('Provide Feedback'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey[700],
          side: BorderSide(color: Colors.grey[300]!),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}

// ============ HELPER WIDGETS ============
Widget _buildSection({
  required String title,
  required String subtitle,
  required Widget child,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
      ),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: child,
      ),
    ],
  );
}

Widget _buildRadioOption<T>({
  required T value,
  required T groupValue,
  required String label,
  required ValueChanged<T?> onChanged,
}) {
  return RadioListTile<T>(
    value: value,
    groupValue: groupValue,
    onChanged: onChanged,
    title: Text(
      label,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    dense: true,
    visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
    activeColor: Colors.blue,
  );
}
