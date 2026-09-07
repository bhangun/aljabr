import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_plugin_chat/aljabr_plugin_chat.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';

void main() {
  test('ChatPlugin, ComposerPlugin, CheckpointPlugin can be instantiated and metadata verified', () {
    final chat = ChatPlugin();
    expect(chat.metadata.id, equals('aljabr.chat'));

    final composer = ComposerPlugin();
    expect(composer.metadata.id, equals('aljabr.composer'));

    final checkpoint = CheckpointPlugin();
    expect(checkpoint.metadata.id, equals('aljabr.checkpoint'));
  });
}
