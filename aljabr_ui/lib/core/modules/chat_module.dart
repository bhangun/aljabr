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
    context.registerCapability('aljabr.agent.chat', description: 'Autonomous agent chat and interactive reasoning');

    context.registerView(
      ViewContribution(
        id: viewId,
        ownerId: id,
        title: 'Agent',
        icon: Icons.auto_awesome,
        defaultRegion: UiRegion.mainWorkbench,
        builder: (_) => const ChatPanel(),
      ),
    );

    context.registerNavigation(
      NavigationContribution(
        id: 'aljabr.chat.navigation',
        ownerId: id,
        groupId: BuiltInNavigationGroups.workspace.id,
        label: 'Agent',
        icon: Icons.auto_awesome,
        viewId: viewId,
        order: 100,
        action: (ctx) {},
      ),
    );

    // Activity Bar Center: Agent Chat icon
    context.registerActivityBarItem(
      ActivityBarContribution(
        id: 'aljabr.activity.chat',
        ownerId: id,
        title: 'Aljabr Agent',
        icon: Icons.auto_awesome_rounded,
        order: 15,
      ),
    );

    context.registerCommand(
      AppCommand(
        id: 'aljabr.agent.open',
        title: 'Aljabr: Open Agent',
        category: 'Agent',
        icon: Icons.auto_awesome,
        action: (ctx) {},
      ),
    );

    // Toolbar Center: Open Agent quick action
    context.registerToolbarItem(
      ToolbarContribution(
        id: 'aljabr.agent.toolbar.open',
        ownerId: id,
        targetId: ToolbarTargets.app,
        alignment: ToolbarAlignment.center,
        kind: ToolbarItemKind.command,
        commandId: 'aljabr.agent.open',
        icon: Icons.auto_awesome,
        tooltip: 'Open Agent',
        order: 10,
      ),
    );

    // Status Bar Center: Agent State
    context.registerStatusBarItem(
      StatusBarContribution(
        id: 'aljabr.status.agent',
        ownerId: id,
        alignment: StatusBarAlignment.center,
        kind: StatusBarItemKind.text,
        icon: Icons.smart_toy_outlined,
        order: 10,
        textBuilder: (status) => 'Aljabr: Idle',
      ),
    );

    // Context Menu: Ask Agent
    context.registerContextMenuItem(
      MenuContribution(
        id: 'aljabr.chat.askAgent',
        ownerId: id,
        targetId: MenuTargets.editor,
        label: 'Ask Aljabr with Selection',
        icon: Icons.auto_awesome,
        group: 'ai',
        order: 500,
        isVisible: (ctx) => ctx.get(CoreContextKeys.selectionText) != null,
        action: (ctx) {},
      ),
    );

    // Register Agent-related settings contributions
    context.registerSettingsPage(
      SettingsPageContribution(
        id: 'aljabr.settings.ai_provider',
        ownerId: id,
        title: 'AI Provider',
        icon: Icons.smart_toy_outlined,
        section: 'agent',
        order: 20,
        builder: (_) => AiProviderSettingsSection(),
      ),
    );

    context.registerSettingsPage(
      SettingsPageContribution(
        id: 'aljabr.settings.local_llm',
        ownerId: id,
        title: 'Local LLM',
        icon: Icons.computer_outlined,
        section: 'agent',
        order: 30,
        builder: (_) => LocalLlmSettingsSection(),
      ),
    );

    context.registerSettingsPage(
      SettingsPageContribution(
        id: 'aljabr.settings.agent_security',
        ownerId: id,
        title: 'Agent & Security',
        icon: Icons.security_outlined,
        section: 'agent',
        order: 40,
        builder: (_) => AgentSecuritySettingsSection(),
      ),
    );

    context.registerSettingsPage(
      SettingsPageContribution(
        id: 'aljabr.settings.skills',
        ownerId: id,
        title: 'Skills',
        icon: Icons.psychology_outlined,
        section: 'agent',
        order: 50,
        builder: (_) => const SkillsSettingsView(),
      ),
    );
  }

  @override
  Future<void> deactivate() async {}
}
