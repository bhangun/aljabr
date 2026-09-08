import 'package:flutter/material.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import '../settings/screens/settings_dialog.dart';

class NavigationPlugin implements AljabrPlugin {
  static const pluginId = 'aljabr.navigation';

  @override
  PluginMetadata get metadata => const PluginMetadata(
        id: pluginId,
        name: 'Aljabr Navigation & Shell Framework',
        version: '1.0.0',
        description:
            'Core activity bar, navigation groups, toolbar, and status bar',
      );

  @override
  Future<void> activate(PluginContext context) async {
    context.ui.navigation.registerGroup(BuiltInNavigationGroups.project);
    context.ui.navigation.registerGroup(BuiltInNavigationGroups.workspace);
    context.ui.navigation.registerGroup(BuiltInNavigationGroups.tools);
    context.ui.navigation.registerGroup(BuiltInNavigationGroups.management);

    // Context Contributor
    context.context.register(
      ContextContribution(
        id: 'aljabr.core.workspace_context',
        ownerId: pluginId,
        contribute: (writer) {
          writer.set(CoreContextKeys.workspaceName, 'wayang-platform');
          writer.set(CoreContextKeys.gitBranch, 'main');
        },
      ),
    );

    context.ui.navigation.register(
      NavigationContribution(
        id: 'aljabr.history',
        ownerId: pluginId,
        groupId: BuiltInNavigationGroups.workspace.id,
        label: 'Conversation History',
        icon: Icons.history,
        order: 10,
        action: (ctx) {},
      ),
    );

    context.ui.navigation.register(
      NavigationContribution(
        id: 'aljabr.scheduled',
        ownerId: pluginId,
        groupId: BuiltInNavigationGroups.workspace.id,
        label: 'Scheduled Tasks',
        icon: Icons.schedule,
        order: 20,
        action: (ctx) {},
      ),
    );

    // Activity Bar Contributions
    context.ui.activityBar.register(
      ActivityBarContribution(
        id: 'aljabr.activity.projects',
        ownerId: pluginId,
        label: 'Projects & Sessions',
        icon: Icons.source_outlined,
        activeIcon: Icons.source,
        section: ActivityBarSection.primary,
        order: 5,
      ),
    );

    context.ui.activityBar.register(
      ActivityBarContribution(
        id: 'aljabr.activity.explorer',
        ownerId: pluginId,
        label: 'Explorer',
        icon: Icons.folder_copy_outlined,
        activeIcon: Icons.folder_copy,
        section: ActivityBarSection.primary,
        order: 10,
      ),
    );

    context.ui.activityBar.register(
      ActivityBarContribution(
        id: 'aljabr.activity.history',
        ownerId: pluginId,
        label: 'Timeline & History',
        icon: Icons.history_rounded,
        section: ActivityBarSection.primary,
        order: 20,
      ),
    );

    context.ui.activityBar.register(
      ActivityBarContribution(
        id: 'aljabr.activity.extensions',
        ownerId: pluginId,
        label: 'Extensions & Plugins',
        icon: Icons.extension_outlined,
        activeIcon: Icons.extension,
        section: ActivityBarSection.secondary,
        order: 30,
      ),
    );

    context.ui.activityBar.register(
      ActivityBarContribution(
        id: 'aljabr.activity.settings',
        ownerId: pluginId,
        label: 'Settings',
        icon: Icons.settings_outlined,
        section: ActivityBarSection.bottom,
        order: 100,
        action: (ctx) {
          showDialog(
            context: ctx,
            barrierDismissible: true,
            builder: (_) => const SettingsDialog(),
          );
        },
      ),
    );

    // Global App Toolbar start items
    context.ui.toolbar.register(
      ToolbarContribution(
        id: 'aljabr.toolbar.logo',
        ownerId: pluginId,
        targetId: ToolbarTargets.app,
        alignment: ToolbarAlignment.start,
        kind: ToolbarItemKind.widget,
        order: 0,
        builder: (ctx) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icons/aljabr-logo.png', height: 24),
            const SizedBox(width: 8),
            const Text(
              'Aljabr',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: const Color(0xFF7928CA).withValues(alpha: 0.2),
                border: Border.all(
                    color: const Color(0xFF7928CA).withValues(alpha: 0.4),
                    width: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Color(0xFFD8B4FE),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Global Status Bar items
    context.ui.statusBar.register(
      StatusBarContribution(
        id: 'aljabr.status.workspace',
        ownerId: pluginId,
        alignment: StatusBarAlignment.start,
        kind: StatusBarItemKind.text,
        icon: Icons.folder_outlined,
        order: 10,
        textBuilder: (status) =>
            status.get(CoreContextKeys.workspaceName) ?? 'wayang-platform',
      ),
    );

    context.ui.statusBar.register(
      StatusBarContribution(
        id: 'aljabr.status.branch',
        ownerId: pluginId,
        alignment: StatusBarAlignment.start,
        kind: StatusBarItemKind.text,
        icon: Icons.account_tree_outlined,
        order: 20,
        textBuilder: (status) =>
            status.get(CoreContextKeys.gitBranch) ?? 'main',
      ),
    );

    context.ui.statusBar.register(
      StatusBarContribution(
        id: 'aljabr.status.encoding',
        ownerId: pluginId,
        alignment: StatusBarAlignment.end,
        kind: StatusBarItemKind.text,
        order: 100,
        textBuilder: (status) => 'UTF-8',
      ),
    );
  }

  @override
  Future<void> deactivate(PluginContext context) async {}
}
