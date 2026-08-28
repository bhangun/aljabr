// SessionControlBar widget for quick actions
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../project/models/session_mode.dart';
import '../../project/models/session_statusx.dart';
import '../../project/providers/session_actions.dart';
import '../providers/chat_transcript_provider.dart';
import '../providers/session_provider.dart';

class SessionControlBar extends ConsumerWidget {
  final String sessionId;

  const SessionControlBar({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final notifier = ref.read(chatTranscriptProvider(sessionId).notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: session.status.color,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            session.status.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: session.status.color,
            ),
          ),
          const Spacer(),
          // Mode selector
          DropdownButton<SessionMode>(
            value: session.mode,
            items: SessionMode.values.map((mode) {
              return DropdownMenuItem(
                value: mode,
                child: Text(mode.toString().split('.').last),
              );
            }).toList(),
            onChanged: (mode) {
              if (mode != null) {
                notifier.toggleSessionMode(mode);
              }
            },
          ),
          const SizedBox(width: 12),
          // Pause/Resume
          IconButton(
            icon: Icon(
              session.status == SessionStatus.paused
                  ? Icons.play_arrow
                  : Icons.pause,
            ),
            onPressed: () => toggleSessionPause(ref, sessionId),
            tooltip:
                session.status == SessionStatus.paused ? 'Resume' : 'Pause',
          ),
          // Cancel
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () => cancelAllPending(ref, sessionId),
            tooltip: 'Cancel All Pending',
          ),
        ],
      ),
    );
  }
}
