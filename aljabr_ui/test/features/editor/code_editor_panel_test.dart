import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr/features/editor/widgets/code_editor_panel.dart';
import 'package:aljabr/features/editor/providers/active_file_provider.dart';
import 'package:aljabr/features/editor/providers/file_buffer_provider.dart';
import 'package:aljabr/features/editor/providers/open_file_provider.dart';

void main() {
  testWidgets('CodeEditorPanel renders empty state when no file is selected',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CodeEditorPanel(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('No File Open'), findsOneWidget);
    expect(find.text('Select a file from the explorer on the left to edit'),
        findsOneWidget);
  });

  testWidgets(
      'CodeEditorPanel renders interactive editor and updates buffer when file is open',
      (tester) async {
    final container = ProviderContainer();
    container.read(openFilesProvider.notifier).open('/tmp/test_file.dart');
    container.read(activeFileProvider.notifier).select('/tmp/test_file.dart');
    container
        .read(fileBufferProvider.notifier)
        .updateContent('/tmp/test_file.dart', 'void main() {}');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: CodeEditorPanel(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify status footer details
    expect(find.text('UTF-8'), findsOneWidget);
    expect(find.text('Spaces: 2'), findsOneWidget);
    expect(find.textContaining('Ln 1, Col 1'), findsOneWidget);
    expect(find.text('Save (⌘S)'), findsOneWidget);

    // Verify editable text field is present
    expect(find.byType(TextField), findsOneWidget);

    // Enter new text into editor
    await tester.enterText(find.byType(TextField), 'int x = 42;\nprint(x);');
    await tester.pumpAndSettle();

    final buffer = container.read(fileBufferProvider)['/tmp/test_file.dart'];
    expect(buffer?.content, 'int x = 42;\nprint(x);');
    expect(buffer?.isDirty, isTrue);
  });
}
