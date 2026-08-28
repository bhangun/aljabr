import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr/core/commands/command_registry.dart';
import 'package:aljabr/core/commands/command_palette_dialog.dart';

void main() {
  testWidgets('CommandPaletteDialog filters commands based on search query', (tester) async {
    final registry = CommandRegistry();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommandPaletteDialog(registry: registry),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('File: Save'), findsOneWidget);
    expect(find.text('Aljabr: Ask Agent'), findsOneWidget);

    // Enter search query
    await tester.enterText(find.byType(TextField), 'Terminal');
    await tester.pumpAndSettle();

    expect(find.text('View: Toggle Integrated Terminal'), findsOneWidget);
    expect(find.text('File: Save'), findsNothing);
  });
}
