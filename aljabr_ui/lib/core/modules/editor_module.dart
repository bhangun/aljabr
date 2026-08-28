import 'package:flutter/material.dart';
import 'package:aljabr_extension/aljabr_extension.dart';
import '../../features/editor/widgets/editor_panel_shell.dart';

class EditorModule implements AljabrModule {
  @override
  String get id => 'aljabr.editor';

  @override
  Future<void> activate(ModuleContext context) async {
    context.views.register(
      ViewContribution(
        id: 'aljabr.editor.panel',
        title: 'Editor',
        icon: Icons.code,
        defaultRegion: UiRegion.mainWorkbench, // Both chat and editor are main for now
        builder: (_) => const EditorPanelShell(),
      ),
      ownerId: id,
    );
  }

  @override
  Future<void> deactivate() async {}
}
