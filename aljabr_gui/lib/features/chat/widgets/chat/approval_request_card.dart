import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/framework.dart';
import '../../../project/providers/active_session_provider.dart';
import '../../models/approval_request.dart';
import '../../models/risk_level.dart';

import '../../../../theme/app_colors.dart';
import '../../providers/chat_transcript_provider.dart';

/// Human-in-the-loop gate. Renders inline in the transcript when the agent
/// wants to do something risky; blocks with Approve/Deny until resolved,
/// then collapses to a small resolved-state summary.
class ApprovalRequestCard extends ConsumerWidget {
  final ApprovalRequest request;
  const ApprovalRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final risk = request.risk;
    final resolved = request.status != ApprovalStatus.pending;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: risk.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: risk.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 16, color: risk.color),
              const SizedBox(width: 8),
              Text('Approval needed',
                  style: TextStyle(
                      color: risk.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: risk.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(risk.label,
                    style: TextStyle(
                        color: risk.color,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              request.command,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontFamily: 'monospace',
                  fontSize: 12.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            request.reason,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 12),
          if (resolved)
            _ResolvedBadge(status: request.status)
          else
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => ref
                      .read(chatTranscriptProvider(ref.read(
                              activeSessionIdProvider
                                  as ProviderListenable<String>))
                          .notifier)
                      .resolveApproval(request.id, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.border),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Deny'),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: () => ref
                      .read(chatTranscriptProvider(ref.read(
                              activeSessionIdProvider
                                  as ProviderListenable<String>))
                          .notifier)
                      .resolveApproval(request.id, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: risk.color,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Approve & run'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ResolvedBadge extends StatelessWidget {
  final ApprovalStatus status;
  const _ResolvedBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final approved = status == ApprovalStatus.approved;
    final color = approved ? AppTheme.accentGreen : AppTheme.textMuted;
    return Row(
      children: [
        Icon(approved ? Icons.check_circle : Icons.block,
            size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          approved ? 'Approved — command executed' : 'Denied by user',
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
