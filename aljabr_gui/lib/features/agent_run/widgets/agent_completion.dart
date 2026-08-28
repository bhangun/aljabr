import 'package:flutter/material.dart';

class AgentRunSummary {
  final int filesChanged;
  final int testsAdded;
  final int testsPassed;
  final int testsFailed;

  const AgentRunSummary(
      {this.filesChanged = 0,
      this.testsAdded = 0,
      this.testsPassed = 0,
      this.testsFailed = 0});
}

class AgentCompletion extends StatelessWidget {
  const AgentCompletion({super.key, required this.summary});
  final AgentRunSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text('Completed', style: Theme.of(context).textTheme.titleMedium)
          ]),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Files changed', value: '${summary.filesChanged}'),
          _SummaryRow(label: 'Tests added', value: '${summary.testsAdded}'),
          _SummaryRow(label: 'Tests passed', value: '${summary.testsPassed}'),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.bodySmall)
        ],
      ),
    );
  }
}
