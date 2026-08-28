import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/danger_zone_section.dart';
import '../widgets/provider_feedback_button.dart';
import '../widgets/rule_section.dart';
import '../widgets/skill_section.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  ConsumerState<ProjectDetailsScreen> createState() =>
      _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkillsSection(),
            SizedBox(height: 24),
            RulesSection(),
            SizedBox(height: 32),
            DangerZoneSection(),
            SizedBox(height: 32),
            ProvideFeedbackButton(),
          ],
        ),
      ),
    );
  }
}
