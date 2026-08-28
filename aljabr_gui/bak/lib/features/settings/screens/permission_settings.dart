// permissions_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============ PROVIDERS ============
final permissionsSettingsProvider =
    StateNotifierProvider<PermissionsSettingsNotifier, PermissionsSettings>((
      ref,
    ) {
      return PermissionsSettingsNotifier();
    });

class PermissionsSettingsNotifier extends StateNotifier<PermissionsSettings> {
  PermissionsSettingsNotifier()
    : super(
        const PermissionsSettings(
          projectSpecificSettings: ProjectSpecificSettings(
            sandboxEnabled: false,
            terminalExecution: TerminalExecutionPolicy.requireReview,
          ),
          fileAccessRules: [],
          networkAccessRules: [],
          terminalCommands: [],
          commandsOutsideSandbox: [],
          mcpTools: [],
        ),
      );

  void updateProjectSpecificSettings(ProjectSpecificSettings settings) {
    state = state.copyWith(projectSpecificSettings: settings);
  }

  void addFileAccessRule(FileAccessRule rule) {
    final newRules = List<FileAccessRule>.from(state.fileAccessRules)
      ..add(rule);
    state = state.copyWith(fileAccessRules: newRules);
  }

  void removeFileAccessRule(String id) {
    final newRules = state.fileAccessRules
        .where((rule) => rule.id != id)
        .toList();
    state = state.copyWith(fileAccessRules: newRules);
  }

  void addNetworkAccessRule(NetworkAccessRule rule) {
    final newRules = List<NetworkAccessRule>.from(state.networkAccessRules)
      ..add(rule);
    state = state.copyWith(networkAccessRules: newRules);
  }

  void removeNetworkAccessRule(String id) {
    final newRules = state.networkAccessRules
        .where((rule) => rule.id != id)
        .toList();
    state = state.copyWith(networkAccessRules: newRules);
  }
}

// ============ MODELS ============
enum TerminalExecutionPolicy { requireReview, autoApprove, autoDeny }

class ProjectSpecificSettings {
  final bool sandboxEnabled;
  final TerminalExecutionPolicy terminalExecution;

  const ProjectSpecificSettings({
    required this.sandboxEnabled,
    required this.terminalExecution,
  });

  ProjectSpecificSettings copyWith({
    bool? sandboxEnabled,
    TerminalExecutionPolicy? terminalExecution,
  }) {
    return ProjectSpecificSettings(
      sandboxEnabled: sandboxEnabled ?? this.sandboxEnabled,
      terminalExecution: terminalExecution ?? this.terminalExecution,
    );
  }
}

class FileAccessRule {
  final String id;
  final String path;
  final bool isAllowed;

  FileAccessRule({
    required this.id,
    required this.path,
    required this.isAllowed,
  });
}

class NetworkAccessRule {
  final String id;
  final String url;
  final bool isAllowed;

  NetworkAccessRule({
    required this.id,
    required this.url,
    required this.isAllowed,
  });
}

class TerminalCommand {
  final String id;
  final String command;
  final bool isAllowed;

  TerminalCommand({
    required this.id,
    required this.command,
    required this.isAllowed,
  });
}

class MCPTool {
  final String id;
  final String name;
  final String description;
  final bool isEnabled;

  MCPTool({
    required this.id,
    required this.name,
    required this.description,
    required this.isEnabled,
  });
}

class PermissionsSettings {
  final ProjectSpecificSettings projectSpecificSettings;
  final List<FileAccessRule> fileAccessRules;
  final List<NetworkAccessRule> networkAccessRules;
  final List<TerminalCommand> terminalCommands;
  final List<TerminalCommand> commandsOutsideSandbox;
  final List<MCPTool> mcpTools;

  const PermissionsSettings({
    required this.projectSpecificSettings,
    required this.fileAccessRules,
    required this.networkAccessRules,
    required this.terminalCommands,
    required this.commandsOutsideSandbox,
    required this.mcpTools,
  });

  PermissionsSettings copyWith({
    ProjectSpecificSettings? projectSpecificSettings,
    List<FileAccessRule>? fileAccessRules,
    List<NetworkAccessRule>? networkAccessRules,
    List<TerminalCommand>? terminalCommands,
    List<TerminalCommand>? commandsOutsideSandbox,
    List<MCPTool>? mcpTools,
  }) {
    return PermissionsSettings(
      projectSpecificSettings:
          projectSpecificSettings ?? this.projectSpecificSettings,
      fileAccessRules: fileAccessRules ?? this.fileAccessRules,
      networkAccessRules: networkAccessRules ?? this.networkAccessRules,
      terminalCommands: terminalCommands ?? this.terminalCommands,
      commandsOutsideSandbox:
          commandsOutsideSandbox ?? this.commandsOutsideSandbox,
      mcpTools: mcpTools ?? this.mcpTools,
    );
  }
}

// ============ MAIN WIDGET ============
class PermissionsSettingsScreen extends ConsumerStatefulWidget {
  const PermissionsSettingsScreen({super.key});

  @override
  ConsumerState<PermissionsSettingsScreen> createState() =>
      _PermissionsSettingsScreenState();
}

class _PermissionsSettingsScreenState
    extends ConsumerState<PermissionsSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions Settings'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProjectSpecificSettingsSection(),
            SizedBox(height: 24),
            FileAccessRulesSection(),
            SizedBox(height: 24),
            NetworkAccessRulesSection(),
            SizedBox(height: 24),
            TerminalCommandsSection(),
            SizedBox(height: 24),
            CommandsOutsideSandboxSection(),
            SizedBox(height: 24),
            MCPToolsSection(),
            SizedBox(height: 32),
            ProvideFeedbackButton(),
          ],
        ),
      ),
    );
  }
}

// ============ PROJECT SPECIFIC SETTINGS SECTION ============
class ProjectSpecificSettingsSection extends ConsumerWidget {
  const ProjectSpecificSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(permissionsSettingsProvider);

    return _buildSection(
      title: 'Project-Specific Settings',
      subtitle:
          'Modify scoped permissions, folders, and agent settings like Sandbox and Terminal Command Execution.',
      child: Column(
        children: [
          // Sandbox toggle
          SwitchListTile(
            value: settings.projectSpecificSettings.sandboxEnabled,
            onChanged: (value) {
              final current = settings.projectSpecificSettings;
              ref
                  .read(permissionsSettingsProvider.notifier)
                  .updateProjectSpecificSettings(
                    current.copyWith(sandboxEnabled: value),
                  );
            },
            title: const Text('Sandbox Mode'),
            subtitle: const Text(
              'Restrict agent tools to a secure environment',
            ),
            activeColor: Colors.blue,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            dense: true,
          ),
          const Divider(height: 1),
          // Terminal Execution dropdown
          ListTile(
            title: const Text(
              'Terminal Command Execution',
              style: TextStyle(fontSize: 14),
            ),
            trailing: DropdownButton<TerminalExecutionPolicy>(
              value: settings.projectSpecificSettings.terminalExecution,
              onChanged: (value) {
                if (value != null) {
                  final current = settings.projectSpecificSettings;
                  ref
                      .read(permissionsSettingsProvider.notifier)
                      .updateProjectSpecificSettings(
                        current.copyWith(terminalExecution: value),
                      );
                }
              },
              items: TerminalExecutionPolicy.values.map((policy) {
                return DropdownMenuItem(
                  value: policy,
                  child: Text(
                    policy.name.replaceAll('_', ' ').toTitleCase(),
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              elevation: 0,
              isDense: true,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            dense: true,
          ),
          const Divider(height: 1),
          // Projects list
          _buildProjectListTile(
            label: 'Projects',
            projects: const ['wayang-platform', 'gollek'],
            onTap: () {
              // Navigate to projects
            },
          ),
        ],
      ),
    );
  }
}

// ============ FILE ACCESS RULES SECTION ============
class FileAccessRulesSection extends ConsumerWidget {
  const FileAccessRulesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(permissionsSettingsProvider);

    return _buildSection(
      title: 'File Access Rules',
      subtitle: 'Configure allowed and denied paths for file reads and writes.',
      child: Column(
        children: [
          _buildOpenButton(
            label: 'Open',
            onPressed: () {
              // Navigate to file access rules configuration
            },
          ),
          if (settings.fileAccessRules.isNotEmpty) ...[
            const Divider(height: 1),
            ...settings.fileAccessRules.map(
              (rule) => _buildAccessRuleTile(
                label: rule.path,
                isAllowed: rule.isAllowed,
                onDelete: () {
                  ref
                      .read(permissionsSettingsProvider.notifier)
                      .removeFileAccessRule(rule.id);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============ NETWORK ACCESS RULES SECTION ============
class NetworkAccessRulesSection extends ConsumerWidget {
  const NetworkAccessRulesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(permissionsSettingsProvider);

    return _buildSection(
      title: 'Network Access Rules',
      subtitle: 'Configure allowed and denied URLs for reading.',
      child: Column(
        children: [
          _buildOpenButton(
            label: 'Open',
            onPressed: () {
              // Navigate to network access rules configuration
            },
          ),
          if (settings.networkAccessRules.isNotEmpty) ...[
            const Divider(height: 1),
            ...settings.networkAccessRules.map(
              (rule) => _buildAccessRuleTile(
                label: rule.url,
                isAllowed: rule.isAllowed,
                onDelete: () {
                  ref
                      .read(permissionsSettingsProvider.notifier)
                      .removeNetworkAccessRule(rule.id);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============ TERMINAL COMMANDS SECTION ============
class TerminalCommandsSection extends ConsumerWidget {
  const TerminalCommandsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(permissionsSettingsProvider);

    return _buildSection(
      title: 'Terminal & Tooling Permissions',
      subtitle: 'Configure allowed terminal commands.',
      child: Column(
        children: [
          _buildOpenButton(
            label: 'Open',
            onPressed: () {
              // Navigate to terminal commands configuration
            },
          ),
          if (settings.terminalCommands.isNotEmpty) ...[
            const Divider(height: 1),
            ...settings.terminalCommands.map(
              (command) => _buildCommandTile(
                label: command.command,
                isAllowed: command.isAllowed,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============ COMMANDS OUTSIDE SANDBOX SECTION ============
class CommandsOutsideSandboxSection extends ConsumerWidget {
  const CommandsOutsideSandboxSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(permissionsSettingsProvider);

    return _buildSection(
      title: 'Commands Outside Sandbox',
      subtitle: 'Configure allowed commands outside the sandbox.',
      child: Column(
        children: [
          _buildOpenButton(
            label: 'Open',
            onPressed: () {
              // Navigate to commands outside sandbox configuration
            },
          ),
          if (settings.commandsOutsideSandbox.isNotEmpty) ...[
            const Divider(height: 1),
            ...settings.commandsOutsideSandbox.map(
              (command) => _buildCommandTile(
                label: command.command,
                isAllowed: command.isAllowed,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============ MCP TOOLS SECTION ============
class MCPToolsSection extends ConsumerWidget {
  const MCPToolsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(permissionsSettingsProvider);

    return _buildSection(
      title: 'MCP Tools',
      subtitle: 'Configure external tools via Model Context Protocol.',
      child: Column(
        children: [
          _buildOpenButton(
            label: 'Open',
            onPressed: () {
              // Navigate to MCP tools configuration
            },
          ),
          if (settings.mcpTools.isNotEmpty) ...[
            const Divider(height: 1),
            ...settings.mcpTools.map(
              (tool) => _buildMCPToolTile(
                label: tool.name,
                description: tool.description,
                isEnabled: tool.isEnabled,
              ),
            ),
          ],
        ],
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

Widget _buildOpenButton({
  required String label,
  required VoidCallback onPressed,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.edit, size: 18),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              elevation: 0,
              minimumSize: const Size(double.infinity, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildProjectListTile({
  required String label,
  required List<String> projects,
  required VoidCallback onTap,
}) {
  return ListTile(
    title: Text(
      label,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...projects.map(
          (project) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              project,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
      ],
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    dense: true,
    onTap: onTap,
  );
}

Widget _buildAccessRuleTile({
  required String label,
  required bool isAllowed,
  required VoidCallback onDelete,
}) {
  return ListTile(
    leading: Icon(
      isAllowed ? Icons.check_circle : Icons.cancel,
      color: isAllowed ? Colors.green : Colors.red,
      size: 18,
    ),
    title: Text(
      label,
      style: const TextStyle(fontSize: 13, color: Colors.black87),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    trailing: IconButton(
      icon: Icon(Icons.close, size: 18, color: Colors.grey[400]),
      onPressed: onDelete,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    dense: true,
  );
}

Widget _buildCommandTile({required String label, required bool isAllowed}) {
  return ListTile(
    leading: Icon(
      isAllowed ? Icons.check_circle : Icons.cancel,
      color: isAllowed ? Colors.green : Colors.red,
      size: 18,
    ),
    title: Text(
      label,
      style: TextStyle(
        fontSize: 13,
        color: isAllowed ? Colors.black87 : Colors.grey[500],
        fontFamily: 'monospace',
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    trailing: Text(
      isAllowed ? 'Allowed' : 'Denied',
      style: TextStyle(
        fontSize: 12,
        color: isAllowed ? Colors.green : Colors.red,
        fontWeight: FontWeight.w500,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    dense: true,
  );
}

Widget _buildMCPToolTile({
  required String label,
  required String description,
  required bool isEnabled,
}) {
  return ListTile(
    leading: Icon(
      isEnabled ? Icons.check_circle : Icons.cancel,
      color: isEnabled ? Colors.green : Colors.grey[400],
      size: 18,
    ),
    title: Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    ),
    subtitle: Text(
      description,
      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    trailing: Switch(
      value: isEnabled,
      onChanged: (_) {},
      activeColor: Colors.blue,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    dense: true,
  );
}

// ============ EXTENSIONS ============
extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split('_')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
