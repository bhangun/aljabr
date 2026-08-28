import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';
import 'package:aljabr/core/license/edition.dart';
import 'package:aljabr/core/license/pro_plugin_host.dart';

void main() {
  group('ProPluginHost Integration Tests', () {
    late PluginManager pluginManager;
    late ProPluginHost host;

    setUp(() {
      pluginManager = PluginManager();
      host = ProPluginHost(
        pluginManager: pluginManager,
      );
    });

    test('Activating Pro edition dynamically activates Governance and Pro plugins', () async {
      await host.syncPlugins(AljabrEdition.pro);

      expect(pluginManager.activePlugins.length, 5);
      expect(pluginManager.runtime.views.get('aljabr.pro.governance.dashboard'), isNotNull);
      expect(pluginManager.runtime.activityBar.get('aljabr.activity.governance'), isNotNull);
    });

    test('Switching to Community edition cleanly deactivates Pro plugins', () async {
      // First activate Pro
      await host.syncPlugins(AljabrEdition.pro);
      expect(pluginManager.activePlugins.isNotEmpty, isTrue);

      // Switch to Community
      await host.syncPlugins(AljabrEdition.community);

      expect(pluginManager.activePlugins.isEmpty, isTrue);
      expect(pluginManager.runtime.views.get('aljabr.pro.governance.dashboard'), isNull);
      expect(pluginManager.runtime.activityBar.get('aljabr.activity.governance'), isNull);
    });
  });
}
