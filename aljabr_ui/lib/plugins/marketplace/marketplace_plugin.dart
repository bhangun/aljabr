import 'package:flutter/material.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import '../plugin/screens/plugin_manager_screen.dart';

class MarketplacePlugin implements AljabrPlugin {
  static const pluginId = 'aljabr.marketplace';
  static const viewId = 'aljabr.marketplace.view';

  @override
  PluginMetadata get metadata => const PluginMetadata(
        id: pluginId,
        name: 'Aljabr Extension Marketplace',
        version: '1.0.0',
        description: 'Discovery and installation of community and pro plugins',
      );

  @override
  Future<void> activate(PluginContext context) async {
    context.ui.views.register(
      ViewContribution(
        id: viewId,
        ownerId: pluginId,
        title: 'Extensions',
        icon: Icons.extension_outlined,
        preferredPlacement: ViewPlacement.sidebar,
        behavior: ViewBehavior.panel,
        builder: (_) => const PluginManagerScreen(),
      ),
    );

    context.ui.activityBar.register(
      ActivityBarContribution(
        id: 'aljabr.activity.extensions',
        ownerId: pluginId,
        label: 'Extensions',
        icon: Icons.extension_outlined,
        activeIcon: Icons.extension,
        section: ActivityBarSection.secondary,
        defaultViewId: viewId,
        order: 40,
      ),
    );
  }

  @override
  Future<void> deactivate(PluginContext context) async {}
}
