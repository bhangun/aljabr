import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';
import 'edition.dart';

class ProPluginHost {
  final PluginManager pluginManager;
  final List<AljabrPlugin> proPlugins;

  ProPluginHost({
    required this.pluginManager,
    this.proPlugins = const [],
  });

  Future<void> syncPlugins(AljabrEdition edition) async {
    if (edition.isProOrHigher) {
      for (final plugin in proPlugins) {
        try {
          await pluginManager.activate(plugin);
        } catch (_) {}
      }
    } else {
      for (final plugin in proPlugins) {
        try {
          await pluginManager.deactivate(plugin.metadata.id);
        } catch (_) {}
      }
    }
  }
}
