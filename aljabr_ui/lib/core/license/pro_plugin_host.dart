import 'package:aljabr_plugin_runtime/aljabr_plugin_runtime.dart';
import 'package:aljabr_admin/aljabr_admin.dart';
import 'package:aljabr_analytics/aljabr_analytics.dart';
import 'package:aljabr_audit/aljabr_audit.dart';
import 'package:aljabr_collaboration/aljabr_collaboration.dart';
import 'package:aljabr_governance/aljabr_governance.dart';
import 'edition.dart';

class ProPluginHost {
  final PluginManager pluginManager;

  ProPluginHost({
    required this.pluginManager,
  });

  Future<void> syncPlugins(AljabrEdition edition) async {
    if (edition.isProOrHigher) {
      await _activateProPlugins();
    } else {
      await _deactivateProPlugins();
    }
  }

  Future<void> _activateProPlugins() async {
    final plugins = [
      GovernancePlugin(),
      AdminPlugin(),
      AnalyticsPlugin(),
      AuditPlugin(),
      CollaborationPlugin(),
    ];

    for (final plugin in plugins) {
      try {
        await pluginManager.activate(plugin);
      } catch (_) {}
    }
  }

  Future<void> _deactivateProPlugins() async {
    final pluginIds = [
      'aljabr.pro.governance',
      'aljabr.pro.admin',
      'aljabr.pro.analytics',
      'aljabr.pro.audit',
      'aljabr.pro.collaboration',
    ];

    for (final id in pluginIds) {
      try {
        await pluginManager.deactivate(id);
      } catch (_) {}
    }
  }
}
