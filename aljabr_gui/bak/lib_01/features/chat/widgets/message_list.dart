import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../coding_agent.dart';

import '../../../presentation/widgets/chat/message_list.dart';
import '../../../presentation/widgets/shared/shared_widgets.dart';
import '../../workspace/widgets/virtual_list.dart';
import '../models/message.dart';

class MessageList extends ConsumerStatefulWidget {
  const MessageList({super.key});

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottomIfNeeded(int count) {
    if (count == _lastMessageCount) return;
    _lastMessageCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider.select((s) => s.messages));
    final lastContentLength = messages.isEmpty
        ? 0
        : messages.last.content.length;

    if (messages.isEmpty) {
      return const EmptyState(
        icon: Icons.code,
        message: 'Start a conversation',
        subtitle:
            'Ask anything about your code, paste files, or describe what you want to build.',
      );
    }

    _scrollToBottomIfNeeded(messages.length * 100000 + lastContentLength);

    // Use virtual list for large conversations
    if (messages.length > 200) {
      return VirtualMessageList<Message>(
        items: messages,
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemBuilder: (context, message, index) {
          return MessageBubble(
            message: message,
            isLast: index == messages.length - 1,
          );
        },
      );
    }

    // Regular list for smaller conversations
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: messages.length,
      itemBuilder: (_, i) =>
          MessageBubble(message: messages[i], isLast: i == messages.length - 1),
    );
  }
}
