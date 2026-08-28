import 'package:flutter/material.dart';
import 'package:aljabr_extension/aljabr_extension.dart';
import '../../features/settings/screens/settings_dialog.dart';

class CoreNavigationModule implements AljabrModule {
  @override
  String get id => 'aljabr.navigation';

  @override
  Future<void> activate(ModuleContext context) async {
    context.navigation.registerGroup(BuiltInNavigationGroups.project);
    context.navigation.registerGroup(BuiltInNavigationGroups.workspace);
    context.navigation.registerGroup(BuiltInNavigationGroups.tools);
    context.navigation.registerGroup(BuiltInNavigationGroups.management);

    // Capabilities
    context.registerCapability('aljabr.core.navigation', description: 'Sidebar and multi-region navigation');
    context.registerCapability('aljabr.core.workspace', description: 'Local project and file system integration');

    // Context Contributor
    context.registerContextContributor(
      ContextContribution(
        id: 'aljabr.core.workspace_context',
        ownerId: id,
        contribute: (writer) {
          writer.set(CoreContextKeys.workspaceName, 'wayang-platform');
          writer.set(CoreContextKeys.gitBranch, 'main');
        },
      ),
    );

    context.registerNavigation(
      NavigationContribution(
        id: 'aljabr.history',
        ownerId: id,
        groupId: BuiltInNavigationGroups.workspace.id,
        label: 'Conversation History',
        icon: Icons.history,
        order: 10,
        action: (ctx) {},
      ),
    );

    context.registerNavigation(
      NavigationContribution(
        id: 'aljabr.scheduled',
        ownerId: id,
        groupId: BuiltInNavigationGroups.workspace.id,
        label: 'Scheduled Tasks',
        icon: Icons.schedule,
        order: 20,
        action: (ctx) {},
      ),
    );

    // Activity Bar Contributions (Far Left Rail)
    context.registerActivityBarItem(
      ActivityBarContribution(
        id: 'aljabr.activity.explorer',
        ownerId: id,
        label: 'Explorer',
        icon: Icons.folder_copy_outlined,
        activeIcon: Icons.folder_copy,
        section: ActivityBarSection.primary,
        order: 10,
      ),
    );

    context.registerActivityBarItem(
      ActivityBarContribution(
        id: 'aljabr.activity.history',
        ownerId: id,
        label: 'Timeline & History',
        icon: Icons.history_rounded,
        section: ActivityBarSection.primary,
        order: 20,
      ),
    );

    context.registerActivityBarItem(
      ActivityBarContribution(
        id: 'aljabr.activity.extensions',
        ownerId: id,
        label: 'Extensions & Plugins',
        icon: Icons.extension_outlined,
        activeIcon: Icons.extension,
        section: ActivityBarSection.secondary,
        order: 30,
      ),
    );

    context.registerActivityBarItem(
      ActivityBarContribution(
        id: 'aljabr.activity.settings',
        ownerId: id,
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
    context.registerToolbarItem(
      ToolbarContribution(
        id: 'aljabr.toolbar.logo',
        ownerId: id,
        targetId: ToolbarTargets.app,
        alignment: ToolbarAlignment.start,
        kind: ToolbarItemKind.widget,
        order: 0,
        builder: (ctx) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF238636).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.hub_rounded, size: 16, color: Color(0xFF3FB950)),
            ),
            const SizedBox(width: 8),
            const Text(
              'Aljabr Studio',
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
                border: Border.all(color: const Color(0xFF7928CA).withValues(alpha: 0.4), width: 0.8),
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
    context.registerStatusBarItem(
      StatusBarContribution(
        id: 'aljabr.status.workspace',
        ownerId: id,
        alignment: StatusBarAlignment.start,
        kind: StatusBarItemKind.text,
        icon: Icons.folder_outlined,
        order: 10,
        textBuilder: (status) =>
            status.get(CoreContextKeys.workspaceName) ?? 'wayang-platform',
      ),
    );

    context.registerStatusBarItem(
      StatusBarContribution(
        id: 'aljabr.status.branch',
        ownerId: id,
        alignment: StatusBarAlignment.start,
        kind: StatusBarItemKind.text,
        icon: Icons.account_tree_outlined,
        order: 20,
        textBuilder: (status) =>
            status.get(CoreContextKeys.gitBranch) ?? 'main',
      ),
    );

    context.registerStatusBarItem(
      StatusBarContribution(
        id: 'aljabr.status.encoding',
        ownerId: id,
        alignment: StatusBarAlignment.end,
        kind: StatusBarItemKind.text,
        order: 100,
        textBuilder: (status) => 'UTF-8',
      ),
    );
  }

  @override
  Future<void> deactivate() async {}
}
