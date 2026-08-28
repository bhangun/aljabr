import 'package:flutter_test/flutter_test.dart';
import 'package:aljabr_extension/aljabr_extension.dart';

class SampleModule implements AljabrModule {
  @override
  String get id => 'test.module';

  @override
  Future<void> activate(ModuleContext context) async {
    context.registerCommand(
      AppCommand(
        id: 'test.command',
        title: 'Test Command',
        category: 'Testing',
      ),
    );
  }

  @override
  Future<void> deactivate() async {}
}

void main() {
  test('ModuleManager activates and deactivates module contributions', () async {
    final manager = ModuleManager();
    final module = SampleModule();

    await manager.activate(module);
    expect(manager.commands.get('test.command'), isNotNull);

    await manager.deactivate(module.id);
    expect(manager.commands.get('test.command'), isNull);
  });
}
