import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_plugin_terminal/aljabr_plugin_terminal.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';

void main() {
  test('TerminalPlugin can be instantiated and metadata verified', () {
    final plugin = TerminalPlugin();
    expect(plugin.metadata.id, equals('aljabr.terminal'));
  });
}
