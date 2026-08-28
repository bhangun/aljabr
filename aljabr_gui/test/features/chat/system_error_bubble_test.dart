import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr/features/chat/models/chat_entry.dart';
import 'package:aljabr/features/chat/widgets/chat/system_error_bubble.dart';

void main() {
  testWidgets('SystemErrorBubble displays gRPC notice, copy, and feedback buttons', (tester) async {
    final entry = ChatEntry(
      id: 'err-1',
      type: ChatEntryType.systemMessage,
      status: ChatEntryStatus.failed,
      text: 'io.grpc.StatusRuntimeException: UNAVAILABLE: io exception on 127.0.0.1:8085',
      timestamp: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SystemErrorBubble(entry: entry),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify gRPC header and supervisor shortcut
    expect(find.text('Backend Connection Notice (gRPC / API)'), findsOneWidget);
    expect(find.text('Open Backend Supervisor'), findsOneWidget);

    // Verify copy button
    expect(find.text('Copy Error'), findsOneWidget);

    // Verify feedback buttons
    expect(find.text('Helpful'), findsOneWidget);
    expect(find.text('Report / Bad'), findsOneWidget);

    // Tap on Helpful feedback button
    await tester.tap(find.text('Helpful'));
    await tester.pumpAndSettle();

    expect(find.text('Thank you for rating this diagnostic!'), findsOneWidget);
  });
}
