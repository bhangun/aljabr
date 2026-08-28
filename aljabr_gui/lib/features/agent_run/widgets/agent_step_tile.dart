import 'package:flutter/material.dart';
import '../models/agent_step.dart';
import 'agent_step_details.dart';

class AgentStepTile extends StatefulWidget {
  const AgentStepTile({super.key, required this.step, required this.isLast});
  final AgentStep step;
  final bool isLast;

  @override
  State<AgentStepTile> createState() => _AgentStepTileState();
}

class _AgentStepTileState extends State<AgentStepTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final step = widget.step;

    return Column(
      children: [
        InkWell(
          onTap: () {
            if (step.description != null) setState(() => expanded = !expanded);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepIndicator(step: step),
                const SizedBox(width: 12),
                Expanded(child: _StepContent(step: step, expanded: expanded)),
                if (step.duration != null)
                  Text('${step.duration!.inSeconds}s',
                      style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
        if (expanded)
          AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: AgentStepDetails(step: step)),
      ],
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({required this.step, required this.expanded});
  final AgentStep step;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(step.title, style: Theme.of(context).textTheme.bodyMedium),
        if (step.description != null && expanded)
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(step.description!,
                style: Theme.of(context).textTheme.bodySmall),
          ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});
  final AgentStep step;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (step.status) {
      case AgentStepStatus.completed:
        icon = Icons.check;
        color = Colors.green;
        break;
      case AgentStepStatus.running:
        icon = Icons.more_horiz;
        color = Theme.of(context).colorScheme.primary;
        break;
      case AgentStepStatus.failed:
        icon = Icons.priority_high;
        color = Colors.red;
        break;
      case AgentStepStatus.skipped:
        icon = Icons.remove;
        color = Theme.of(context).colorScheme.onSurfaceVariant;
        break;
      case AgentStepStatus.pending:
        icon = Icons.circle_outlined;
        color = Theme.of(context).colorScheme.onSurfaceVariant;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
      child: Icon(icon, size: 14, color: color),
    );
  }
}
