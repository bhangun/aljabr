import 'package:flutter/material.dart';
import '../models/agent_step.dart';
import 'agent_step_tile.dart';

class AgentTimeline extends StatelessWidget {
  const AgentTimeline({super.key, required this.steps});
  final List<AgentStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          AgentStepTile(step: steps[i], isLast: i == steps.length - 1),
      ],
    );
  }
}
