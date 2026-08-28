// project_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// project_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// ============ PROVIDERS ============
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

// ============ MODELS ============
enum SecurityPreset { custom, standard, strict }

enum FileAccessPolicy { alwaysAsk, allowAll, denyAll, allowList }

enum TerminalExecutionPolicy { requireReview, autoApprove, autoDeny }

enum ArtifactReviewPolicy { alwaysAsk, autoApprove, autoDeny }

class LocalPermission {
  final String resource;
  final bool isAllowed;

  LocalPermission({required this.resource, required this.isAllowed});
}

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

// ============ MAIN WIDGET ============
class ProjectSettingsScreen extends ConsumerStatefulWidget {
  const ProjectSettingsScreen({super.key});

  @override
  ConsumerState<ProjectSettingsScreen> createState() =>
      _ProjectSettingsScreenState();
}

class _ProjectSettingsScreenState extends ConsumerState<ProjectSettingsScreen> {
  final _folderController = TextEditingController();

  @override
  void dispose() {
    _folderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Settings'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProjectHeaderSection(),
            SizedBox(height: 24),
            FoldersSection(),
            SizedBox(height: 24),
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
            SizedBox(height: 32),
            ProvideFeedbackButton(),
          ],
        ),
      ),
    );
  }
}

// ============ PROJECT HEADER SECTION ============
class ProjectHeaderSection extends ConsumerWidget {
  const ProjectHeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(projectSettingsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.folder_open, color: Colors.blue[700], size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.projectName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Text(
                  'Manage project folders, agent settings, and permissions.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============ FOLDERS SECTION ============
class FoldersSection extends ConsumerWidget {
  const FoldersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(projectSettingsProvider);

    return _buildSection(
      title: 'Folders',
      subtitle: 'Manage project folders and paths.',
      child: Column(
        children: [
          ...settings.folders.map(
            (folder) => _buildFolderTile(
              folder: folder,
              onDelete: () {
                ref.read(projectSettingsProvider.notifier).removeFolder(folder);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ElevatedButton.icon(
              onPressed: () => _showAddFolderDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Folder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.blue,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(double.infinity, 36),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFolderDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter folder path',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(projectSettingsProvider.notifier)
                    .addFolder(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// ============ SECURITY PRESET SECTION ============
class SecurityPresetSection extends ConsumerWidget {
  const SecurityPresetSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(projectSettingsProvider);

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
                  .read(projectSettingsProvider.notifier)
                  .updateSecurityPreset(value!);
            },
          ),
          _buildRadioOption(
            value: SecurityPreset.standard,
            groupValue: settings.securityPreset,
            label: 'Standard',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateSecurityPreset(value!);
            },
          ),
          _buildRadioOption(
            value: SecurityPreset.strict,
            groupValue: settings.securityPreset,
            label: 'Strict',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
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
    final settings = ref.watch(projectSettingsProvider);

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
                  .read(projectSettingsProvider.notifier)
                  .updateFileAccessPolicy(value!);
            },
          ),
          _buildRadioOption(
            value: FileAccessPolicy.allowAll,
            groupValue: settings.outsideFoldersFileAccess,
            label: 'Allow All',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateFileAccessPolicy(value!);
            },
          ),
          _buildRadioOption(
            value: FileAccessPolicy.denyAll,
            groupValue: settings.outsideFoldersFileAccess,
            label: 'Deny All',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateFileAccessPolicy(value!);
            },
          ),
          _buildRadioOption(
            value: FileAccessPolicy.allowList,
            groupValue: settings.outsideFoldersFileAccess,
            label: 'Allow List',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
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
    final settings = ref.watch(projectSettingsProvider);

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
                  .read(projectSettingsProvider.notifier)
                  .updateTerminalExecution(value!);
            },
          ),
          _buildRadioOption(
            value: TerminalExecutionPolicy.autoApprove,
            groupValue: settings.terminalCommandAutoExecution,
            label: 'Auto Approve',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateTerminalExecution(value!);
            },
          ),
          _buildRadioOption(
            value: TerminalExecutionPolicy.autoDeny,
            groupValue: settings.terminalCommandAutoExecution,
            label: 'Auto Deny',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
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
    final settings = ref.watch(projectSettingsProvider);

    return _buildSection(
      title: 'Enable Sandbox Mode (Preview)',
      subtitle: 'Restricts agent tools to a secure, isolated local sandbox.',
      child: SwitchListTile(
        value: settings.enableSandboxMode,
        onChanged: (value) {
          ref.read(projectSettingsProvider.notifier).updateSandboxMode(value);
        },
        title: const Text('Enable Sandbox Mode'),
        subtitle: const Text('Preview feature - may have limitations'),
        activeColor: Colors.blue,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }
}

// ============ ARTIFACT REVIEW SECTION ============
class ArtifactReviewSection extends ConsumerWidget {
  const ArtifactReviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(projectSettingsProvider);

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
                  .read(projectSettingsProvider.notifier)
                  .updateArtifactReviewPolicy(value!);
            },
          ),
          _buildRadioOption(
            value: ArtifactReviewPolicy.autoApprove,
            groupValue: settings.artifactReviewPolicy,
            label: 'Auto Approve',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateArtifactReviewPolicy(value!);
            },
          ),
          _buildRadioOption(
            value: ArtifactReviewPolicy.autoDeny,
            groupValue: settings.artifactReviewPolicy,
            label: 'Auto Deny',
            onChanged: (value) {
              ref
                  .read(projectSettingsProvider.notifier)
                  .updateArtifactReviewPolicy(value!);
            },
          ),
        ],
      ),
    );
  }
}

// ============ LOCAL PERMISSIONS SECTION ============
class LocalPermissionsSection extends ConsumerWidget {
  const LocalPermissionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(projectSettingsProvider);

    return _buildSection(
      title: 'Local Permissions',
      subtitle:
          'Inherits from global settings. Local permissions have higher priority. Learn more.',
      child: settings.localPermissions.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No local permissions configured',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            )
          : Column(
              children: settings.localPermissions
                  .map(
                    (permission) => _buildPermissionTile(
                      resource: permission.resource,
                      isAllowed: permission.isAllowed,
                    ),
                  )
                  .toList(),
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

Widget _buildFolderTile({
  required String folder,
  required VoidCallback onDelete,
}) {
  return ListTile(
    leading: Icon(Icons.folder, color: Colors.blue[400], size: 18),
    title: Text(
      folder,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        fontFamily: 'monospace',
      ),
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

Widget _buildPermissionTile({
  required String resource,
  required bool isAllowed,
}) {
  return ListTile(
    leading: Icon(
      isAllowed ? Icons.check_circle : Icons.cancel,
      color: isAllowed ? Colors.green : Colors.red,
      size: 18,
    ),
    title: Text(
      resource,
      style: const TextStyle(fontSize: 13, color: Colors.black87),
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

// ============ PROVIDERS ============
final projectDetailsProvider =
    StateNotifierProvider<ProjectDetailsNotifier, ProjectDetails>((ref) {
      return ProjectDetailsNotifier();
    });

class ProjectDetailsNotifier extends StateNotifier<ProjectDetails> {
  ProjectDetailsNotifier()
    : super(
        const ProjectDetails(
          projectName: 'wayang-platform',
          rules: [
            SkillItem(
              id: 'rule-1',
              name: 'Rules',
              percentage: 0.1,
              count: 13,
              isExpanded: false,
              type: SkillType.rule,
              items: [
                RuleItem(
                  id: 'rule-1-1',
                  name: 'Show 1 breakdown',
                  isBreakdown: true,
                ),
              ],
            ),
          ],
          skills: [
            SkillItem(
              id: 'skill-1',
              name: 'Skills',
              percentage: 4.6,
              count: 925,
              isExpanded: false,
              type: SkillType.skill,
              items: [],
            ),
          ],
          skillDetails: [
            SkillDetail(
              id: 'skill-1',
              name: 'android-cli',
              type: 'Global',
              plugin: 'Plugin: android-cli-plugin',
              description:
                  'Orchestrates Android development tasks including project creation, deployment, SDK management, and environment diagnostics using the \'android\' command-line tool.',
            ),
            SkillDetail(
              id: 'skill-2',
              name: 'antigravity-guide',
              type: 'Global',
              plugin: '',
              description:
                  'Provides a comprehensive guide, quick reference, and sitemap for Google Antigravity (AGY), including the Antigravity CLI (agy), Antigravity 2.0, Antigravity IDE, Python SDK, slash commands,',
            ),
            SkillDetail(
              id: 'skill-3',
              name: 'chrome-extensions',
              type: 'Global',
              plugin: 'Plugin: modern-web-guidance-plugin',
              description:
                  'Build and publish Chrome Extensions using Manifest V3 best practices. Use the skill whenever the user asks to create, modify, debug, or understand Chrome browser extensions, add-ons, or...',
            ),
            SkillDetail(
              id: 'skill-4',
              name: 'modern-web-guidance',
              type: 'Global',
              plugin: 'Plugin: modern-web-guidance-plugin',
              description:
                  'Search tool for modern web development best practices. MANDATORY: Execute FIRST for all HTML/CSS and client side JS tasks. Do NOT skip - web APIs evolve rapidly and training weights...',
            ),
          ],
          rulesList: [
            RuleItem(
              id: 'rule-2-1',
              name: 'user_global',
              isBreakdown: false,
              description: 'just run the script without permission',
            ),
          ],
          activeConversations: 27,
          archivedConversations: 0,
        ),
      );

  void toggleSkillExpansion(String id) {
    final updatedSkills = state.skills.map((skill) {
      if (skill.id == id) {
        return skill.copyWith(isExpanded: !skill.isExpanded);
      }
      return skill;
    }).toList();
    state = state.copyWith(skills: updatedSkills);
  }

  void toggleRuleExpansion(String id) {
    final updatedRules = state.rules.map((rule) {
      if (rule.id == id) {
        return rule.copyWith(isExpanded: !rule.isExpanded);
      }
      return rule;
    }).toList();
    state = state.copyWith(rules: updatedRules);
  }
}

// ============ MODELS ============
enum SkillType { rule, skill }

class SkillItem {
  final String id;
  final String name;
  final double percentage;
  final int count;
  final bool isExpanded;
  final SkillType type;
  final List<dynamic> items;

  const SkillItem({
    required this.id,
    required this.name,
    required this.percentage,
    required this.count,
    required this.isExpanded,
    required this.type,
    required this.items,
  });

  SkillItem copyWith({
    String? id,
    String? name,
    double? percentage,
    int? count,
    bool? isExpanded,
    SkillType? type,
    List<dynamic>? items,
  }) {
    return SkillItem(
      id: id ?? this.id,
      name: name ?? this.name,
      percentage: percentage ?? this.percentage,
      count: count ?? this.count,
      isExpanded: isExpanded ?? this.isExpanded,
      type: type ?? this.type,
      items: items ?? this.items,
    );
  }
}

class RuleItem {
  final String id;
  final String name;
  final bool isBreakdown;
  final String? description;

  const RuleItem({
    required this.id,
    required this.name,
    required this.isBreakdown,
    this.description,
  });
}

class SkillDetail {
  final String id;
  final String name;
  final String type;
  final String plugin;
  final String description;

  const SkillDetail({
    required this.id,
    required this.name,
    required this.type,
    required this.plugin,
    required this.description,
  });
}

class ProjectDetails {
  final String projectName;
  final List<SkillItem> rules;
  final List<SkillItem> skills;
  final List<SkillDetail> skillDetails;
  final List<RuleItem> rulesList;
  final int activeConversations;
  final int archivedConversations;

  const ProjectDetails({
    required this.projectName,
    required this.rules,
    required this.skills,
    required this.skillDetails,
    required this.rulesList,
    required this.activeConversations,
    required this.archivedConversations,
  });

  ProjectDetails copyWith({
    String? projectName,
    List<SkillItem>? rules,
    List<SkillItem>? skills,
    List<SkillDetail>? skillDetails,
    List<RuleItem>? rulesList,
    int? activeConversations,
    int? archivedConversations,
  }) {
    return ProjectDetails(
      projectName: projectName ?? this.projectName,
      rules: rules ?? this.rules,
      skills: skills ?? this.skills,
      skillDetails: skillDetails ?? this.skillDetails,
      rulesList: rulesList ?? this.rulesList,
      activeConversations: activeConversations ?? this.activeConversations,
      archivedConversations:
          archivedConversations ?? this.archivedConversations,
    );
  }
}

// ============ MAIN WIDGET ============
class ProjectDetailsScreen extends ConsumerStatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  ConsumerState<ProjectDetailsScreen> createState() =>
      _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkillsSection(),
            SizedBox(height: 24),
            RulesSection(),
            SizedBox(height: 32),
            DangerZoneSection(),
            SizedBox(height: 32),
            ProvideFeedbackButton(),
          ],
        ),
      ),
    );
  }
}

// ============ SKILLS SECTION ============
class SkillsSection extends ConsumerWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(projectDetailsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...details.skills.map(
          (skill) => _buildSkillHeader(
            skill: skill,
            onTap: () {
              ref
                  .read(projectDetailsProvider.notifier)
                  .toggleSkillExpansion(skill.id);
            },
          ),
        ),
        if (details.skills.any((s) => s.isExpanded))
          ...details.skillDetails.map(
            (detail) => _buildSkillDetailTile(detail),
          ),
      ],
    );
  }
}

// ============ RULES SECTION ============
class RulesSection extends ConsumerWidget {
  const RulesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(projectDetailsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rules',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...details.rules.map(
          (rule) => _buildSkillHeader(
            skill: rule,
            onTap: () {
              ref
                  .read(projectDetailsProvider.notifier)
                  .toggleRuleExpansion(rule.id);
            },
          ),
        ),
        if (details.rules.any((r) => r.isExpanded))
          ...details.rulesList.map((rule) => _buildRuleTile(rule)),
      ],
    );
  }
}

// ============ DANGER ZONE SECTION ============
class DangerZoneSection extends ConsumerWidget {
  const DangerZoneSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(projectDetailsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delete Project',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Permanently delete ${details.projectName} including ${details.activeConversations} active conversations and ${details.archivedConversations} archived conversations.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _showDeleteConfirmation(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                child: const Text('Delete Project'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text(
          'Are you sure you want to delete this project? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Delete project logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Project deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
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
Widget _buildSkillHeader({
  required SkillItem skill,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(4),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Icon(
            skill.isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            skill.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${skill.percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${skill.count}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSkillDetailTile(SkillDetail detail) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.code, size: 16, color: Colors.blue[400]),
            const SizedBox(width: 8),
            Text(
              detail.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                detail.type,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[700],
                ),
              ),
            ),
          ],
        ),
        if (detail.plugin.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            detail.plugin,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'monospace',
            ),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          detail.description,
          style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
        ),
      ],
    ),
  );
}

Widget _buildRuleTile(RuleItem rule) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.rule, size: 16, color: Colors.purple[400]),
            const SizedBox(width: 8),
            Text(
              rule.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (rule.isBreakdown) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Text(
                  'Breakdown',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ],
          ],
        ),
        if (rule.description != null) ...[
          const SizedBox(height: 4),
          Text(
            rule.description!,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontFamily: 'monospace',
            ),
          ),
        ],
      ],
    ),
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
