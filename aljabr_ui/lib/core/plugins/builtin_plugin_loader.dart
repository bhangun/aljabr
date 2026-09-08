import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';
import 'package:aljabr_coding_pack/aljabr_coding_pack.dart';
import '../../plugins/backend_monitor/backend_monitor_plugin.dart';
import '../../plugins/dashboard/dashboard_plugin.dart';
import '../../plugins/log/log_plugin.dart';
import '../../plugins/marketplace/marketplace_plugin.dart';
import '../../plugins/navigation/navigation_plugin.dart';
import '../../plugins/settings/settings_plugin.dart';
import '../../plugins/explorer/explorer_plugin.dart';
import '../../widgets/sidebar/sidebar_widget.dart';
import '../commands/workbench_commands.dart';

/// Central bootstrapper for the Workbench Platform.
/// Loads agnostic platform core plugins and modular domain plugin packs.
class BuiltInPluginLoader {
  final PluginManager pluginManager;
  final List<AljabrPlugin>? domainPluginPacks;

  BuiltInPluginLoader({
    required this.pluginManager,
    this.domainPluginPacks,
  });

  /// The neutral, agnostic platform plugins that form the Workbench Foundation:
  /// Navigation & Shell, Settings, Plugin Store, Telemetry & Diagnostics, Infrastructure.
  static List<AljabrPlugin> get platformCorePlugins => [
        NavigationPlugin(),
        SettingsPlugin(),
        MarketplacePlugin(),
        DashboardPlugin(),
        BackendMonitorPlugin(),
        LogPlugin(),
        ExplorerPlugin(),
      ];

  /// Default domain plugin packs (Coding Agent Suite).
  static List<AljabrPlugin> get defaultDomainPacks => [
        CodingAgentPluginPack(
          vibeSidebarBuilder: (context) => const SidebarWidget(),
        ),
      ];

  Future<void> loadAll() async {
    // 1. Load Neutral Workbench Platform Core Plugins
    for (final plugin in platformCorePlugins) {
      try {
        await pluginManager.activate(plugin);
      } catch (_) {}
    }

    // 2. Load Domain Plugin Packs (e.g. Coding Agent Pack, Low-Code Pack, etc.)
    final packs = domainPluginPacks ?? defaultDomainPacks;
    for (final pack in packs) {
      try {
        await pluginManager.activate(pack);
        if (pack is CodingAgentPluginPack) {
          for (final subPlugin in pack.subPlugins) {
            try {
              await pluginManager.activate(subPlugin);
            } catch (_) {}
          }
        }
      } catch (_) {}
    }

    // 3. Register workbench commands
    WorkbenchCommands.registerAll(
      commandRegistry: pluginManager.runtime.commands,
      workbench: pluginManager.runtime.workbench,
      workspaceModeController: pluginManager.runtime.workspaceModeController,
    );
  }
}
