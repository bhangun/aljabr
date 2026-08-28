import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../models/chat_entry.dart';
import '../../../backend_monitor/screens/backend_monitor_dialog.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radii.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';

class SystemErrorBubble extends ConsumerStatefulWidget {
  final ChatEntry entry;

  const SystemErrorBubble({super.key, required this.entry});

  @override
  ConsumerState<SystemErrorBubble> createState() => _SystemErrorBubbleState();
}

class _SystemErrorBubbleState extends ConsumerState<SystemErrorBubble> {
  bool? _feedbackRating; // true = good, false = bad

  @override
  Widget build(BuildContext context) {
    final isGrpcError = widget.entry.text.toLowerCase().contains('grpc') ||
        widget.entry.text.toLowerCase().contains('connection') ||
        widget.entry.text.toLowerCase().contains('unavailable') ||
        widget.entry.text.toLowerCase().contains('socket');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      constraints: const BoxConstraints(maxWidth: 720),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: Colors.red.shade400.withValues(alpha: 0.35),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error Header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.red.shade900.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadii.md - 1)),
              border: Border(
                bottom: BorderSide(
                    color: Colors.red.shade400.withValues(alpha: 0.25)),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 16, color: Colors.redAccent),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: Text(
                    isGrpcError
                        ? 'Backend Connection Notice (gRPC / API)'
                        : 'System Execution Notice',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.redAccent,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Gap(AppSpacing.sm),
                if (isGrpcError)
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const BackendMonitorDialog(),
                      );
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.panelAlt,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.dns_outlined,
                              size: 12, color: AppTheme.accent),
                          Gap(4),
                          Text(
                            'Open Backend Supervisor',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Error Content (Selectable text)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SelectionArea(
              child: Text(
                widget.entry.text,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  height: 1.4,
                  color: Color(0xFFFFA198),
                ),
              ),
            ),
          ),

          // Action Toolbar: Copy + Feedback (Good/Bad) + Retry
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.panelAlt.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppRadii.md - 1)),
              border: Border(
                top: BorderSide(
                    color: Colors.red.shade400.withValues(alpha: 0.15)),
              ),
            ),
            child: Row(
              children: [
                // Copy Button
                _ActionBtn(
                  icon: Icons.copy_rounded,
                  label: 'Copy Error',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.entry.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error copied to clipboard'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const Gap(AppSpacing.md),

                // Feedback: Good
                _ActionBtn(
                  icon: _feedbackRating == true
                      ? Icons.thumb_up_alt
                      : Icons.thumb_up_alt_outlined,
                  label: 'Helpful',
                  color: _feedbackRating == true
                      ? Colors.green
                      : AppTheme.textMuted,
                  onTap: () {
                    setState(() => _feedbackRating = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for rating this diagnostic!'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const Gap(AppSpacing.sm),

                // Feedback: Bad
                _ActionBtn(
                  icon: _feedbackRating == false
                      ? Icons.thumb_down_alt
                      : Icons.thumb_down_alt_outlined,
                  label: 'Report / Bad',
                  color: _feedbackRating == false
                      ? Colors.orange
                      : AppTheme.textMuted,
                  onTap: () {
                    setState(() => _feedbackRating = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Diagnostic feedback logged for error resolution.'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final clr = color ?? AppTheme.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13.5, color: clr),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: clr,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
