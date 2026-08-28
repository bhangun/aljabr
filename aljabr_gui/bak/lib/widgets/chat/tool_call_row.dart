import 'package:flutter/material.dart';
import '../../models/tool_call.dart';
import '../../theme/app_colors.dart';

/// One expandable row for a [ToolCall]: collapsed shows kind icon, verb,
/// summary, status dot, and duration; expanded reveals the raw
/// input/output the way Codex/Antigravity let you inspect a step.
class ToolCallRow extends StatefulWidget {
  final ToolCall call;
  const ToolCallRow({super.key, required this.call});

  @override
  State<ToolCallRow> createState() => _ToolCallRowState();
}

class _ToolCallRowState extends State<ToolCallRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final call = widget.call;
    final hasDetail = call.detailInput != null || call.detailOutput != null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.panelAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: hasDetail
                ? () => setState(() => _expanded = !_expanded)
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(call.kind.icon, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    call.kind.verb,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      call.summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  if (call.duration != null) ...[
                    Text(
                      '${call.duration!.inSeconds}s',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  _StatusDot(status: call.status),
                  if (hasDetail) ...[
                    const SizedBox(width: 6),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppTheme.textMuted,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_expanded && hasDetail) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (call.detailInput != null) ...[
                    const _DetailLabel('Input'),
                    const SizedBox(height: 4),
                    _DetailBlock(text: call.detailInput!),
                  ],
                  if (call.detailOutput != null) ...[
                    const SizedBox(height: 10),
                    const _DetailLabel('Output'),
                    const SizedBox(height: 4),
                    _DetailBlock(text: call.detailOutput!),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final ToolCallStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == ToolCallStatus.running) {
      return SizedBox(
        width: 11,
        height: 11,
        child: CircularProgressIndicator(strokeWidth: 1.6, color: status.color),
      );
    }
    return Icon(
      status == ToolCallStatus.success ? Icons.check_circle : Icons.error,
      size: 13,
      color: status.color,
    );
  }
}

class _DetailLabel extends StatelessWidget {
  final String label;
  const _DetailLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textMuted,
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  final String text;
  const _DetailBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: SelectableText(
        text,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontFamily: 'monospace',
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }
}
