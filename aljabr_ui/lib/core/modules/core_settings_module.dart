import 'package:flutter/material.dart';
import 'package:aljabr_extension/aljabr_extension.dart';
import '../../features/settings/screens/settings_dialog.dart';

class CoreSettingsModule implements AljabrModule {
  @override
  String get id => 'aljabr.core_settings';

  @override
  Future<void> activate(ModuleContext context) async {
    context.registerSettingsPage(
      SettingsPageContribution(
        id: 'aljabr.settings.appearance',
        ownerId: id,
        title: 'Appearance',
        icon: Icons.palette_outlined,
        section: 'core',
        order: 10,
        builder: (_) => AppearanceSettingsSection(),
      ),
    );

    context.registerSettingsPage(
      SettingsPageContribution(
        id: 'aljabr.settings.browser',
        ownerId: id,
        title: 'Browser',
        icon: Icons.web_asset_outlined,
        section: 'core',
        order: 60,
        builder: (_) => BrowserSettingsSection(),
      ),
    );

    context.registerSettingsPage(
      SettingsPageContribution(
        id: 'aljabr.settings.notifications',
        ownerId: id,
        title: 'Notifications',
        icon: Icons.notifications_none_outlined,
        section: 'core',
        order: 70,
        builder: (_) => NotificationsSettingsSection(),
      ),
    );

    context.registerSettingsPage(
      SettingsPageContribution(
        id: 'aljabr.settings.privacy',
        ownerId: id,
        title: 'Privacy',
        icon: Icons.lock_outline,
        section: 'core',
        order: 80,
        builder: (_) => PrivacySettingsSection(),
      ),
    );

    context.registerSettingsPage(
      SettingsPageContribution(
        id: 'aljabr.settings.advanced',
        ownerId: id,
        title: 'Advanced',
        icon: Icons.tune_outlined,
        section: 'core',
        order: 90,
        builder: (_) => AdvancedSettingsSection(),
      ),
    );
  }

  @override
  Future<void> deactivate() async {}
}
