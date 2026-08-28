import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../theme/app_colors.dart';
import 'markdown_text.dart';

/// Renders a user prompt or agent text entry. Agent text supports a small
/// markdown subset (bold, inline code, bullets, fenced code blocks) via
/// [AgentMarkdownText]; user prompts render as plain text.
class ChatMessageBubble extends StatelessWidget {
  final ChatEntry entry;
  const ChatMessageBubble({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isUser = entry.type == ChatEntryType.userPrompt;

    final content = Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: isUser
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
          : EdgeInsets.zero,
      decoration: isUser
          ? BoxDecoration(
              color: AppTheme.panelAlt,
              borderRadius: BorderRadius.circular(10),
            )
          : null,
      child: isUser
          ? Text(
              entry.text,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14.5,
                height: 1.5,
              ),
            )
          : AgentMarkdownText(text: entry.text),
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: content,
      ),
    );
  }
}

/// Collapsible one-line "Worked for 16s" / "Timed 60 seconds" event row,
/// with a chevron and optional spinner for in-flight steps.
class StepEventRow extends StatefulWidget {
  final ChatEntry entry;
  const StepEventRow({super.key, required this.entry});

  @override
  State<StepEventRow> createState() => _StepEventRowState();
}

class _StepEventRowState extends State<StepEventRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            if (widget.entry.isLoading) ...[
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                widget.entry.text,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
