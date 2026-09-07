import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aljabr_coding_core/aljabr_coding_core.dart';
import '../../providers/agent_runtime_provider.dart';
import '../../providers/chat_transcript_provider.dart';
import '../../providers/model_agent_providers.dart';
import '../step_even_row.dart';
import 'approval_request_card.dart';
import 'chat_message_bubble.dart';
import 'system_error_bubble.dart';
import 'thinking_bubble.dart';
import 'search_bubble.dart';
import '../plan_card.dart';
import '../scroll_to_bottom.dart';
import '../tool_call_row.dart';

/// Scrollable chat transcript with auto-scroll behavior
class ChatTranscript extends ConsumerStatefulWidget {
  final String sessionId;
  final List<ChatEntry> entries;

  const ChatTranscript({
    super.key,
    required this.sessionId,
    required this.entries,
  });

  @override
  ConsumerState<ChatTranscript> createState() => _ChatTranscriptState();
}

class _ChatTranscriptState extends ConsumerState<ChatTranscript> {
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final isAtBottom = currentScroll >= maxScroll - 20;
    if (_isAtBottom != isAtBottom) {
      setState(() => _isAtBottom = isAtBottom);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(chatTranscriptProvider(widget.sessionId));

    // Auto-scroll on new entries
    ref.listen(chatTranscriptProvider(widget.sessionId), (previous, next) {
      if (next.length > (previous?.length ?? 0)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    // Listen for server events
    ref.listen(agentEventsProvider(widget.sessionId), (previous, next) {
      final entry = next.value;
      if (entry == null) return;
      if (!ref.read(agentRunningProvider)) return;
      final notifier =
          ref.read(chatTranscriptProvider(widget.sessionId).notifier);
      notifier.appendEntry(entry);

      if (entry.id == 'live-tc1') {
        notifier.updatePlanStepStatus('plan1', 'p4', PlanStepStatus.done);
      }
    });

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
          itemCount: entries.length,
          itemBuilder: (context, i) => KeyedSubtree(
            key: ValueKey(entries[i].id),
            child: _buildEntry(entries[i]),
          ),
        ),
        if (!_isAtBottom && entries.isNotEmpty)
          Positioned(
            bottom: 16,
            right: 16,
            child: ScrollToBottomButton(onTap: _scrollToBottom),
          ),
      ],
    );
  }

  Widget _buildEntry(ChatEntry entry) {
    try {
      switch (entry.type) {
        case ChatEntryType.stepEvent:
          return StepEventRow(entry: entry);
        case ChatEntryType.toolCall:
          if (entry.toolCall == null) return const SizedBox.shrink();
          return ToolCallRow(
            call: entry.toolCall!,
          );
        case ChatEntryType.approvalRequest:
          if (entry.approval == null) return const SizedBox.shrink();
          return ApprovalRequestCard(
            request: entry.approval!,
          );
        case ChatEntryType.plan:
          if (entry.plan == null) return const SizedBox.shrink();
          return PlanCard(
            plan: entry.plan!,
          );
        case ChatEntryType.thinking:
          return ThinkingBubble(entry: entry);
        case ChatEntryType.search:
          return SearchBubble(entry: entry);
        case ChatEntryType.userPrompt:
        case ChatEntryType.agentText:
          return ChatMessageBubble(entry: entry);
        case ChatEntryType.attachment:
          return const SizedBox.shrink();
        case ChatEntryType.systemMessage:
          return SystemErrorBubble(entry: entry);
      }
    } catch (e) {
      logDebug('CHAT UI ERROR: _buildEntry failed for entry ${entry.id}: $e');
      return Text('Error rendering message: $e',
          style: const TextStyle(color: Colors.red));
    }
  }
}
