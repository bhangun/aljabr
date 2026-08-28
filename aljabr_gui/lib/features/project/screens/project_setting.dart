import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/artifact_review_section.dart';
import '../widgets/folder_section.dart';
import '../widgets/local_permission_section.dart';
import '../widgets/outside_folder_section.dart';
import '../widgets/project_header_section.dart';
import '../widgets/provider_feedback_button.dart';
import '../widgets/sandbox_mode_section.dart';
import '../widgets/security_preset_section.dart';
import '../widgets/terminal_execution_section.dart';

class ProjectSettingsScreen extends ConsumerStatefulWidget {
  const ProjectSettingsScreen({super.key});

  @override
  ConsumerState<ProjectSettingsScreen> createState() =>
      _ProjectSettingsScreenState();
}

class _ProjectSettingsScreenState extends ConsumerState<ProjectSettingsScreen> {
  final _folderController = TextEditingController();

  @override
  void dispose() {
    _folderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Settings'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProjectHeaderSection(),
            SizedBox(height: 24),
            FoldersSection(),
            SizedBox(height: 24),
            SecurityPresetSection(),
            SizedBox(height: 24),
            OutsideFoldersSection(),
            SizedBox(height: 24),
            TerminalExecutionSection(),
            SizedBox(height: 24),
            SandboxModeSection(),
            SizedBox(height: 24),
            ArtifactReviewSection(),
            SizedBox(height: 24),
            LocalPermissionsSection(),
            SizedBox(height: 32),
            ProvideFeedbackButton(),
          ],
        ),
      ),
    );
  }
}
