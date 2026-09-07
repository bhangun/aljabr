import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_plugin_mutations/aljabr_plugin_mutations.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';

void main() {
  test('MutationsPlugin can be instantiated and metadata verified', () {
    final plugin = MutationsPlugin();
    expect(plugin.metadata.id, equals('aljabr.mutations'));
  });
}
