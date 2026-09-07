import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_plugin_agent_run/aljabr_plugin_agent_run.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';

void main() {
  test('AgentRunPlugin can be instantiated and metadata verified', () {
    final plugin = AgentRunPlugin();
    expect(plugin.metadata.id, equals('aljabr.agent_run'));
  });
}
