import 'dart:convert';
import 'dart:io';
import 'extension_manifest.dart';

class DiscoveredPlugin {
  final ExtensionManifest manifest;
  final Directory directory;

  const DiscoveredPlugin({
    required this.manifest,
    required this.directory,
  });
}

class PluginLoader {
  static List<String> get pluginDirectories {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '';

    return [
      '${Directory.current.path}/.aljabr/plugins',
      '${Directory.current.path}/plugins',
      '$home/.aljabr/extensions',
      '$home/.wayang/extensions',
    ];
  }

  static Future<List<DiscoveredPlugin>> scanPlugins() async {
    final discovered = <DiscoveredPlugin>[];

    for (final path in pluginDirectories) {
      final dir = Directory(path);
      if (!dir.existsSync()) continue;

      try {
        final entities = await dir.list().toList();
        for (final entity in entities) {
          if (entity is Directory) {
            final manifestFile = File('${entity.path}/plugin.json');
            if (manifestFile.existsSync()) {
              try {
                final content = await manifestFile.readAsString();
                final json = jsonDecode(content) as Map<String, dynamic>;
                final manifest = ExtensionManifest.fromJson(json);
                discovered.add(
                  DiscoveredPlugin(
                    manifest: manifest,
                    directory: entity,
                  ),
                );
              } catch (_) {}
            }
          }
        }
      } catch (_) {}
    }

    return discovered;
  }
}
