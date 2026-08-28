import 'package:flutter/material.dart';

class ProvideFeedbackButton extends StatelessWidget {
  const ProvideFeedbackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () {
          // Navigate to feedback
        },
        icon: const Icon(Icons.feedback_outlined, size: 18),
        label: const Text('Provide Feedback'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey[700],
          side: BorderSide(color: Colors.grey[300]!),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
