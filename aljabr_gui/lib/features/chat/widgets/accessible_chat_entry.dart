import 'package:flutter/material.dart';

import '../models/chat_entry.dart';
import '../models/plan_step.dart';

class AccessibleChatEntry extends StatelessWidget {
  final ChatEntry entry;
  final VoidCallback? onTap;

  const AccessibleChatEntry({
    super.key,
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _getSemanticsLabel(entry),
      hint: _getSemanticsHint(entry),
      container: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(entry),
                _buildContent(entry),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSemanticsLabel(ChatEntry entry) {
    switch (entry.type) {
      case ChatEntryType.userPrompt:
        return 'User message: ${entry.text}';
      case ChatEntryType.agentText:
        return 'Agent message: ${entry.text}';
      case ChatEntryType.toolCall:
        return 'Tool call: ${entry.toolCall?.summary}';
      case ChatEntryType.plan:
        return 'Plan: ${entry.plan?.title}';
      default:
        return 'Chat entry: ${entry.type}';
    }
  }

  String _getSemanticsHint(ChatEntry entry) {
    if (entry.status == ChatEntryStatus.pending) {
      return 'This message is pending.';
    }
    if (entry.status == ChatEntryStatus.processing) {
      return 'This message is being processed.';
    }
    if (entry.errorMessage != null) {
      return 'Error: ${entry.errorMessage}';
    }
    return '';
  }

  Widget _buildHeader(ChatEntry entry) {
    return Row(
      children: [
        Icon(
          _getIcon(entry.type),
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          entry.type.toString().split('.').last,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const Spacer(),
        if (entry.status != ChatEntryStatus.completed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(entry.status).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              entry.status.toString().split('.').last,
              style: TextStyle(
                fontSize: 10,
                color: _getStatusColor(entry.status),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            _formatTime(entry.timestamp),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ChatEntry entry) {
    if (entry.text.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(entry.text),
      );
    }
    if (entry.toolCall != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔧 ${entry.toolCall!.summary}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (entry.toolCall!.detailOutput != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(entry.toolCall!.detailOutput!),
                ),
              ),
          ],
        ),
      );
    }
    if (entry.plan != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entry.plan!.steps.map((step) {
            return Row(
              children: [
                Icon(
                  step.status.icon,
                  size: 16,
                  color: step.status.color,
                ),
                const SizedBox(width: 4),
                Text(step.description),
              ],
            );
          }).toList(),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  IconData _getIcon(ChatEntryType type) {
    switch (type) {
      case ChatEntryType.userPrompt:
        return Icons.person_outline;
      case ChatEntryType.agentText:
        return Icons.smart_toy_outlined;
      case ChatEntryType.toolCall:
        return Icons.build_outlined;
      case ChatEntryType.plan:
        return Icons.list_outlined;
      default:
        return Icons.article_outlined;
    }
  }

  Color _getStatusColor(ChatEntryStatus status) {
    switch (status) {
      case ChatEntryStatus.pending:
        return Colors.orange;
      case ChatEntryStatus.processing:
        return Colors.blue;
      case ChatEntryStatus.completed:
        return Colors.green;
      case ChatEntryStatus.failed:
        return Colors.red;
      case ChatEntryStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
