import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_plugin_editor/aljabr_plugin_editor.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';

void main() {
  test('EditorPlugin can be instantiated and metadata verified', () {
    final plugin = EditorPlugin();
    expect(plugin.metadata.id, equals('aljabr.editor'));
  });
}
