import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr/features/diff/widgets/change_explanation_card.dart';
import 'package:aljabr/features/chat/models/file_diff.dart';

void main() {
  testWidgets('ChangeExplanationDialog renders breakdown and verification ladder', (tester) async {
    const hunk = DiffHunk(
      id: 'hunk-1',
      header: '@@ -42,4 +42,4 @@',
      lines: [
        DiffLine(type: DiffLineType.deletion, content: 'if (session == null) return null;'),
        DiffLine(type: DiffLineType.addition, content: 'return session?.user;'),
      ],
      status: HunkStatus.pending,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChangeExplanationDialog(
            filePath: 'lib/auth/session_service.dart',
            hunk: hunk,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Why this change?'), findsOneWidget);
    expect(find.text('lib/auth/session_service.dart'), findsOneWidget);
    expect(find.text('Reason'), findsOneWidget);
    expect(find.text('Risk Assessment'), findsOneWidget);
    expect(find.text('Automated Verification Ladder'), findsOneWidget);
    expect(find.text('L0 Static Syntax & AST Parse'), findsOneWidget);
    expect(find.text('L1 Compilation & Type Checker'), findsOneWidget);
    expect(find.text('L2 Targeted Unit Tests'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });
}
