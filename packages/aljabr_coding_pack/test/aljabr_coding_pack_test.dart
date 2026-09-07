import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_coding_pack/aljabr_coding_pack.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';

void main() {
  test('CodingAgentPluginPack can be instantiated and bundles all coding plugins', () {
    final pack = CodingAgentPluginPack();
    expect(pack.metadata.id, equals('aljabr.coding_agent_pack'));
    expect(pack.subPlugins.length, equals(9));

    final ids = pack.subPlugins.map((p) => p.metadata.id).toSet();
    expect(ids, containsAll([
      'aljabr.chat',
      'aljabr.editor',
      'aljabr.diff',
      'aljabr.mutations',
      'aljabr.agent_run',
      'aljabr.checkpoint',
      'aljabr.composer',
      'aljabr.terminal',
      'aljabr.project',
    ]));
  });
}
