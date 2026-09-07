import 'package:flutter/material.dart';
import 'package:aljabr_plugin_mutations/aljabr_plugin_mutations.dart';
import '../models/agent_step.dart';

class AgentStepDetails extends StatelessWidget {
  const AgentStepDetails({super.key, required this.step});
  final AgentStep step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0, bottom: 12.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (step.description != null)
              Text(step.description!,
                  style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (step.type == AgentStepType.fileWrite)
                  TextButton(
                      onPressed: () async {
                        // show mutations panel to inspect evidence
                        // rely on MutationPanel bottom sheet implemented earlier
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (ctx) => const FractionallySizedBox(
                            heightFactor: 0.8,
                            child: MutationPanel(),
                          ),
                        );
                      },
                      child: const Text('View mutations')),
                if (step.type == AgentStepType.fileRead)
                  TextButton(onPressed: () {}, child: const Text('Open file')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
