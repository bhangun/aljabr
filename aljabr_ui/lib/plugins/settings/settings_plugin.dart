import 'package:flutter/material.dart';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import 'screens/settings_dialog.dart';

class SettingsPlugin implements AljabrPlugin {
  static const pluginId = 'aljabr.core_settings';

  @override
  PluginMetadata get metadata => const PluginMetadata(
        id: pluginId,
        name: 'Aljabr Core Settings',
        version: '1.0.0',
        description: 'Core application settings (Appearance, Browser, Notifications, Privacy, Advanced)',
      );

  @override
  Future<void> activate(PluginContext context) async {
    context.ui.settings.register(
      SettingsPageContribution(
        id: 'aljabr.settings.appearance',
        ownerId: pluginId,
        title: 'Appearance',
        icon: Icons.palette_outlined,
        section: 'core',
        order: 10,
        builder: (_) => AppearanceSettingsSection(),
      ),
    );

    context.ui.settings.register(
      SettingsPageContribution(
        id: 'aljabr.settings.browser',
        ownerId: pluginId,
        title: 'Browser',
        icon: Icons.web_asset_outlined,
        section: 'core',
        order: 60,
        builder: (_) => BrowserSettingsSection(),
      ),
    );

    context.ui.settings.register(
      SettingsPageContribution(
        id: 'aljabr.settings.notifications',
        ownerId: pluginId,
        title: 'Notifications',
        icon: Icons.notifications_none_outlined,
        section: 'core',
        order: 70,
        builder: (_) => NotificationsSettingsSection(),
      ),
    );

    context.ui.settings.register(
      SettingsPageContribution(
        id: 'aljabr.settings.privacy',
        ownerId: pluginId,
        title: 'Privacy',
        icon: Icons.lock_outline,
        section: 'core',
        order: 80,
        builder: (_) => PrivacySettingsSection(),
      ),
    );

    context.ui.settings.register(
      SettingsPageContribution(
        id: 'aljabr.settings.advanced',
        ownerId: pluginId,
        title: 'Advanced',
        icon: Icons.tune_outlined,
        section: 'core',
        order: 90,
        builder: (_) => AdvancedSettingsSection(),
      ),
    );
  }

  @override
  Future<void> deactivate(PluginContext context) async {}
}
