import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../markdown/widgets/markdown_text.dart';
import '../../models/chat_entry.dart';
import '../../../../theme/app_colors.dart';
import '../../../project/providers/session_actions.dart';

/// Renders a user prompt or agent text entry. Agent text supports a small
/// markdown subset (bold, inline code, bullets, fenced code blocks) via
/// [AgentMarkdownText]; user prompts render as plain text.
class ChatMessageBubble extends ConsumerWidget {
  final ChatEntry entry;
  const ChatMessageBubble({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = entry.type == ChatEntryType.userPrompt;

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                constraints: const BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SelectionArea(
                  child: Text(
                    entry.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _buildActionButton(context, Icons.content_copy, 'Copy', () {
                Clipboard.setData(ClipboardData(text: entry.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 1)),
                );
              }),
            ],
          ),
        ),
      );
    }

    // Agent message — flush left, full width, with markdown
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectionArea(
              child: MarkdownText(text: entry.text),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildActionButton(context, Icons.content_copy, 'Copy', () {
                  Clipboard.setData(ClipboardData(text: entry.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 1)),
                  );
                }),
                const SizedBox(width: 8),
                _buildActionButton(
                    context, Icons.fork_right, 'Fork from this point', () {
                  forkActiveSession(ref, fromMessageId: entry.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Forking session from this message...'),
                        duration: Duration(seconds: 1)),
                  );
                }),
                const SizedBox(width: 8),
                _buildActionButton(context, Icons.thumb_up_outlined, 'Helpful',
                    () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Thank you for your feedback!'),
                        duration: Duration(seconds: 1)),
                  );
                }),
                const SizedBox(width: 8),
                _buildActionButton(
                    context, Icons.thumb_down_outlined, 'Unhelpful', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Feedback recorded to improve responses.'),
                        duration: Duration(seconds: 1)),
                  );
                }),
                if (entry.metadata?.containsKey('metrics') == true) ...[
                  const SizedBox(width: 8),
                  _buildActionButton(context, Icons.bar_chart, 'Metrics', () {
                    _showMetricsDialog(
                        context,
                        entry.metadata!['metrics_raw'] as String? ??
                            'No raw metrics');
                  }),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(icon, size: 16, color: AppTheme.textMuted),
        ),
      ),
    );
  }

  void _showMetricsDialog(BuildContext context, String rawMetrics) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.panel,
        title: const Text('Execution Metrics',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
        content: SingleChildScrollView(
          child: Text(
            rawMetrics,
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close',
                style: TextStyle(color: AppTheme.accentBlue)),
          ),
        ],
      ),
    );
  }
}
