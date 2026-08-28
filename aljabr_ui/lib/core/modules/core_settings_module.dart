import 'package:flutter/material.dart';
import 'package:aljabr_extension/aljabr_extension.dart';
import '../../features/settings/screens/settings_dialog.dart';

class CoreSettingsModule implements AljabrModule {
  @override
  String get id => 'aljabr.core_settings';

  @override
  Future<void> activate(ModuleContext context) async {
    context.settings.register(
      SettingsContribution(
        id: 'aljabr.settings.appearance',
        title: 'Appearance',
        icon: Icons.palette_outlined,
        category: 'Core',
        order: 10,
        builder: (_) => AppearanceSettingsSection(),
      ),
      ownerId: id,
    );

    context.settings.register(
      SettingsContribution(
        id: 'aljabr.settings.browser',
        title: 'Browser',
        icon: Icons.web_asset_outlined,
        category: 'Core',
        order: 60,
        builder: (_) => BrowserSettingsSection(),
      ),
      ownerId: id,
    );

    context.settings.register(
      SettingsContribution(
        id: 'aljabr.settings.notifications',
        title: 'Notifications',
        icon: Icons.notifications_none_outlined,
        category: 'Core',
        order: 70,
        builder: (_) => NotificationsSettingsSection(),
      ),
      ownerId: id,
    );

    context.settings.register(
      SettingsContribution(
        id: 'aljabr.settings.privacy',
        title: 'Privacy',
        icon: Icons.lock_outline,
        category: 'Core',
        order: 80,
        builder: (_) => PrivacySettingsSection(),
      ),
      ownerId: id,
    );

    context.settings.register(
      SettingsContribution(
        id: 'aljabr.settings.advanced',
        title: 'Advanced',
        icon: Icons.tune_outlined,
        category: 'Core',
        order: 90,
        builder: (_) => AdvancedSettingsSection(),
      ),
      ownerId: id,
    );
  }

  @override
  Future<void> deactivate() async {}
}
