import 'package:flutter/material.dart';
import 'package:aljabr_extension/aljabr_extension.dart';
import '../../features/editor/widgets/editor_panel_shell.dart';

class EditorModule implements AljabrModule {
  @override
  String get id => 'aljabr.editor';

  @override
  Future<void> activate(ModuleContext context) async {
    context.registerCapability('aljabr.core.editor', description: 'Core multi-tab code editor');

    context.registerView(
      ViewContribution(
        id: 'aljabr.editor.panel',
        ownerId: id,
        title: 'Editor',
        icon: Icons.code,
        preferredPlacement: ViewPlacement.main,
        behavior: ViewBehavior.editor,
        builder: (_) => const EditorPanelShell(),
      ),
    );

    // Editor Context Menu items (Copy, Format, Ask)
    context.registerContextMenuItem(
      MenuContribution(
        id: 'aljabr.editor.copy',
        ownerId: id,
        targetId: MenuTargets.editor,
        label: 'Copy',
        icon: Icons.copy_outlined,
        group: 'clipboard',
        order: 100,
        action: (ctx) {},
      ),
    );

    context.registerContextMenuItem(
      MenuContribution(
        id: 'aljabr.editor.format',
        ownerId: id,
        targetId: MenuTargets.editor,
        label: 'Format Document',
        icon: Icons.format_align_left_rounded,
        group: 'edit',
        order: 200,
        action: (ctx) {},
      ),
    );
  }

  @override
  Future<void> deactivate() async {}
}
