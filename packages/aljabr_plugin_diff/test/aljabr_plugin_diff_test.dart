import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_plugin_diff/aljabr_plugin_diff.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';

void main() {
  test('DiffPlugin can be instantiated and metadata verified', () {
    final plugin = DiffPlugin();
    expect(plugin.metadata.id, equals('aljabr.diff'));
  });
}
