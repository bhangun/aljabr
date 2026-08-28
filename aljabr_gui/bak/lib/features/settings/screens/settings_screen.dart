import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../coding_agent.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../chat/states/sessions_provider.dart';
import '../states/settings_provider.dart';
import '../../../presentation/widgets/shared/shared_widgets.dart';
import '../../../presentation/widgets/shared/shortcuts_help_dialog.dart';
import '../../../presentation/screens/snippets_screen.dart';
import '../../../core/entities/app_settings.dart';
import '../../workspace/workspace.dart';
import '../../../core/utils/token_counter.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _apiKeyCtrl;
  late TextEditingController _systemPromptCtrl;
  late TextEditingController _wayangProBaseUrlCtrl;
  bool _showKey = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _apiKeyCtrl = TextEditingController(text: settings.apiKey);
    _systemPromptCtrl = TextEditingController(text: settings.systemPrompt);
    _wayangProBaseUrlCtrl = TextEditingController(text: settings.wayangProBaseUrl);
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    _systemPromptCtrl.dispose();
    _wayangProBaseUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textPrimary,
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── AI Provider ───────────────────────────────────────────────────
          _Section(
            title: 'AI Provider',
            children: [
              const _FieldLabel('Provider'),
              const SizedBox(height: 6),
              _DropdownField<AiProvider>(
                value: settings.provider,
                items: AiProvider.values,
                onChanged: notifier.updateProvider,
              ),
              const SizedBox(height: 16),
              if (settings.provider == AiProvider.claude) ...[
                const _FieldLabel('Anthropic API Key'),
                const SizedBox(height: 6),
                TextField(
                  controller: _apiKeyCtrl,
                  obscureText: !_showKey,
                  style: AppTheme.monoSmall.copyWith(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'sk-ant-…',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showKey ? Icons.visibility_off : Icons.visibility,
                        size: 17,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: () => setState(() => _showKey = !_showKey),
                    ),
                  ),
                  onSubmitted: (v) => notifier.updateApiKey(v.trim()),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your key is stored locally and never sent to any server other than api.anthropic.com.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
                ),
                const SizedBox(height: 12),
                CodexButton(
                  label: 'Save API key',
                  onPressed: () => notifier.updateApiKey(_apiKeyCtrl.text.trim()),
                ),
              ],
              if (settings.provider == AiProvider.wayangPro) ...[
                const _FieldLabel('Wayang Pro Base URL'),
                const SizedBox(height: 6),
                TextField(
                  controller: _wayangProBaseUrlCtrl,
                  style: AppTheme.monoSmall.copyWith(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'http://localhost:8080',
                  ),
                  onSubmitted: (v) => notifier.updateWayangProBaseUrl(v.trim()),
                ),
                const SizedBox(height: 12),
                CodexButton(
                  label: 'Save Base URL',
                  onPressed: () => notifier.updateWayangProBaseUrl(_wayangProBaseUrlCtrl.text.trim()),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // ── Model ──────────────────────────────────────────────────────────
          _Section(
            title: 'Model',
            children: [
              const _FieldLabel('Model'),
              const SizedBox(height: 6),
              _DropdownField<String>(
                value: settings.model,
                items: AppConstants.modelContextWindows.keys.toList(),
                onChanged: notifier.updateModel,
              ),
              const SizedBox(height: 4),
              Text(
                'Context window: ~${(AppConstants.modelContextWindows[settings.model] ?? 0) ~/ 1000}k tokens',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 14),
              _FieldLabel('Max output tokens: ${settings.maxTokens}'),
              Slider(
                value: settings.maxTokens.toDouble(),
                min: 1024,
                max: 16384,
                divisions: 30,
                activeColor: AppTheme.accent,
                inactiveColor: AppTheme.border,
                label: settings.maxTokens.toString(),
                onChanged: (v) => notifier.updateMaxTokens(v.round()),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Behaviour ──────────────────────────────────────────────────────
          _Section(
            title: 'Behaviour',
            children: [
              _SwitchTile(
                label: 'Streaming responses',
                subtitle: 'See tokens as they arrive',
                value: settings.streamingEnabled,
                onChanged: notifier.updateStreamingEnabled,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Editor ────────────────────────────────────────────────────────
          _Section(
            title: 'Editor',
            children: [
              _FieldLabel('Font size: ${settings.fontSize.round()}px'),
              Slider(
                value: settings.fontSize,
                min: 10,
                max: 20,
                divisions: 10,
                activeColor: AppTheme.accent,
                inactiveColor: AppTheme.border,
                label: '${settings.fontSize.round()}px',
                onChanged: notifier.updateFontSize,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Snippets ──────────────────────────────────────────────────────
          _Section(
            title: 'Prompt snippets',
            children: [
              const Text(
                'Reusable prompts triggered with /shortcut while typing.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 10),
              CodexButton(
                label: 'Manage snippets',
                icon: Icons.bolt_outlined,
                variant: ButtonVariant.secondary,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SnippetsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── System prompt ─────────────────────────────────────────────────
          _Section(
            title: 'System Prompt',
            children: [
              TextField(
                controller: _systemPromptCtrl,
                maxLines: 8,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  height: 1.5,
                ),
                decoration: const InputDecoration(
                  hintText: 'Custom system instructions…',
                ),
                onChanged: notifier.updateSystemPrompt,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _systemPromptCtrl.text = AppSettings.defaultSystemPrompt;
                  notifier.updateSystemPrompt(AppSettings.defaultSystemPrompt);
                },
                child: const Text(
                  'Reset to default',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Data management ──────────────────────────────────────────────
          _Section(
            title: 'Data',
            children: [
              _DataRow(
                label: 'Export all sessions',
                subtitle: 'Copy a JSON backup to clipboard',
                action: 'Export',
                onTap: () => _exportAll(context, ref),
              ),
              const SizedBox(height: 10),
              _DataRow(
                label: 'Import sessions',
                subtitle: 'Restore from a previously exported JSON file',
                action: 'Import',
                onTap: () => _importSessions(context, ref),
              ),
              const SizedBox(height: 10),
              _DataRow(
                label: 'Delete all sessions',
                subtitle: 'Permanently remove every saved session',
                action: 'Delete all',
                danger: true,
                onTap: () => _confirmDeleteAll(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                TextButton.icon(
                  onPressed: () => showShortcutsHelp(context),
                  icon: const Icon(
                    Icons.keyboard_outlined,
                    size: 15,
                    color: AppTheme.textMuted,
                  ),
                  label: const Text(
                    'Keyboard shortcuts',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppConstants.appName} v${AppConstants.appVersion}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAll(BuildContext context, WidgetRef ref) async {
    final result = ref.read(sessionsProvider.notifier).exportAllSessions();
    result.fold(
      onSuccess: (json) async {
        await Clipboard.setData(ClipboardData(text: json));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All sessions copied to clipboard as JSON'),
              backgroundColor: AppTheme.surfaceElevated,
            ),
          );
        }
      },
      onFailure: (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export failed: ${e.message}'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      },
    );
  }

  Future<void> _importSessions(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    final jsonString = String.fromCharCodes(result.files.single.bytes!);
    final importResult = await ref
        .read(sessionsProvider.notifier)
        .importFromJson(jsonString);

    if (!context.mounted) return;
    importResult.fold(
      onSuccess: (sessions) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${sessions.length} session${sessions.length == 1 ? '' : 's'}',
          ),
          backgroundColor: AppTheme.surfaceElevated,
        ),
      ),
      onFailure: (e) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: ${e.message}'),
          backgroundColor: AppTheme.error,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'Delete all sessions?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'This permanently deletes every session and cannot be undone. Consider exporting first.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete all',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(sessionsProvider.notifier).deleteAllSessions();
    }
  }
}


// NEW: Workspace Card Widget
class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard({required this.workspace});
  final Workspace workspace;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.folder_outlined, size: 16, color: AppTheme.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workspace.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${workspace.sessionCount} sessions',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (workspace.isPinned)
            const Icon(Icons.push_pin, size: 14, color: AppTheme.accent),
        ],
      ),
    );
  }
}

// NEW: Token Usage Card
class _TokenUsageCard extends ConsumerWidget {
  const _TokenUsageCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final totalTokens = sessions.fold(0, (sum, s) {
      return sum + s.messages.fold(0, (s2, m) => s2 + (m.tokenCount ?? 0));
    });

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.timer, size: 14, color: AppTheme.textMuted),
            const SizedBox(width: 8),
            Text(
              'Total tokens used: ${_formatTokens(totalTokens)}',
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.message, size: 14, color: AppTheme.textMuted),
            const SizedBox(width: 8),
            Text(
              'Total messages: ${sessions.fold(0, (sum, s) => sum + s.messages.length)}',
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTokens(int tokens) {
    if (tokens < 1000) return '$tokens';
    if (tokens < 1000000) return '${(tokens / 1000).toStringAsFixed(1)}K';
    return '${(tokens / 1000000).toStringAsFixed(1)}M';
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final T value;
  final List<T> items;
  final void Function(T) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: AppTheme.surfaceElevated,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13.5),
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i.toString())))
            .toList(),
        onChanged: (v) => v != null ? onChanged(v) : null,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13.5,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11.5,
                  ),
                ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.accent,
        ),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.label,
    required this.subtitle,
    required this.action,
    required this.onTap,
    this.danger = false,
  });
  final String label;
  final String subtitle;
  final String action;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13.5,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
        CodexButton(
          label: action,
          small: true,
          variant: danger ? ButtonVariant.danger : ButtonVariant.secondary,
          onPressed: onTap,
        ),
      ],
    );
  }
}
