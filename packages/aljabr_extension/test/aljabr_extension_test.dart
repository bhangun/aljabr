import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_extension/aljabr_extension.dart';

class _TestModule implements AljabrModule {
  @override
  String get id => 'test.module';

  @override
  Future<void> activate(ModuleContext context) async {
    context.registerCapability('test.capability');

    context.registerView(
      ViewContribution(
        id: 'test.view',
        ownerId: id,
        title: 'Test View',
        preferredPlacement: ViewPlacement.sidebar,
        builder: (_) => const SizedBox(),
      ),
    );

    context.registerActivityBarItem(
      ActivityBarContribution(
        id: 'test.activity',
        ownerId: id,
        label: 'Test Activity',
        icon: Icons.star,
        defaultViewId: 'test.view',
      ),
    );

    context.registerContextContributor(
      ContextContribution(
        id: 'test.context',
        ownerId: id,
        contribute: (writer) {
          writer.set(CoreContextKeys.workspaceName, 'Aljabr-Test');
        },
      ),
    );
  }

  @override
  Future<void> deactivate() async {}
}

class _FailingModule implements AljabrModule {
  @override
  String get id => 'failing.module';

  @override
  Future<void> activate(ModuleContext context) async {
    context.registerCapability('failing.capability');
    // Reference a nonexistent view to trigger validator error
    context.registerActivityBarItem(
      ActivityBarContribution(
        id: 'failing.activity',
        ownerId: id,
        label: 'Failing Activity',
        icon: Icons.error,
        defaultViewId: 'nonexistent.view',
      ),
    );
  }

  @override
  Future<void> deactivate() async {}
}

void main() {
  group('Extensibility Framework & Architecture Tests', () {
    late ModuleManager manager;

    setUp(() {
      manager = ModuleManager();
    });

    test('ModuleManager activates, contributes context, and deactivates module contributions cleanly', () async {
      final module = _TestModule();
      await manager.activate(module);

      expect(manager.capabilities.has('test.capability'), isTrue);
      expect(manager.views.get('test.view'), isNotNull);
      expect(manager.activityBar.get('test.activity'), isNotNull);

      // Context test
      final snapshot = manager.contextService.snapshot();
      expect(snapshot.get(CoreContextKeys.workspaceName), 'Aljabr-Test');

      // Workbench layout test
      manager.workbench.activateActivity('test.activity', defaultViewId: 'test.view');
      expect(manager.workbench.activeActivityId, 'test.activity');
      expect(manager.workbench.layout.activeViewIn(ViewArea.sidebar), 'test.view');

      // Deactivation and rollback
      await manager.deactivate('test.module');
      expect(manager.capabilities.has('test.capability'), isFalse);
      expect(manager.views.get('test.view'), isNull);
      expect(manager.activityBar.get('test.activity'), isNull);
      expect(manager.workbench.layout.locationOf('test.view'), isNull);
    });

    test('ModuleManager rolls back contributions on failed activation', () async {
      final failingModule = _FailingModule();
      var threw = false;

      try {
        await manager.activate(failingModule);
      } catch (e) {
        threw = true;
        expect(e, isA<StateError>());
      }

      expect(threw, isTrue);
      // Should be cleaned up completely
      expect(manager.capabilities.has('failing.capability'), isFalse);
      expect(manager.activityBar.get('failing.activity'), isNull);
    });

    test('PlacedContributionRegistry resolves and orders contributions deterministically', () {
      final registry = ToolbarRegistry();

      registry.register(
        const ToolbarContribution(
          id: 'b.tool',
          ownerId: 'test',
          order: 10,
          alignment: ToolbarAlignment.start,
        ),
      );

      registry.register(
        const ToolbarContribution(
          id: 'a.tool',
          ownerId: 'test',
          order: 10,
          alignment: ToolbarAlignment.start,
        ),
      );

      registry.register(
        const ToolbarContribution(
          id: 'c.tool',
          ownerId: 'test',
          order: 5,
          alignment: ToolbarAlignment.start,
        ),
      );

      const ctx = ToolbarContext(targetId: ToolbarTargets.app);
      final resolved = registry.resolve(ctx, ToolbarAlignment.start);

      expect(resolved.map((c) => c.id).toList(), ['c.tool', 'a.tool', 'b.tool']);
    });

    test('WorkbenchController supports moving and closing views', () {
      final views = ViewRegistry();
      views.register(
        ViewContribution(
          id: 'chat.view',
          ownerId: 'chat',
          title: 'Chat',
          preferredPlacement: ViewPlacement.main,
          builder: (_) => const SizedBox(),
        ),
      );

      final controller = WorkbenchController(views: views);
      controller.openView('chat.view');

      expect(controller.layout.activeViewIn(ViewArea.main), 'chat.view');

      // Move view from main to bottom panel
      controller.moveView('chat.view', ViewArea.bottomPanel);
      expect(controller.layout.activeViewIn(ViewArea.bottomPanel), 'chat.view');
      expect(controller.layout.activeViewIn(ViewArea.main), isNull);

      // Close view
      controller.closeView('chat.view');
      expect(controller.layout.locationOf('chat.view'), isNull);
    });
  });
}
