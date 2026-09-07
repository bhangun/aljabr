import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';
import 'package:aljabr/core/plugins/builtin_plugin_loader.dart';
import 'package:aljabr_coding_pack/aljabr_coding_pack.dart';
import 'package:aljabr/plugins/backend_monitor/backend_monitor_plugin.dart';
import 'package:aljabr/plugins/dashboard/dashboard_plugin.dart';
import 'package:aljabr/plugins/explorer/explorer_plugin.dart';
import 'package:aljabr/plugins/log/log_plugin.dart';
import 'package:aljabr/plugins/marketplace/marketplace_plugin.dart';
import 'package:aljabr/plugins/navigation/navigation_plugin.dart';
import 'package:aljabr/plugins/settings/settings_plugin.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature-as-Plugin Architecture & BuiltInPluginLoader Tests', () {
    late ExtensionRuntime runtime;
    late PluginManager pluginManager;
    late BuiltInPluginLoader loader;

    setUp(() {
      runtime = ExtensionRuntime();
      pluginManager = PluginManager(runtime: runtime);
      loader = BuiltInPluginLoader(pluginManager: pluginManager);
    });

    test('BuiltInPluginLoader activates all 16 built-in feature plugins', () async {
      await loader.loadAll();

      final activeIds = pluginManager.activePlugins.map((p) => p.metadata.id).toSet();

      final expectedPlugins = [
        NavigationPlugin.pluginId,
        SettingsPlugin.pluginId,
        BackendMonitorPlugin.pluginId,
        ChatPlugin.pluginId,
        EditorPlugin.pluginId,
        ExplorerPlugin.pluginId,
        MarketplacePlugin.pluginId,
        TerminalPlugin.pluginId,
        AgentRunPlugin.pluginId,
        CheckpointPlugin.pluginId,
        DiffPlugin.pluginId,
        LogPlugin.pluginId,
        MutationsPlugin.pluginId,
        ProjectPlugin.pluginId,
        DashboardPlugin.pluginId,
        ComposerPlugin.pluginId,
        CodingAgentPluginPack.pluginId,
      ];

      for (final id in expectedPlugins) {
        expect(activeIds.contains(id), isTrue, reason: 'Plugin $id should be active');
      }
      expect(activeIds.length, equals(17));
    });

    test('All contributed views are registered in ViewRegistry', () async {
      await loader.loadAll();

      final views = runtime.views.all.map((v) => v.id).toSet();

      final expectedViewIds = [
        ChatPlugin.viewId,
        EditorPlugin.viewId,
        ExplorerPlugin.viewId,
        MarketplacePlugin.viewId,
        TerminalPlugin.viewId,
        AgentRunPlugin.viewId,
        DiffPlugin.viewId,
        MutationsPlugin.viewId,
        ProjectPlugin.viewId,
        DashboardPlugin.viewId,
        ComposerPlugin.viewId,
      ];

      for (final viewId in expectedViewIds) {
        expect(views.contains(viewId), isTrue, reason: 'View $viewId should be registered');
      }
    });

    test('All key commands from plugins are registered in CommandRegistry', () async {
      await loader.loadAll();

      final commands = runtime.commands.all.map((c) => c.id).toSet();

      expect(commands.contains('aljabr.chat.open'), isTrue);
      expect(commands.contains('aljabr.agent.open'), isTrue);
      expect(commands.contains('aljabr.editor.open'), isTrue);
      expect(commands.contains('aljabr.terminal.toggle'), isTrue);
      expect(commands.contains('aljabr.agent_run.open'), isTrue);
      expect(commands.contains('aljabr.checkpoint.create'), isTrue);
      expect(commands.contains('aljabr.checkpoint.restore'), isTrue);
      expect(commands.contains('aljabr.diff.open'), isTrue);
      expect(commands.contains('aljabr.log.open'), isTrue);
      expect(commands.contains('aljabr.mutations.open'), isTrue);
      expect(commands.contains('aljabr.project.switch'), isTrue);
      expect(commands.contains('aljabr.project.newSession'), isTrue);
      expect(commands.contains('aljabr.dashboard.open'), isTrue);
      expect(commands.contains('aljabr.composer.focus'), isTrue);
    });

    test('Settings pages are registered from SettingsPlugin and ChatPlugin', () async {
      await loader.loadAll();

      final settings = runtime.settings.all.map((s) => s.id).toSet();

      // Core settings
      expect(settings.contains('aljabr.settings.appearance'), isTrue);
      expect(settings.contains('aljabr.settings.browser'), isTrue);
      expect(settings.contains('aljabr.settings.notifications'), isTrue);
      expect(settings.contains('aljabr.settings.privacy'), isTrue);
      expect(settings.contains('aljabr.settings.advanced'), isTrue);

      // Agent settings
      expect(settings.contains('aljabr.settings.ai_provider'), isTrue);
      expect(settings.contains('aljabr.settings.local_llm'), isTrue);
      expect(settings.contains('aljabr.settings.agent_security'), isTrue);
      expect(settings.contains('aljabr.settings.skills'), isTrue);
    });

    test('Navigation groups and items are registered from NavigationPlugin and BackendMonitorPlugin', () async {
      await loader.loadAll();

      final navGroups = runtime.navigation.groups.map((g) => g.id).toSet();
      expect(navGroups.contains('project'), isTrue);
      expect(navGroups.contains('workspace'), isTrue);
      expect(navGroups.contains('tools'), isTrue);
      expect(navGroups.contains('management'), isTrue);

      final navItems = runtime.navigation.all.map((n) => n.id).toSet();
      expect(navItems.contains('aljabr.history'), isTrue);
      expect(navItems.contains('aljabr.scheduled'), isTrue);
      expect(navItems.contains('aljabr.infrastructure'), isTrue);
      expect(navItems.contains('aljabr.enterprise_compliance'), isTrue);
      expect(navItems.contains('aljabr.metrics'), isTrue);
      expect(navItems.contains('aljabr.settings'), isTrue);
    });

    test('Deactivating a plugin unregisters all its contributions cleanly', () async {
      await loader.loadAll();

      expect(runtime.views.all.any((v) => v.id == DiffPlugin.viewId), isTrue);
      expect(runtime.commands.all.any((c) => c.id == 'aljabr.diff.open'), isTrue);

      await pluginManager.deactivate(DiffPlugin.pluginId);

      expect(runtime.views.all.any((v) => v.id == DiffPlugin.viewId), isFalse);
      expect(runtime.commands.all.any((c) => c.id == 'aljabr.diff.open'), isFalse);
    });
  });
}
