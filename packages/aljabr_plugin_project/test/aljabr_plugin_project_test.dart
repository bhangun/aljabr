import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_plugin_project/aljabr_plugin_project.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';

void main() {
  test('ProjectPlugin can be instantiated and metadata verified', () {
    final plugin = ProjectPlugin();
    expect(plugin.metadata.id, equals('aljabr.project'));
  });
}
