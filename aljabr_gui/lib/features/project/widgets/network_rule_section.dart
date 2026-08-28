import 'package:flutter/material.dart';

import 'section_widget.dart';

class NetworkAccessRulesSection extends StatelessWidget {
  const NetworkAccessRulesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Section(
      title: 'Network Access Rules',
      subtitle: 'Configure allowed and denied URLs for reading.',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ElevatedButton.icon(
          onPressed: () {
            // Navigate to network access rules configuration
          },
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Open'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            elevation: 0,
            minimumSize: const Size(80, 36),
          ),
        ),
      ),
    );
  }
}
