import 'package:flutter/material.dart';
import 'package:aljabr_extension/aljabr_extension.dart';
import '../../features/backend_monitor/screens/backend_monitor_dialog.dart';
import '../../features/backend_monitor/screens/enterprise_compliance_dialog.dart';
import '../../features/dashboard/widgets/metric_dashboard.dart';
import '../../features/settings/screens/settings_dialog.dart';

class BackendMonitorModule implements AljabrModule {
  @override
  String get id => 'aljabr.management_tools';

  @override
  Future<void> activate(ModuleContext context) async {
    context.registerNavigation(
      NavigationContribution(
        id: 'aljabr.infrastructure',
        ownerId: id,
        groupId: BuiltInNavigationGroups.management.id,
        label: 'Backend Infrastructure',
        icon: Icons.dns_rounded,
        order: 10,
        action: (ctx) {
          showDialog(
            context: ctx,
            builder: (context) => const BackendMonitorDialog(),
          );
        },
      ),
    );

    context.registerNavigation(
      NavigationContribution(
        id: 'aljabr.enterprise_compliance',
        ownerId: id,
        groupId: BuiltInNavigationGroups.management.id,
        label: 'Enterprise Compliance',
        icon: Icons.verified_user_rounded,
        order: 20,
        action: (ctx) {
          showDialog(
            context: ctx,
            builder: (context) => const EnterpriseComplianceDialog(),
          );
        },
      ),
    );

    context.registerNavigation(
      NavigationContribution(
        id: 'aljabr.metrics',
        ownerId: id,
        groupId: BuiltInNavigationGroups.management.id,
        label: 'Metrics Dashboard',
        icon: Icons.bar_chart,
        order: 30,
        action: (ctx) {
          showDialog(
            context: ctx,
            builder: (context) => const Dialog(
              child: SizedBox(
                width: 900,
                height: 700,
                child: MetricsDashboard(),
              ),
            ),
          );
        },
      ),
    );

    context.registerNavigation(
      NavigationContribution(
        id: 'aljabr.settings',
        ownerId: id,
        groupId: BuiltInNavigationGroups.management.id,
        label: 'Settings',
        icon: Icons.settings_outlined,
        order: 40,
        action: (ctx) {
          showDialog(
            context: ctx,
            barrierDismissible: true,
            builder: (_) => const SettingsDialog(),
          );
        },
      ),
    );

    // End Toolbar items for Settings & Infrastructure
    context.registerToolbarItem(
      ToolbarContribution(
        id: 'aljabr.toolbar.settings',
        ownerId: id,
        targetId: ToolbarTargets.app,
        alignment: ToolbarAlignment.end,
        kind: ToolbarItemKind.action,
        icon: Icons.settings_outlined,
        tooltip: 'Settings',
        order: 90,
        action: (ctx) {
          showDialog(
            context: ctx,
            barrierDismissible: true,
            builder: (_) => const SettingsDialog(),
          );
        },
      ),
    );

    context.registerToolbarItem(
      ToolbarContribution(
        id: 'aljabr.toolbar.infrastructure',
        ownerId: id,
        targetId: ToolbarTargets.app,
        alignment: ToolbarAlignment.end,
        kind: ToolbarItemKind.action,
        icon: Icons.dns_outlined,
        tooltip: 'Backend Infrastructure',
        order: 80,
        action: (ctx) {
          showDialog(
            context: ctx,
            builder: (context) => const BackendMonitorDialog(),
          );
        },
      ),
    );
  }

  @override
  Future<void> deactivate() async {}
}
