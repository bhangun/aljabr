import 'package:aljabr/features/project/providers/active_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr/features/chat/widgets/chat/chat_panel.dart';
import 'package:aljabr/features/chat/providers/chat_transcript_provider.dart';

void main() {
  testWidgets('ChatPanel renders messages', (WidgetTester tester) async {
    final container = ProviderContainer();
    container.read(activeSessionIdProvider.notifier).state = 'test-session';

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: ChatPanel(slashCommands: []),
            ),
          ),
        ),
      ),
    );

    final notifier =
        container.read(chatTranscriptProvider('test-session').notifier);

    notifier.addUserMessage('who are you');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('who are you'), findsOneWidget);

    // Dump the render tree to see sizing
    debugDumpRenderTree();
  });
}
