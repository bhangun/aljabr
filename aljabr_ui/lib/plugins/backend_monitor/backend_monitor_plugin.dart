import 'package:flutter/material.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import 'screens/backend_monitor_dialog.dart';
import 'screens/enterprise_compliance_dialog.dart';
import '../dashboard/widgets/metric_dashboard.dart';
import '../settings/screens/settings_dialog.dart';

class BackendMonitorPlugin implements AljabrPlugin {
  static const pluginId = 'aljabr.management_tools';

  @override
  PluginMetadata get metadata => const PluginMetadata(
        id: pluginId,
        name: 'Aljabr Management & Infrastructure Tools',
        version: '1.0.0',
        description: 'Backend infrastructure monitoring, enterprise compliance, and system metrics',
      );

  @override
  Future<void> activate(PluginContext context) async {
    context.ui.navigation.register(
      NavigationContribution(
        id: 'aljabr.infrastructure',
        ownerId: pluginId,
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

    context.ui.navigation.register(
      NavigationContribution(
        id: 'aljabr.enterprise_compliance',
        ownerId: pluginId,
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

    context.ui.navigation.register(
      NavigationContribution(
        id: 'aljabr.metrics',
        ownerId: pluginId,
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

    context.ui.navigation.register(
      NavigationContribution(
        id: 'aljabr.settings',
        ownerId: pluginId,
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
    context.ui.toolbar.register(
      ToolbarContribution(
        id: 'aljabr.toolbar.settings',
        ownerId: pluginId,
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

    context.ui.toolbar.register(
      ToolbarContribution(
        id: 'aljabr.toolbar.infrastructure',
        ownerId: pluginId,
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
  Future<void> deactivate(PluginContext context) async {}
}
