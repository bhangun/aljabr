import 'package:flutter/material.dart';
import '../../models/chat_entry.dart';
import '../../../../theme/app_colors.dart';
import '../../../markdown/widgets/markdown_text.dart';

/// Collapsible thinking/reasoning bubble — shown for models that emit
/// internal scratch/reasoning before the final answer.
///
/// Behaviour:
///  - While [ChatEntryStatus.processing]: auto-expanded, header pulses blue.
///  - When [ChatEntryStatus.completed]: collapsed by default, user can expand.
class ThinkingBubble extends StatefulWidget {
  final ChatEntry entry;
  const ThinkingBubble({super.key, required this.entry});

  @override
  State<ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<ThinkingBubble>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    // Auto-expand while processing
    _expanded = widget.entry.status == ChatEntryStatus.processing;

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(ThinkingBubble old) {
    super.didUpdateWidget(old);
    // Collapse and stop pulsing once processing finishes
    if (old.entry.status == ChatEntryStatus.processing &&
        widget.entry.status == ChatEntryStatus.completed) {
      _pulseCtrl.stop();
      setState(() => _expanded = false);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  String get _tokenCount {
    final words = widget.entry.text.trim().split(RegExp(r'\s+'));
    return '~${words.length} tokens';
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = widget.entry.status == ChatEntryStatus.processing;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.panelAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isProcessing
              ? AppTheme.accentBlue.withAlpha(100)
              : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── header row ────────────────────────────────────────────────────
          InkWell(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            onTap: widget.entry.text.trim().isEmpty
                ? null
                : () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  if (isProcessing)
                    FadeTransition(
                      opacity: _pulseAnim,
                      child: const Icon(
                        Icons.psychology_outlined,
                        size: 16,
                        color: AppTheme.accentBlue,
                      ),
                    )
                  else
                    const Icon(
                      Icons.psychology_outlined,
                      size: 16,
                      color: AppTheme.textMuted,
                    ),
                  const SizedBox(width: 8),
                  if (isProcessing)
                    FadeTransition(
                      opacity: _pulseAnim,
                      child: const Text(
                        'Thinking…',
                        style: TextStyle(
                          color: AppTheme.accentBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Reasoned · $_tokenCount',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  const Spacer(),
                  if (widget.entry.text.trim().isNotEmpty)
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppTheme.textMuted,
                    ),
                ],
              ),
            ),
          ),
          // ── expandable body ───────────────────────────────────────────────
          if (_expanded && widget.entry.text.trim().isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppTheme.border),
                ),
              ),
              child: MarkdownText(text: widget.entry.text),
            ),
        ],
      ),
    );
  }
}
