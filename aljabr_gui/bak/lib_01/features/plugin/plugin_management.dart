// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plugin Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      darkTheme: ThemeData.dark(),
      home: const PluginManagerScreen(),
    );
  }
}

// ============ Models ============
enum PluginType { official, uploaded, custom }

enum PluginStatus { installed, notInstalled, updating, error }

class Plugin {
  final String id;
  final String name;
  final String author;
  final DateTime lastUpdated;
  final String? description;
  final String version;
  final PluginType type;
  final PluginStatus status;
  final String? homepage;
  final String? iconPath;
  final Map<String, dynamic> metadata;
  final List<String> capabilities;
  final bool requiresRestart;

  Plugin({
    required this.id,
    required this.name,
    required this.author,
    required this.lastUpdated,
    this.description,
    this.version = '1.0.0',
    this.type = PluginType.official,
    this.status = PluginStatus.notInstalled,
    this.homepage,
    this.iconPath,
    this.metadata = const {},
    this.capabilities = const [],
    this.requiresRestart = false,
  });

  Plugin copyWith({
    String? id,
    String? name,
    String? author,
    DateTime? lastUpdated,
    String? description,
    String? version,
    PluginType? type,
    PluginStatus? status,
    String? homepage,
    String? iconPath,
    Map<String, dynamic>? metadata,
    List<String>? capabilities,
    bool? requiresRestart,
  }) {
    return Plugin(
      id: id ?? this.id,
      name: name ?? this.name,
      author: author ?? this.author,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      description: description ?? this.description,
      version: version ?? this.version,
      type: type ?? this.type,
      status: status ?? this.status,
      homepage: homepage ?? this.homepage,
      iconPath: iconPath ?? this.iconPath,
      metadata: metadata ?? this.metadata,
      capabilities: capabilities ?? this.capabilities,
      requiresRestart: requiresRestart ?? this.requiresRestart,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'author': author,
    'lastUpdated': lastUpdated.toIso8601String(),
    'description': description,
    'version': version,
    'type': type.toString(),
    'status': status.toString(),
    'homepage': homepage,
    'iconPath': iconPath,
    'metadata': metadata,
    'capabilities': capabilities,
    'requiresRestart': requiresRestart,
  };

  factory Plugin.fromJson(Map<String, dynamic> json) => Plugin(
    id: json['id'],
    name: json['name'],
    author: json['author'],
    lastUpdated: DateTime.parse(json['lastUpdated']),
    description: json['description'],
    version: json['version'] ?? '1.0.0',
    type: PluginType.values.firstWhere(
      (e) => e.toString() == json['type'],
      orElse: () => PluginType.official,
    ),
    status: PluginStatus.values.firstWhere(
      (e) => e.toString() == json['status'],
      orElse: () => PluginStatus.notInstalled,
    ),
    homepage: json['homepage'],
    iconPath: json['iconPath'],
    metadata: json['metadata'] ?? {},
    capabilities: List<String>.from(json['capabilities'] ?? []),
    requiresRestart: json['requiresRestart'] ?? false,
  );

  // Computed properties
  bool get isInstalled => status == PluginStatus.installed;
  bool get isUploaded => type == PluginType.uploaded;
  bool get isOfficial => type == PluginType.official;
  String get formattedDate => _formatDate(lastUpdated);

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// ============ Plugin Repository ============
class PluginRepository {
  final Ref ref;
  List<Plugin> _cache = [];
  bool _initialized = false;

  PluginRepository(this.ref);

  Future<List<Plugin>> getPlugins() async {
    if (!_initialized) {
      await _initialize();
    }
    return _cache;
  }

  Future<void> _initialize() async {
    try {
      // Load from local storage first
      final plugins = await _loadFromStorage();
      if (plugins.isNotEmpty) {
        _cache = plugins;
      } else {
        // Load default plugins
        _cache = _getDefaultPlugins();
        await _saveToStorage(_cache);
      }
    } catch (e) {
      // Fallback to default plugins
      _cache = _getDefaultPlugins();
    }
    _initialized = true;
  }

  List<Plugin> _getDefaultPlugins() {
    return [
      Plugin(
        id: 'pdf-viewer',
        name: 'PDFViewer',
        author: 'Anthropic',
        lastUpdated: DateTime(2026, 7, 15),
        description:
            'View, annotate, and manage PDF documents with advanced features',
        version: '2.3.1',
        homepage: 'https://anthropic.com/plugins/pdf-viewer',
        capabilities: ['view', 'annotate', 'search', 'export'],
        type: PluginType.official,
      ),
      Plugin(
        id: 'reflect',
        name: 'Reflect',
        author: 'Anthropic',
        lastUpdated: DateTime(2026, 7, 15),
        description: 'Reflection and analysis tools for better decision making',
        version: '1.7.0',
        homepage: 'https://anthropic.com/plugins/reflect',
        capabilities: ['analysis', 'reflection', 'decision-support'],
        type: PluginType.official,
      ),
      Plugin(
        id: 'claude-code',
        name: 'Claude Code',
        author: 'Anthropic',
        lastUpdated: DateTime(2026, 7, 15),
        description: 'AI-powered code generation, analysis, and optimization',
        version: '3.1.2',
        homepage: 'https://anthropic.com/plugins/claude-code',
        capabilities: [
          'code-generation',
          'analysis',
          'optimization',
          'debugging',
        ],
        type: PluginType.official,
      ),
      Plugin(
        id: 'time-focus',
        name: 'Time and Focus',
        author: 'Anthropic',
        lastUpdated: DateTime(2026, 7, 14),
        description: 'Time management and focus enhancement tools',
        version: '1.2.0',
        homepage: 'https://anthropic.com/plugins/time-focus',
        capabilities: ['time-tracking', 'focus', 'productivity'],
        type: PluginType.official,
      ),
      Plugin(
        id: 'extensions',
        name: 'Extensions',
        author: 'Anthropic',
        lastUpdated: DateTime(2026, 7, 13),
        description: 'Extend Claude\'s capabilities with custom extensions',
        version: '2.0.1',
        homepage: 'https://anthropic.com/plugins/extensions',
        capabilities: ['extension-management', 'customization'],
        type: PluginType.official,
      ),
    ];
  }

  Future<void> _saveToStorage(List<Plugin> plugins) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/plugins.json');
      final json = jsonEncode(plugins.map((p) => p.toJson()).toList());
      await file.writeAsString(json);
    } catch (e) {
      // Silent fail - we'll use in-memory cache
    }
  }

  Future<List<Plugin>> _loadFromStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/plugins.json');
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((json) => Plugin.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Plugin> addPlugin(Plugin plugin) async {
    _cache = [..._cache, plugin];
    await _saveToStorage(_cache);
    return plugin;
  }

  Future<void> removePlugin(String id) async {
    _cache = _cache.where((p) => p.id != id).toList();
    await _saveToStorage(_cache);
  }

  Future<Plugin> updatePlugin(Plugin plugin) async {
    final index = _cache.indexWhere((p) => p.id == plugin.id);
    if (index != -1) {
      _cache[index] = plugin;
      await _saveToStorage(_cache);
    }
    return plugin;
  }

  Future<void> installPlugin(String id) async {
    final index = _cache.indexWhere((p) => p.id == id);
    if (index != -1) {
      _cache[index] = _cache[index].copyWith(
        status: PluginStatus.installed,
        metadata: {
          ..._cache[index].metadata,
          'installedAt': DateTime.now().toIso8601String(),
        },
      );
      await _saveToStorage(_cache);
    }
  }

  Future<void> uninstallPlugin(String id) async {
    final index = _cache.indexWhere((p) => p.id == id);
    if (index != -1 && _cache[index].isUploaded) {
      _cache[index] = _cache[index].copyWith(
        status: PluginStatus.notInstalled,
        metadata: {
          ..._cache[index].metadata,
          'uninstalledAt': DateTime.now().toIso8601String(),
        },
      );
      await _saveToStorage(_cache);
    }
  }

  Future<List<Plugin>> searchPlugins(String query) async {
    if (query.isEmpty) return _cache;

    final lowerQuery = query.toLowerCase();
    return _cache.where((plugin) {
      return plugin.name.toLowerCase().contains(lowerQuery) ||
          plugin.author.toLowerCase().contains(lowerQuery) ||
          (plugin.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          plugin.capabilities.any((c) => c.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  Future<List<Plugin>> getInstalledPlugins() async {
    return _cache.where((p) => p.isInstalled).toList();
  }

  Future<List<Plugin>> getOfficialPlugins() async {
    return _cache.where((p) => p.isOfficial).toList();
  }

  Future<List<Plugin>> getUploadedPlugins() async {
    return _cache.where((p) => p.isUploaded).toList();
  }

  Future<void> exportPlugin(String id, String filePath) async {
    final plugin = _cache.firstWhere((p) => p.id == id);
    final json = jsonEncode(plugin.toJson());
    final file = File(filePath);
    await file.writeAsString(json);
  }

  Future<Plugin> importPlugin(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final json = jsonDecode(content);
    final plugin = Plugin.fromJson(json);

    // Check if plugin with same ID exists
    final existing = _cache.firstWhere(
      (p) => p.id == plugin.id,
      orElse: () => plugin,
    );
    if (existing.id == plugin.id && _cache.contains(existing)) {
      throw Exception('Plugin with ID ${plugin.id} already exists');
    }

    return await addPlugin(plugin);
  }
}

// ============ Plugin Service ============
class PluginService {
  static const String _pluginsBaseUrl = 'https://api.anthropic.com/plugins';
  final Ref ref;
  final PluginRepository _repository;

  PluginService(this.ref) : _repository = PluginRepository(ref);

  Future<List<Plugin>> fetchAvailablePlugins() async {
    try {
      // Simulate network request
      await Future.delayed(const Duration(milliseconds: 500));

      // In production, this would be a real API call:
      // final response = await http.get(Uri.parse('$_pluginsBaseUrl/available'));
      // final List<dynamic> data = jsonDecode(response.body);

      // For now, return default plugins
      return await _repository.getPlugins();
    } catch (e) {
      throw Exception('Failed to fetch available plugins: $e');
    }
  }

  Future<bool> validatePlugin(Plugin plugin) async {
    // Validate plugin structure
    if (plugin.id.isEmpty || plugin.name.isEmpty || plugin.author.isEmpty) {
      return false;
    }

    // Check for version format
    final versionRegex = RegExp(r'^\d+\.\d+\.\d+$');
    if (!versionRegex.hasMatch(plugin.version)) {
      return false;
    }

    return true;
  }

  Future<void> installPluginFromSource(
    String pluginId, {
    String? sourceUrl,
  }) async {
    try {
      // Update status to installing
      await _repository.updatePlugin(
        (await _repository.getPlugins())
            .firstWhere((p) => p.id == pluginId)
            .copyWith(status: PluginStatus.updating),
      );

      // Simulate installation process
      await Future.delayed(const Duration(seconds: 2));

      // Check compatibility
      final plugin = (await _repository.getPlugins()).firstWhere(
        (p) => p.id == pluginId,
      );
      final compatibility = await _checkCompatibility(plugin);

      if (!compatibility.compatible) {
        throw Exception('Plugin not compatible: ${compatibility.reason}');
      }

      // Install
      await _repository.installPlugin(pluginId);

      // If plugin requires restart, update metadata
      if (plugin.requiresRestart) {
        await _repository.updatePlugin(
          plugin.copyWith(
            metadata: {
              ...plugin.metadata,
              'requiresRestart': true,
              'pendingRestart': true,
            },
          ),
        );
      }
    } catch (e) {
      // Rollback status
      final plugin = (await _repository.getPlugins()).firstWhere(
        (p) => p.id == pluginId,
      );
      await _repository.updatePlugin(
        plugin.copyWith(
          status: PluginStatus.error,
          metadata: {
            ...plugin.metadata,
            'error': e.toString(),
            'errorTime': DateTime.now().toIso8601String(),
          },
        ),
      );
      rethrow;
    }
  }

  Future<CompatibilityResult> _checkCompatibility(Plugin plugin) async {
    // Check platform compatibility
    final platform = Platform.operatingSystem;
    final supportedPlatforms = plugin.metadata['platforms'] ?? ['all'];

    if (!supportedPlatforms.contains(platform) &&
        !supportedPlatforms.contains('all')) {
      return CompatibilityResult(
        compatible: false,
        reason: 'Plugin not supported on $platform',
      );
    }

    // Check version compatibility
    final minVersion = plugin.metadata['minVersion'] ?? '1.0.0';
    final currentVersion = '1.0.0'; // In production, get from app

    if (!_isVersionCompatible(currentVersion, minVersion)) {
      return CompatibilityResult(
        compatible: false,
        reason: 'Plugin requires version $minVersion or higher',
      );
    }

    return CompatibilityResult(compatible: true);
  }

  bool _isVersionCompatible(String current, String required) {
    final currentParts = current.split('.').map(int.parse).toList();
    final requiredParts = required.split('.').map(int.parse).toList();

    for (int i = 0; i < requiredParts.length; i++) {
      if (currentParts[i] < requiredParts[i]) return false;
    }
    return true;
  }

  Future<void> uninstallPlugin(String pluginId) async {
    final plugin = (await _repository.getPlugins()).firstWhere(
      (p) => p.id == pluginId,
    );

    if (!plugin.isUploaded && plugin.isOfficial) {
      // Official plugins can only be uninstalled (not deleted)
      await _repository.uninstallPlugin(pluginId);
    } else {
      // Uploaded plugins can be completely removed
      await _repository.removePlugin(pluginId);
    }
  }

  Future<List<Plugin>> getPluginUpdates() async {
    try {
      // In production, check for updates
      final installed = await _repository.getInstalledPlugins();
      final updated = <Plugin>[];

      for (final plugin in installed) {
        // Simulate update check
        final hasUpdate = plugin.metadata['hasUpdate'] ?? false;
        if (hasUpdate) {
          updated.add(plugin);
        }
      }

      return updated;
    } catch (e) {
      return [];
    }
  }

  Future<void> updatePlugin(String pluginId) async {
    try {
      // In production, download and install update
      await _repository.installPlugin(pluginId);
    } catch (e) {
      throw Exception('Failed to update plugin: $e');
    }
  }
}

class CompatibilityResult {
  final bool compatible;
  final String? reason;

  CompatibilityResult({required this.compatible, this.reason});
}

// ============ Providers ============
final pluginRepositoryProvider = Provider<PluginRepository>((ref) {
  return PluginRepository(ref);
});

final pluginServiceProvider = Provider<PluginService>((ref) {
  return PluginService(ref);
});

final pluginListProvider = FutureProvider<List<Plugin>>((ref) async {
  final repository = ref.watch(pluginRepositoryProvider);
  return await repository.getPlugins();
});

final installedPluginsProvider = FutureProvider<List<Plugin>>((ref) async {
  final repository = ref.watch(pluginRepositoryProvider);
  return await repository.getInstalledPlugins();
});

final officialPluginsProvider = FutureProvider<List<Plugin>>((ref) async {
  final repository = ref.watch(pluginRepositoryProvider);
  return await repository.getOfficialPlugins();
});

final uploadedPluginsProvider = FutureProvider<List<Plugin>>((ref) async {
  final repository = ref.watch(pluginRepositoryProvider);
  return await repository.getUploadedPlugins();
});

final pluginUpdatesProvider = FutureProvider<List<Plugin>>((ref) async {
  final service = ref.watch(pluginServiceProvider);
  return await service.getPluginUpdates();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final selectedPluginIdProvider = StateProvider<String?>((ref) => null);

final filteredPluginsProvider = FutureProvider<List<Plugin>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final repository = ref.watch(pluginRepositoryProvider);

  if (query.isEmpty) {
    return await repository.getPlugins();
  }

  return await repository.searchPlugins(query);
});

final pluginDetailProvider = FutureProvider.family<Plugin?, String>((
  ref,
  id,
) async {
  final plugins = await ref.watch(pluginListProvider.future);
  try {
    return plugins.firstWhere((p) => p.id == id);
  } catch (e) {
    return null;
  }
});

final isInstallingProvider = StateProvider<Set<String>>((ref) => {});

final pluginErrorsProvider = StateProvider<Map<String, String>>((ref) => {});

// ============ Main Screen ============
class PluginManagerScreen extends ConsumerStatefulWidget {
  const PluginManagerScreen({super.key});

  @override
  ConsumerState<PluginManagerScreen> createState() =>
      _PluginManagerScreenState();
}

class _PluginManagerScreenState extends ConsumerState<PluginManagerScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pluginsAsync = ref.watch(filteredPluginsProvider);
    final updatesAsync = ref.watch(pluginUpdatesProvider);
    final query = ref.watch(searchQueryProvider);
    final installing = ref.watch(isInstallingProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, updatesAsync),

            // Search Bar
            _buildSearchBar(context, query),

            // Section Title with updates badge
            _buildSectionTitle(context, pluginsAsync, updatesAsync),

            // Plugin List
            Expanded(
              child: _buildPluginList(context, pluginsAsync, installing),
            ),

            // Bottom Navigation
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AsyncValue<List<Plugin>> updatesAsync,
  ) {
    final hasUpdates = updatesAsync.when(
      data: (updates) => updates.isNotEmpty,
      error: (_, __) => false,
      loading: () => false,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[800]!, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          if (hasUpdates) _buildUpdateBadge(),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Focus search
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showUploadDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsDialog(context),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue[700],
            child: const Icon(Icons.person, size: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateBadge() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Updates',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, String query) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: 'Search plugins...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                  onPressed: () {
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                )
              : _buildFilterButton(),
          filled: true,
          fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildFilterButton() {
    return IconButton(
      icon: const Icon(Icons.filter_list),
      onPressed: () => _showFilterDialog(),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    AsyncValue<List<Plugin>> pluginsAsync,
    AsyncValue<List<Plugin>> updatesAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Plugins',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          pluginsAsync.when(
            data: (plugins) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${plugins.length}',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            loading: () => const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'browse':
                  _showBrowseDialog(context);
                  break;
                case 'refresh':
                  _refreshPlugins();
                  break;
                case 'export':
                  _exportPlugins();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'browse',
                child: Row(
                  children: [
                    Icon(Icons.explore),
                    SizedBox(width: 8),
                    Text('Browse Marketplace'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Export Plugins'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPluginList(
    BuildContext context,
    AsyncValue<List<Plugin>> pluginsAsync,
    Set<String> installing,
  ) {
    return pluginsAsync.when(
      data: (plugins) {
        if (plugins.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: plugins.length,
          itemBuilder: (context, index) {
            final plugin = plugins[index];
            final isInstalling = installing.contains(plugin.id);

            return _buildPluginItem(context, plugin, isInstalling);
          },
        );
      },
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to load plugins',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _refreshPlugins, child: const Text('Retry')),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No plugins found',
            style: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPluginItem(
    BuildContext context,
    Plugin plugin,
    bool isInstalling,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = ref.watch(selectedPluginIdProvider) == plugin.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? Colors.blue[900] : Colors.blue[50])
            : (isDark ? Colors.grey[850] : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: plugin.isUploaded
              ? Colors.orange.withOpacity(0.3)
              : (plugin.status == PluginStatus.error
                    ? Colors.red.withOpacity(0.3)
                    : (isDark ? Colors.grey[800]! : Colors.grey[200]!)),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ListTile(
        leading: _buildPluginIcon(plugin),
        title: Row(
          children: [
            Expanded(
              child: Text(
                plugin.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (plugin.isUploaded) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Uploaded',
                  style: TextStyle(
                    color: Colors.orange[300],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            if (plugin.status == PluginStatus.error) ...[
              const SizedBox(width: 8),
              Icon(Icons.error_outline, color: Colors.red[400], size: 16),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  plugin.author,
                  style: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  plugin.version,
                  style: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  plugin.formattedDate,
                  style: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (plugin.description != null) ...[
              const SizedBox(height: 4),
              Text(
                plugin.description!,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (plugin.capabilities.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: plugin.capabilities.take(3).map((capability) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      capability,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        trailing: isInstalling
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : plugin.isInstalled
            ? _buildInstalledIndicator(plugin)
            : IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showPluginOptions(context, plugin),
              ),
        onTap: () {
          ref.read(selectedPluginIdProvider.notifier).state = plugin.id;
          _showPluginDetails(context, plugin);
        },
        onLongPress: () => _showPluginOptions(context, plugin),
      ),
    );
  }

  Widget _buildPluginIcon(Plugin plugin) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color getColor() {
      if (plugin.isUploaded) return Colors.orange;
      if (plugin.status == PluginStatus.error) return Colors.red;
      return Colors.blue;
    }

    IconData getIcon() {
      if (plugin.isUploaded) return Icons.cloud_upload;
      if (plugin.status == PluginStatus.error) return Icons.error_outline;
      return Icons.extension;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: getColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(getIcon(), color: getColor(), size: 20),
    );
  }

  Widget _buildInstalledIndicator(Plugin plugin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green[300], size: 16),
          const SizedBox(width: 4),
          Text(
            plugin.isUploaded ? 'Uploaded' : 'Installed',
            style: TextStyle(color: Colors.green[300], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabs = ['General', 'Capabilities', 'Time and focus'];
    final icons = [Icons.settings, Icons.tune, Icons.timer];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(tabs.length, (index) {
          return InkWell(
            onTap: () {
              ref.read(selectedPluginIdProvider.notifier).state = null;
              // Navigate to different sections
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icons[index],
                    color: index == 0
                        ? Colors.blue
                        : isDark
                        ? Colors.grey[500]
                        : Colors.grey[600],
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tabs[index],
                    style: TextStyle(
                      color: index == 0
                          ? Colors.blue
                          : isDark
                          ? Colors.grey[500]
                          : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: index == 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============ Dialog Methods ============
  void _showUploadDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            bool isDragging = false;

            return Container(
              padding: const EdgeInsets.all(24),
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Upload local plugin',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange[300]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Make sure you trust a plugin before installing or using it. '
                            'Uploaded plugins are not controlled by Anthropic, and '
                            'Anthropic cannot verify that they will work as intended. '
                            'See each plugin\'s homepage for more information.',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  MouseRegion(
                    onEnter: (_) => setDialogState(() => isDragging = true),
                    onExit: (_) => setDialogState(() => isDragging = false),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDragging
                              ? Colors.blue
                              : (isDark
                                    ? Colors.grey[600]!
                                    : Colors.grey[300]!),
                          style: BorderStyle.solid,
                          width: isDragging ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: isDragging ? Colors.blue.withOpacity(0.1) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isDragging
                                ? Icons.cloud_upload
                                : Icons.cloud_upload_outlined,
                            size: 40,
                            color: isDragging
                                ? Colors.blue
                                : (isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[400]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isDragging
                                ? 'Drop to upload'
                                : 'Drag and drop or click to upload',
                            style: TextStyle(
                              color: isDragging
                                  ? Colors.blue
                                  : (isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[600]),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Supported: .plugin, .json',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[600]
                                  : Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            setDialogState(() => _isLoading = true);

                            // Simulate upload with validation
                            final newPlugin = Plugin(
                              id: 'uploaded-${DateTime.now().millisecondsSinceEpoch}',
                              name:
                                  'Custom Plugin ${DateTime.now().millisecond.toString().padLeft(3, '0')}',
                              author: 'User',
                              lastUpdated: DateTime.now(),
                              description:
                                  'Custom uploaded plugin with advanced features',
                              version: '1.0.0',
                              type: PluginType.uploaded,
                              status: PluginStatus.installed,
                              capabilities: ['custom', 'user-created'],
                              metadata: {
                                'uploadedAt': DateTime.now().toIso8601String(),
                                'source': 'local',
                              },
                            );

                            // Validate plugin
                            final service = ref.read(pluginServiceProvider);
                            final isValid = await service.validatePlugin(
                              newPlugin,
                            );

                            if (!isValid) {
                              throw Exception('Invalid plugin structure');
                            }

                            // Add plugin
                            final repository = ref.read(
                              pluginRepositoryProvider,
                            );
                            await repository.addPlugin(newPlugin);

                            // Refresh list
                            ref.invalidate(pluginListProvider);
                            ref.invalidate(filteredPluginsProvider);

                            Navigator.of(context).pop();

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Plugin uploaded and installed successfully!',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Upload failed: ${e.toString()}'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          } finally {
                            setDialogState(() => _isLoading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Upload'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPluginOptions(BuildContext context, Plugin plugin) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.blue),
              title: const Text('Details'),
              subtitle: Text(plugin.version),
              onTap: () {
                Navigator.pop(context);
                _showPluginDetails(context, plugin);
              },
            ),
            if (!plugin.isInstalled)
              ListTile(
                leading: Icon(Icons.download_outlined, color: Colors.green),
                title: const Text('Install'),
                subtitle: const Text('Install this plugin'),
                onTap: () => _installPlugin(context, plugin),
              ),
            if (plugin.isInstalled && !plugin.isUploaded)
              ListTile(
                leading: Icon(Icons.update, color: Colors.blue),
                title: const Text('Check for Updates'),
                subtitle: const Text('Look for newer versions'),
                onTap: () => _checkForUpdates(context, plugin),
              ),
            if (plugin.isInstalled && plugin.isUploaded)
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Uninstall and Delete'),
                subtitle: const Text('Remove plugin permanently'),
                onTap: () => _uninstallPlugin(context, plugin),
              ),
            if (plugin.isInstalled && !plugin.isUploaded)
              ListTile(
                leading: Icon(
                  Icons.disabled_by_default_outlined,
                  color: Colors.orange,
                ),
                title: const Text('Disable'),
                subtitle: const Text('Disable plugin without uninstalling'),
                onTap: () => _disablePlugin(context, plugin),
              ),
            if (plugin.homepage != null)
              ListTile(
                leading: Icon(Icons.open_in_browser, color: Colors.blue),
                title: const Text('View Homepage'),
                onTap: () => _openHomepage(plugin.homepage!),
              ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.grey),
              title: const Text('Share Plugin'),
              onTap: () => _sharePlugin(plugin),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _installPlugin(BuildContext context, Plugin plugin) async {
    try {
      // Close bottom sheet
      Navigator.pop(context);

      // Show loading
      setState(() => _isLoading = true);

      // Update installing state
      ref.read(isInstallingProvider.notifier).state = {
        ...ref.read(isInstallingProvider),
        plugin.id,
      };

      // Install plugin
      final service = ref.read(pluginServiceProvider);
      await service.installPluginFromSource(plugin.id);

      // Refresh list
      ref.invalidate(pluginListProvider);
      ref.invalidate(filteredPluginsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plugin.name} installed successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () => _showPluginDetails(context, plugin),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Installation failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
      ref.read(isInstallingProvider.notifier).state = ref
          .read(isInstallingProvider)
          .where((id) => id != plugin.id)
          .toSet();
    }
  }

  Future<void> _uninstallPlugin(BuildContext context, Plugin plugin) async {
    final shouldUninstall = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uninstall Plugin'),
        content: Text(
          'Are you sure you want to uninstall "${plugin.name}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Uninstall'),
          ),
        ],
      ),
    );

    if (shouldUninstall != true) return;

    try {
      Navigator.pop(context); // Close bottom sheet

      final service = ref.read(pluginServiceProvider);
      await service.uninstallPlugin(plugin.id);

      ref.invalidate(pluginListProvider);
      ref.invalidate(filteredPluginsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${plugin.name} ${plugin.isUploaded ? "deleted" : "uninstalled"}',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to uninstall: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkForUpdates(BuildContext context, Plugin plugin) async {
    try {
      Navigator.pop(context);

      final service = ref.read(pluginServiceProvider);
      await service.updatePlugin(plugin.id);

      ref.invalidate(pluginListProvider);
      ref.invalidate(pluginUpdatesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plugin updated successfully!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _disablePlugin(BuildContext context, Plugin plugin) async {
    try {
      final updatedPlugin = plugin.copyWith(
        status: PluginStatus.notInstalled,
        metadata: {
          ...plugin.metadata,
          'disabledAt': DateTime.now().toIso8601String(),
        },
      );

      final repository = ref.read(pluginRepositoryProvider);
      await repository.updatePlugin(updatedPlugin);

      ref.invalidate(pluginListProvider);
      ref.invalidate(filteredPluginsProvider);

      Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plugin.name} disabled'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to disable plugin: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPluginDetails(BuildContext context, Plugin plugin) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            _buildPluginIcon(plugin),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                plugin.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Author', plugin.author),
              _buildDetailRow('Version', plugin.version),
              _buildDetailRow('Type', plugin.type.toString().split('.').last),
              _buildDetailRow(
                'Status',
                plugin.status.toString().split('.').last,
              ),
              _buildDetailRow('Last Updated', plugin.formattedDate),
              if (plugin.description != null)
                _buildDetailRow(
                  'Description',
                  plugin.description!,
                  multiline: true,
                ),
              if (plugin.capabilities.isNotEmpty)
                _buildDetailRow('Capabilities', plugin.capabilities.join(', ')),
              if (plugin.metadata.isNotEmpty)
                _buildDetailRow('Metadata', plugin.metadata.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (plugin.homepage != null)
            TextButton(
              onPressed: () => _openHomepage(plugin.homepage!),
              child: const Text('Visit Homepage'),
            ),
          if (!plugin.isInstalled)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _installPlugin(context, plugin);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Install'),
            ),
          if (plugin.isInstalled && plugin.isUploaded)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _uninstallPlugin(context, plugin);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Uninstall'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool multiline = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: multiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
              ),
              maxLines: multiline ? 5 : 1,
              overflow: multiline
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        title: const Text('Filter Plugins'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Plugins'),
              onTap: () {
                ref.read(searchQueryProvider.notifier).state = '';
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified),
              title: const Text('Official'),
              onTap: () {
                ref.read(searchQueryProvider.notifier).state = 'official';
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload),
              title: const Text('Uploaded'),
              onTap: () {
                ref.read(searchQueryProvider.notifier).state = 'uploaded';
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Installed'),
              onTap: () {
                ref.read(searchQueryProvider.notifier).state = 'installed';
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        title: const Text('Plugin Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Plugin Management Settings'),
            const SizedBox(height: 16),
            _buildSettingToggle('Enable Auto-Update', true),
            _buildSettingToggle('Show Beta Plugins', false),
            _buildSettingToggle('Enable Developer Mode', false),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Plugin Storage Location'),
              subtitle: const Text('Change where plugins are stored'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Export All Plugins'),
              subtitle: const Text('Export plugin configuration'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _exportPlugins,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingToggle(String title, bool initialValue) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool value = initialValue;
        return SwitchListTile(
          title: Text(title),
          value: value,
          onChanged: (newValue) {
            setState(() => value = newValue);
          },
        );
      },
    );
  }

  void _showBrowseDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        title: const Text('Plugin Marketplace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Browse official and community plugins in the marketplace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.star),
              title: Text('Featured Plugins'),
              subtitle: Text('Curated plugins from Anthropic'),
            ),
            const ListTile(
              leading: Icon(Icons.trending_up),
              title: Text('Popular Plugins'),
              subtitle: Text('Most downloaded this month'),
            ),
            const ListTile(
              leading: Icon(Icons.new_releases),
              title: Text('New Plugins'),
              subtitle: Text('Recently added'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPlugins() async {
    try {
      final repository = ref.read(pluginRepositoryProvider);
      final plugins = await repository.getPlugins();

      final json = jsonEncode(plugins.map((p) => p.toJson()).toList());
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/plugins_export_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(json);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Export plugin configurations');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plugins exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openHomepage(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open homepage: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sharePlugin(Plugin plugin) async {
    final shareText =
        '''
Plugin: ${plugin.name}
Author: ${plugin.author}
Version: ${plugin.version}
Description: ${plugin.description ?? 'No description'}
Type: ${plugin.type.toString().split('.').last}
Capabilities: ${plugin.capabilities.join(', ')}
${plugin.homepage != null ? 'Homepage: ${plugin.homepage}' : ''}
''';

    await Share.share(shareText, subject: 'Plugin: ${plugin.name}');
  }

  Future<void> _refreshPlugins() async {
    ref.invalidate(pluginListProvider);
    ref.invalidate(filteredPluginsProvider);
    ref.invalidate(installedPluginsProvider);
    ref.invalidate(officialPluginsProvider);
    ref.invalidate(uploadedPluginsProvider);
    ref.invalidate(pluginUpdatesProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refreshing plugins...'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}
