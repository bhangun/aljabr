import '../../chat/models/session.dart';
import 'agent_plugin.dart';

/// Context provided to plugins
class PluginContext {
  const PluginContext(this.content, this.session, this.previousResults);

  final String content;
  final Session session;
  final Map<String, PluginResult> previousResults;

  /// Get a value from a previous plugin's result
  dynamic getResult(String pluginId, String key) {
    return previousResults[pluginId]?.metadata[key];
  }

  /// Check if a plugin has run
  bool hasPluginRun(String pluginId) {
    return previousResults.containsKey(pluginId);
  }
}
