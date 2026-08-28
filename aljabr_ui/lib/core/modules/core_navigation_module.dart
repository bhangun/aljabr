import 'package:flutter/material.dart';
import 'package:aljabr_extension/aljabr_extension.dart';

class CoreNavigationModule implements AljabrModule {
  @override
  String get id => 'aljabr.navigation';

  @override
  Future<void> activate(ModuleContext context) async {
    context.navigation.registerGroup(BuiltInNavigationGroups.project);
    context.navigation.registerGroup(BuiltInNavigationGroups.workspace);
    context.navigation.registerGroup(BuiltInNavigationGroups.tools);
    context.navigation.registerGroup(BuiltInNavigationGroups.management);

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
