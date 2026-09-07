import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('aljabr_coding_core models can be instantiated', () {
    final entry = ChatEntry(
      id: 'test_entry',
      type: ChatEntryType.userPrompt,
      status: ChatEntryStatus.completed,
      text: 'Hello Aljabr',
      timestamp: DateTime.now(),
    );

    expect(entry.id, equals('test_entry'));
    expect(entry.text, equals('Hello Aljabr'));

    final project = Project(
      id: 'proj_1',
      name: 'Wayang Platform',
      rootPath: '/workspace',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    expect(project.id, equals('proj_1'));
    expect(project.name, equals('Wayang Platform'));
  });
}
