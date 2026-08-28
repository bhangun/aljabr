import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'permission_tile.dart';
import '../providers/project_settings_provider.dart';
import 'section_widget.dart';

class LocalPermissionsSection extends ConsumerWidget {
  const LocalPermissionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(projectSettingsProvider);

    return Section(
      title: 'Local Permissions',
      subtitle:
          'Inherits from global settings. Local permissions have higher priority. Learn more.',
      child: settings.localPermissions.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No local permissions configured',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            )
          : Column(
              children: settings.localPermissions
                  .map(
                    (permission) => PermissionTile(
                      resource: permission.resource,
                      isAllowed: permission.isAllowed,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
