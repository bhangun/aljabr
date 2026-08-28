// browser_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============ PROVIDERS ============
final browserSettingsProvider =
    StateNotifierProvider<BrowserSettingsNotifier, BrowserSettings>((ref) {
      return BrowserSettingsNotifier();
    });

class BrowserSettingsNotifier extends StateNotifier<BrowserSettings> {
  BrowserSettingsNotifier()
    : super(
        const BrowserSettings(
          javaScriptExecutionPolicy: JavaScriptExecutionPolicy.requestReview,
          actuationPermissions: ActuationPermissions(rules: []),
        ),
      );

  void updateJavaScriptExecutionPolicy(JavaScriptExecutionPolicy policy) {
    state = state.copyWith(javaScriptExecutionPolicy: policy);
  }

  void addActuationRule(BrowserActuationRule rule) {
    final newRules = List<BrowserActuationRule>.from(
      state.actuationPermissions.rules,
    )..add(rule);
    state = state.copyWith(
      actuationPermissions: state.actuationPermissions.copyWith(
        rules: newRules,
      ),
    );
  }

  void removeActuationRule(String id) {
    final newRules = state.actuationPermissions.rules
        .where((rule) => rule.id != id)
        .toList();
    state = state.copyWith(
      actuationPermissions: state.actuationPermissions.copyWith(
        rules: newRules,
      ),
    );
  }

  void updateActuationRule(String id, bool isAllowed) {
    final updatedRules = state.actuationPermissions.rules.map((rule) {
      if (rule.id == id) {
        return rule.copyWith(isAllowed: isAllowed);
      }
      return rule;
    }).toList();
    state = state.copyWith(
      actuationPermissions: state.actuationPermissions.copyWith(
        rules: updatedRules,
      ),
    );
  }
}

// ============ MODELS ============
enum JavaScriptExecutionPolicy { requestReview, autoApprove, autoDeny }

class BrowserActuationRule {
  final String id;
  final String url;
  final bool isAllowed;

  BrowserActuationRule({
    required this.id,
    required this.url,
    required this.isAllowed,
  });

  BrowserActuationRule copyWith({String? id, String? url, bool? isAllowed}) {
    return BrowserActuationRule(
      id: id ?? this.id,
      url: url ?? this.url,
      isAllowed: isAllowed ?? this.isAllowed,
    );
  }
}

class ActuationPermissions {
  final List<BrowserActuationRule> rules;

  const ActuationPermissions({required this.rules});

  ActuationPermissions copyWith({List<BrowserActuationRule>? rules}) {
    return ActuationPermissions(rules: rules ?? this.rules);
  }
}

class BrowserSettings {
  final JavaScriptExecutionPolicy javaScriptExecutionPolicy;
  final ActuationPermissions actuationPermissions;

  const BrowserSettings({
    required this.javaScriptExecutionPolicy,
    required this.actuationPermissions,
  });

  BrowserSettings copyWith({
    JavaScriptExecutionPolicy? javaScriptExecutionPolicy,
    ActuationPermissions? actuationPermissions,
  }) {
    return BrowserSettings(
      javaScriptExecutionPolicy:
          javaScriptExecutionPolicy ?? this.javaScriptExecutionPolicy,
      actuationPermissions: actuationPermissions ?? this.actuationPermissions,
    );
  }
}

// ============ MAIN WIDGET ============
class BrowserSettingsScreen extends ConsumerStatefulWidget {
  const BrowserSettingsScreen({super.key});

  @override
  ConsumerState<BrowserSettingsScreen> createState() =>
      _BrowserSettingsScreenState();
}

class _BrowserSettingsScreenState extends ConsumerState<BrowserSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browser Settings'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BrowserInfoSection(),
            SizedBox(height: 24),
            JavaScriptExecutionSection(),
            SizedBox(height: 24),
            ActuationPermissionsSection(),
            SizedBox(height: 32),
            ProvideFeedbackButton(),
          ],
        ),
      ),
    );
  }
}

// ============ BROWSER INFO SECTION ============
class BrowserInfoSection extends StatelessWidget {
  const BrowserInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browser Subagent',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Configure the browser subagent. It requires Google Chrome to be installed. '
                  'The browser subagent can be invoked by typing /browser in the conversation input box.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============ JAVASCRIPT EXECUTION SECTION ============
class JavaScriptExecutionSection extends ConsumerWidget {
  const JavaScriptExecutionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(browserSettingsProvider);

    return _buildSection(
      title: 'General',
      subtitle: 'Browser JavaScript Execution Policy',
      description:
          'Controls whether the agent can run custom JavaScript to automate complex browser actions.',
      child: Column(
        children: [
          _buildRadioOption(
            value: JavaScriptExecutionPolicy.requestReview,
            groupValue: settings.javaScriptExecutionPolicy,
            label: 'Request Review',
            onChanged: (value) {
              ref
                  .read(browserSettingsProvider.notifier)
                  .updateJavaScriptExecutionPolicy(value!);
            },
          ),
          _buildRadioOption(
            value: JavaScriptExecutionPolicy.autoApprove,
            groupValue: settings.javaScriptExecutionPolicy,
            label: 'Auto Approve',
            onChanged: (value) {
              ref
                  .read(browserSettingsProvider.notifier)
                  .updateJavaScriptExecutionPolicy(value!);
            },
          ),
          _buildRadioOption(
            value: JavaScriptExecutionPolicy.autoDeny,
            groupValue: settings.javaScriptExecutionPolicy,
            label: 'Auto Deny',
            onChanged: (value) {
              ref
                  .read(browserSettingsProvider.notifier)
                  .updateJavaScriptExecutionPolicy(value!);
            },
          ),
        ],
      ),
    );
  }
}

// ============ ACTUATION PERMISSIONS SECTION ============
class ActuationPermissionsSection extends ConsumerWidget {
  const ActuationPermissionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(browserSettingsProvider);

    return _buildSection(
      title: 'Actuation Permissions',
      subtitle: 'Browser Actuation Rules',
      description: 'Configure allowed and denied URLs for browser actuation.',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddRuleDialog(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Rule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue[700],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to edit rules
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (settings.actuationPermissions.rules.isNotEmpty) ...[
            const Divider(height: 1),
            ...settings.actuationPermissions.rules.map(
              (rule) => _buildRuleTile(
                rule: rule,
                onToggle: (isAllowed) {
                  ref
                      .read(browserSettingsProvider.notifier)
                      .updateActuationRule(rule.id, isAllowed);
                },
                onDelete: () {
                  ref
                      .read(browserSettingsProvider.notifier)
                      .removeActuationRule(rule.id);
                },
              ),
            ),
          ] else ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No actuation rules configured',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddRuleDialog(BuildContext context, WidgetRef ref) {
    final urlController = TextEditingController();
    bool isAllowed = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Actuation Rule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL Pattern',
                  hintText: 'e.g., *.example.com',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Allow:'),
                  const SizedBox(width: 16),
                  Switch(
                    value: isAllowed,
                    onChanged: (value) {
                      setState(() {
                        isAllowed = value;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                  Text(
                    isAllowed ? 'Allowed' : 'Denied',
                    style: TextStyle(
                      color: isAllowed ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (urlController.text.isNotEmpty) {
                  final rule = BrowserActuationRule(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    url: urlController.text,
                    isAllowed: isAllowed,
                  );
                  ref
                      .read(browserSettingsProvider.notifier)
                      .addActuationRule(rule);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
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
  required String description,
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
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        description,
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

Widget _buildRuleTile({
  required BrowserActuationRule rule,
  required ValueChanged<bool> onToggle,
  required VoidCallback onDelete,
}) {
  return ListTile(
    leading: Icon(
      rule.isAllowed ? Icons.check_circle : Icons.cancel,
      color: rule.isAllowed ? Colors.green : Colors.red,
      size: 18,
    ),
    title: Text(
      rule.url,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.black87,
        fontFamily: 'monospace',
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: rule.isAllowed,
          onChanged: onToggle,
          activeColor: Colors.blue,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(Icons.close, size: 18, color: Colors.grey[400]),
          onPressed: onDelete,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
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
