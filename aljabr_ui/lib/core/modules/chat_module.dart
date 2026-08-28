import 'package:flutter/material.dart';
import 'package:aljabr_extension/aljabr_extension.dart';
import '../../features/chat/widgets/chat/chat_panel.dart';
import '../../features/settings/screens/settings_dialog.dart';
import '../../features/settings/screens/skills_settings_view.dart';

class ChatModule implements AljabrModule {
  @override
  String get id => 'aljabr.chat';

  static const viewId = 'aljabr.chat.panel';

  @override
  Future<void> activate(ModuleContext context) async {
    context.views.register(
      ViewContribution(
        id: viewId,
        title: 'Agent',
        icon: Icons.auto_awesome,
        defaultRegion: UiRegion.mainWorkbench,
        builder: (_) => const ChatPanel(),
      ),
      ownerId: id,
    );

    context.navigation.register(
      NavigationContribution(
        id: 'aljabr.chat.navigation',
        groupId: BuiltInNavigationGroups.workspace.id,
        label: 'Agent',
        icon: Icons.auto_awesome,
        viewId: viewId,
        order: 100,
        action: (ctx) {},
      ),
      ownerId: id,
    );

    context.commands.register(
      AppCommand(
        id: 'aljabr.agent.open',
        title: 'Aljabr: Open Agent',
        category: 'Agent',
        icon: Icons.auto_awesome,
        action: (ctx) {},
      ),
      ownerId: id,
    );

    // Register Agent-related settings contributions
    context.settings.register(
      SettingsContribution(
        id: 'aljabr.settings.ai_provider',
        title: 'AI Provider',
        icon: Icons.smart_toy_outlined,
        category: 'Agent',
        order: 20,
        builder: (_) => AiProviderSettingsSection(),
      ),
      ownerId: id,
    );

    context.settings.register(
      SettingsContribution(
        id: 'aljabr.settings.local_llm',
        title: 'Local LLM',
        icon: Icons.computer_outlined,
        category: 'Agent',
        order: 30,
        builder: (_) => LocalLlmSettingsSection(),
      ),
      ownerId: id,
    );

    context.settings.register(
      SettingsContribution(
        id: 'aljabr.settings.agent_security',
        title: 'Agent & Security',
        icon: Icons.security_outlined,
        category: 'Agent',
        order: 40,
        builder: (_) => AgentSecuritySettingsSection(),
      ),
      ownerId: id,
    );

    context.settings.register(
      SettingsContribution(
        id: 'aljabr.settings.skills',
        title: 'Skills',
        icon: Icons.psychology_outlined,
        category: 'Agent',
        order: 50,
        builder: (_) => const SkillsSettingsView(),
      ),
      ownerId: id,
    );
  }

  @override
  Future<void> deactivate() async {}
}
