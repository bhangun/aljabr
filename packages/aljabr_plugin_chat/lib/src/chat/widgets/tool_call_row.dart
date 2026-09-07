import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';

/// One expandable row for a [ToolCall]: collapsed shows kind icon, toolchain badge, verb,
/// summary, status dot, and duration; expanded reveals raw input/output
/// with one-click copy and structured logs (Codex/Antigravity/Claude Code style).
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

    String? toolBadge;
    Color badgeColor = AppTheme.accentBlue;
    if (call.summary.toLowerCase().contains('cmake') ||
        call.summary.toLowerCase().contains('clang')) {
      toolBadge = 'CMAKE/C++';
      badgeColor = const Color(0xFF00599C);
    } else if (call.summary.toLowerCase().contains('swift') ||
        call.summary.toLowerCase().contains('xcode')) {
      toolBadge = 'SWIFT';
      badgeColor = const Color(0xFFF05138);
    } else if (call.summary.toLowerCase().contains('sonar') ||
        call.summary.toLowerCase().contains('sarif')) {
      toolBadge = 'SONAR';
      badgeColor = const Color(0xFF4B9FD5);
    } else if (call.summary.toLowerCase().contains('mvn') ||
        call.summary.toLowerCase().contains('java')) {
      toolBadge = 'MAVEN';
      badgeColor = const Color(0xFFE76F00);
    } else if (call.summary.toLowerCase().contains('test')) {
      toolBadge = 'VERIFY';
      badgeColor = const Color(0xFF34C759);
    }

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
            onTap:
                hasDetail ? () => setState(() => _expanded = !_expanded) : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(call.kind.icon, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  if (toolBadge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                            color: badgeColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        toolBadge,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
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
                    Row(
                      children: [
                        const _DetailLabel('INPUT / COMMAND'),
                        const Spacer(),
                        _CopyIconButton(text: call.detailInput!),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _DetailBlock(text: call.detailInput!),
                  ],
                  if (call.detailOutput != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const _DetailLabel('OUTPUT / DIAGNOSTICS'),
                        const Spacer(),
                        _CopyIconButton(text: call.detailOutput!),
                      ],
                    ),
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

class _CopyIconButton extends StatelessWidget {
  final String text;
  const _CopyIconButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copied to clipboard'),
            duration: Duration(milliseconds: 1200),
          ),
        );
      },
      borderRadius: BorderRadius.circular(4),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            Icon(Icons.copy, size: 12, color: AppTheme.textMuted),
            SizedBox(width: 4),
            Text('Copy',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ],
        ),
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
        border: Border.all(color: AppTheme.border),
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
