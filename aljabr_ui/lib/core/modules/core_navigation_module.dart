import 'package:aljabr_extension/aljabr_extension.dart';

class CoreNavigationModule implements AljabrModule {
  @override
  String get id => 'aljabr.navigation';

  @override
  Future<void> activate(ModuleContext context) async {
    context.navigation.registerGroup(BuiltInNavigationGroups.project);
    context.navigation.registerGroup(BuiltInNavigationGroups.workspace);
    context.navigation.registerGroup(BuiltInNavigationGroups.tools);
    context.navigation.registerGroup(BuiltInNavigationGroups.management);
  }

  @override
  Future<void> deactivate() async {}
}
