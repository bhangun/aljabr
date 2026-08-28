import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../coding_agent.dart';
import '../../chat/models/session.dart';
import '../plugins/code_executor_plugin.dart';
import '../plugins/web_search_plugin.dart';
import 'plugin_context.dart';
import '../../chat/models/session.dart';

/// Base interface for all plugins
abstract class AgentPlugin {
  /// Unique identifier for the plugin
  String get id;

  /// Display name
  String get name;

  /// Plugin description
  String get description;

  /// Icon for the plugin
  String get icon;

  /// Process a message before it's sent to the model
  Future<Result<PluginResult>> processInput(PluginContext context);

  /// Process a response after it's received from the model
  Future<Result<PluginResult>> processOutput(PluginContext context);

  /// Get plugin settings UI
  Widget? getSettingsUI();

  /// Whether the plugin is enabled
  bool get enabled => true;
}

/// Result of plugin processing
class PluginResult {
  const PluginResult({
    this.modifiedContent,
    this.metadata = const {},
    this.shouldContinue = true,
  });

  final String? modifiedContent;
  final Map<String, dynamic> metadata;
  final bool shouldContinue;
}

/// Plugin manager
class PluginManager {
  final List<AgentPlugin> _plugins = [];
  final Map<String, PluginResult> _results = {};

  void register(AgentPlugin plugin) {
    if (!_plugins.any((p) => p.id == plugin.id)) {
      _plugins.add(plugin);
    }
  }

  void unregister(String id) {
    _plugins.removeWhere((p) => p.id == id);
  }

  List<AgentPlugin> getPlugins() => List.unmodifiable(_plugins);

  /// Run all plugins on input
  Future<Result<String>> processInput(String content, Session session) async {
    var current = content;
    for (final plugin in _plugins) {
      if (!plugin.enabled) continue;
      final context = PluginContext(current, session, _results);
      final result = await plugin.processInput(context);
      if (result.isFailure) {
        return Failure(result.errorOrNull!);
      }
      final data = result.valueOrNull!;
      if (!data.shouldContinue) {
        break;
      }
      if (data.modifiedContent != null) {
        current = data.modifiedContent!;
      }
      _results[plugin.id] = data;
    }
    return Success(current);
  }

  /// Run all plugins on output
  Future<Result<String>> processOutput(String content, Session session) async {
    var current = content;
    for (final plugin in _plugins) {
      if (!plugin.enabled) continue;
      final context = PluginContext(current, session, _results);
      final result = await plugin.processOutput(context);
      if (result.isFailure) {
        return Failure(result.errorOrNull!);
      }
      final data = result.valueOrNull!;
      if (!data.shouldContinue) {
        break;
      }
      if (data.modifiedContent != null) {
        current = data.modifiedContent!;
      }
      _results[plugin.id] = data;
    }
    return Success(current);
  }
}

/// Singleton provider for plugin manager
final pluginManagerProvider = Provider<PluginManager>((ref) {
  final manager = PluginManager();
  // Register built-in plugins
  manager.register(WebSearchPlugin());
  manager.register(CodeExecutorPlugin());
  return manager;
});
