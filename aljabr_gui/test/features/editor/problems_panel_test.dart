import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr/features/editor/widgets/problems_panel.dart';
import 'package:aljabr/features/editor/widgets/editor_panel_shell.dart';

void main() {
  testWidgets('ProblemsPanel displays diagnostics and category filter chips',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ProblemsPanel(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify summary badges
    expect(find.text('Errors'), findsOneWidget);
    expect(find.text('Warnings'), findsOneWidget);
    expect(find.text('Info'), findsOneWidget);

    // Verify filter chips
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
    expect(find.text('Code Smell'), findsOneWidget);

    // Verify sample problems rendered
    expect(find.text('java:S1135'), findsOneWidget);
    expect(find.text('CWE-798'), findsOneWidget);
  });

  testWidgets('EditorPanelShell renders Problems tab and switches views',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: EditorPanelShell(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Code'), findsOneWidget);
    expect(find.text('Diff'), findsOneWidget);
    expect(find.text('Terminal'), findsOneWidget);
    expect(find.text('Problems'), findsOneWidget);

    // Tap on Problems tab
    await tester.tap(find.text('Problems'));
    await tester.pumpAndSettle();

    expect(find.byType(ProblemsPanel), findsOneWidget);
  });
}
