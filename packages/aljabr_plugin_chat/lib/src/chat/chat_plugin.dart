import 'package:flutter/material.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import 'widgets/chat/chat_panel.dart';
import 'providers/chat_transcript_provider.dart';

class ChatPlugin implements AljabrPlugin {
  static const pluginId = 'aljabr.chat';
  static const viewId = 'aljabr.chat.panel';

  @override
  PluginMetadata get metadata => const PluginMetadata(
        id: pluginId,
        name: 'Aljabr AI Coding Agent Chat',
        version: '1.0.0',
        description: 'Interactive conversation, code generation, and agent execution',
      );

  @override
  Future<void> activate(PluginContext context) async {
    registerChatForkCloner();

    context.ui.views.register(
      ViewContribution(
        id: viewId,
        ownerId: pluginId,
        title: 'Agent Chat',
        icon: Icons.chat_bubble_outline,
        preferredPlacement: ViewPlacement.main,
        behavior: ViewBehavior.editor,
        builder: (_) => const ChatPanel(slashCommands: []),
      ),
    );

    context.ui.navigation.register(
      NavigationContribution(
        id: 'aljabr.chat.navigation',
        ownerId: pluginId,
        groupId: BuiltInNavigationGroups.workspace.id,
        label: 'Agent',
        icon: Icons.auto_awesome,
        viewId: viewId,
        order: 100,
        action: (ctx) {},
      ),
    );

    // Activity Bar Secondary: Agent Chat icon
    context.ui.activityBar.register(
      ActivityBarContribution(
        id: 'aljabr.activity.chat',
        ownerId: pluginId,
        label: 'Aljabr Agent',
        icon: Icons.auto_awesome_rounded,
        activeIcon: Icons.auto_awesome,
        section: ActivityBarSection.secondary,
        defaultViewId: viewId,
        order: 15,
      ),
    );

    context.commands.register(
      AppCommand(
        id: 'aljabr.chat.open',
        title: 'Chat: Open AI Coding Assistant',
        category: 'Chat',
        icon: Icons.chat_bubble_outline,
        action: (cmdCtx) {},
      ),
    );

    context.commands.register(
      AppCommand(
        id: 'aljabr.agent.open',
        title: 'Aljabr: Open Agent',
        category: 'Agent',
        icon: Icons.auto_awesome,
        action: (ctx) {},
      ),
    );

    // Toolbar Center: Open Agent quick action
    context.ui.toolbar.register(
      ToolbarContribution(
        id: 'aljabr.agent.toolbar.open',
        ownerId: pluginId,
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
    context.ui.statusBar.register(
      StatusBarContribution(
        id: 'aljabr.status.agent',
        ownerId: pluginId,
        alignment: StatusBarAlignment.center,
        kind: StatusBarItemKind.text,
        icon: Icons.smart_toy_outlined,
        order: 10,
        textBuilder: (status) => 'Aljabr: Idle',
      ),
    );

    // Context Menu: Ask Agent
    context.ui.menus.register(
      MenuContribution(
        id: 'aljabr.chat.askAgent',
        ownerId: pluginId,
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
    context.ui.settings.register(
      SettingsPageContribution(
        id: 'aljabr.settings.ai_provider',
        ownerId: pluginId,
        title: 'AI Provider',
        icon: Icons.smart_toy_outlined,
        section: 'agent',
        order: 20,
        builder: (_) => const Center(
          child: Text('AI Provider Settings',
              style: TextStyle(color: AppTheme.textMuted)),
        ),
      ),
    );

    context.ui.settings.register(
      SettingsPageContribution(
        id: 'aljabr.settings.local_llm',
        ownerId: pluginId,
        title: 'Local LLM',
        icon: Icons.computer_outlined,
        section: 'agent',
        order: 30,
        builder: (_) => const Center(
          child: Text('Local LLM Settings',
              style: TextStyle(color: AppTheme.textMuted)),
        ),
      ),
    );

    context.ui.settings.register(
      SettingsPageContribution(
        id: 'aljabr.settings.agent_security',
        ownerId: pluginId,
        title: 'Agent & Security',
        icon: Icons.security_outlined,
        section: 'agent',
        order: 40,
        builder: (_) => const Center(
          child: Text('Agent & Security Settings',
              style: TextStyle(color: AppTheme.textMuted)),
        ),
      ),
    );

    context.ui.settings.register(
      SettingsPageContribution(
        id: 'aljabr.settings.skills',
        ownerId: pluginId,
        title: 'Skills',
        icon: Icons.psychology_outlined,
        section: 'agent',
        order: 50,
        builder: (_) => const Center(
          child: Text('Skills Settings',
              style: TextStyle(color: AppTheme.textMuted)),
        ),
      ),
    );
  }

  @override
  Future<void> deactivate(PluginContext context) async {}
}
