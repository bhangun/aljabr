// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

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
enum PluginType { official, marketplace, uploaded, repository }

enum PluginStatus { installed, notInstalled, updating, error, pendingRestart }

enum MarketplaceSource { anthropic, github, git, custom }

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
  final String? repositoryUrl;
  final String? marketplaceId;
  final int downloads;
  final double rating;
  final List<String> screenshots;
  final List<String> tags;

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
    this.repositoryUrl,
    this.marketplaceId,
    this.downloads = 0,
    this.rating = 0.0,
    this.screenshots = const [],
    this.tags = const [],
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
    String? repositoryUrl,
    String? marketplaceId,
    int? downloads,
    double? rating,
    List<String>? screenshots,
    List<String>? tags,
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
      repositoryUrl: repositoryUrl ?? this.repositoryUrl,
      marketplaceId: marketplaceId ?? this.marketplaceId,
      downloads: downloads ?? this.downloads,
      rating: rating ?? this.rating,
      screenshots: screenshots ?? this.screenshots,
      tags: tags ?? this.tags,
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
    'repositoryUrl': repositoryUrl,
    'marketplaceId': marketplaceId,
    'downloads': downloads,
    'rating': rating,
    'screenshots': screenshots,
    'tags': tags,
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
    repositoryUrl: json['repositoryUrl'],
    marketplaceId: json['marketplaceId'],
    downloads: json['downloads'] ?? 0,
    rating: (json['rating'] ?? 0.0).toDouble(),
    screenshots: List<String>.from(json['screenshots'] ?? []),
    tags: List<String>.from(json['tags'] ?? []),
  );

  bool get isInstalled =>
      status == PluginStatus.installed || status == PluginStatus.pendingRestart;
  bool get isUploaded => type == PluginType.uploaded;
  bool get isOfficial => type == PluginType.official;
  bool get isMarketplace => type == PluginType.marketplace;
  bool get isFromRepository => type == PluginType.repository;

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

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

  String get formattedDownloads {
    if (downloads >= 1000000) {
      return '${(downloads / 1000000).toStringAsFixed(1)}M';
    } else if (downloads >= 1000) {
      return '${(downloads / 1000).toStringAsFixed(1)}K';
    }
    return downloads.toString();
  }
}

class Marketplace {
  final String id;
  final String name;
  final String description;
  final MarketplaceSource source;
  final String url;
  final String? iconUrl;
  final List<String> categories;
  final int pluginCount;
  final bool isEnabled;
  final DateTime lastSynced;
  final Map<String, dynamic> config;

  Marketplace({
    required this.id,
    required this.name,
    required this.description,
    required this.source,
    required this.url,
    this.iconUrl,
    this.categories = const [],
    this.pluginCount = 0,
    this.isEnabled = true,
    required this.lastSynced,
    this.config = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'source': source.toString(),
    'url': url,
    'iconUrl': iconUrl,
    'categories': categories,
    'pluginCount': pluginCount,
    'isEnabled': isEnabled,
    'lastSynced': lastSynced.toIso8601String(),
    'config': config,
  };

  factory Marketplace.fromJson(Map<String, dynamic> json) => Marketplace(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    source: MarketplaceSource.values.firstWhere(
      (e) => e.toString() == json['source'],
      orElse: () => MarketplaceSource.custom,
    ),
    url: json['url'],
    iconUrl: json['iconUrl'],
    categories: List<String>.from(json['categories'] ?? []),
    pluginCount: json['pluginCount'] ?? 0,
    isEnabled: json['isEnabled'] ?? true,
    lastSynced: DateTime.parse(json['lastSynced']),
    config: json['config'] ?? {},
  );
}

// ============ Repository ============
class PluginRepository {
  final Ref ref;
  List<Plugin> _pluginCache = [];
  List<Marketplace> _marketplaceCache = [];
  bool _initialized = false;

  PluginRepository(this.ref);

  Future<void> _initialize() async {
    if (_initialized) return;

    try {
      await _loadFromStorage();
      if (_pluginCache.isEmpty) {
        _pluginCache = _getDefaultPlugins();
        await _saveToStorage();
      }
      if (_marketplaceCache.isEmpty) {
        _marketplaceCache = _getDefaultMarketplaces();
        await _saveMarketplacesToStorage();
      }
    } catch (e) {
      _pluginCache = _getDefaultPlugins();
      _marketplaceCache = _getDefaultMarketplaces();
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
        type: PluginType.official,
        capabilities: ['view', 'annotate', 'search', 'export'],
        downloads: 15234,
        rating: 4.8,
        tags: ['productivity', 'document'],
        homepage: 'https://anthropic.com/plugins/pdf-viewer',
      ),
      Plugin(
        id: 'reflect',
        name: 'Reflect',
        author: 'Anthropic',
        lastUpdated: DateTime(2026, 7, 15),
        description: 'Reflection and analysis tools for better decision making',
        version: '1.7.0',
        type: PluginType.official,
        capabilities: ['analysis', 'reflection', 'decision-support'],
        downloads: 8765,
        rating: 4.6,
        tags: ['productivity', 'analysis'],
        homepage: 'https://anthropic.com/plugins/reflect',
      ),
      Plugin(
        id: 'claude-code',
        name: 'Claude Code',
        author: 'Anthropic',
        lastUpdated: DateTime(2026, 7, 15),
        description: 'AI-powered code generation, analysis, and optimization',
        version: '3.1.2',
        type: PluginType.official,
        status: PluginStatus.installed,
        capabilities: [
          'code-generation',
          'analysis',
          'optimization',
          'debugging',
        ],
        downloads: 23456,
        rating: 4.9,
        tags: ['development', 'ai'],
        homepage: 'https://anthropic.com/plugins/claude-code',
      ),
      Plugin(
        id: 'time-focus',
        name: 'Time and Focus',
        author: 'Anthropic',
        lastUpdated: DateTime(2026, 7, 14),
        description: 'Time management and focus enhancement tools',
        version: '1.2.0',
        type: PluginType.official,
        capabilities: ['time-tracking', 'focus', 'productivity'],
        downloads: 5432,
        rating: 4.3,
        tags: ['productivity', 'time-management'],
        homepage: 'https://anthropic.com/plugins/time-focus',
      ),
      Plugin(
        id: 'extensions',
        name: 'Extensions',
        author: 'Anthropic',
        lastUpdated: DateTime(2026, 7, 13),
        description: 'Extend Claude\'s capabilities with custom extensions',
        version: '2.0.1',
        type: PluginType.official,
        capabilities: ['extension-management', 'customization'],
        downloads: 9876,
        rating: 4.5,
        tags: ['development', 'customization'],
        homepage: 'https://anthropic.com/plugins/extensions',
      ),
      Plugin(
        id: 'code-assistant',
        name: 'Code Assistant Pro',
        author: 'DevTools Inc',
        lastUpdated: DateTime(2026, 7, 10),
        description: 'Advanced code assistance with AI-powered suggestions',
        version: '3.0.0',
        type: PluginType.marketplace,
        marketplaceId: 'community-plugins',
        capabilities: ['code-completion', 'refactoring', 'testing'],
        downloads: 12345,
        rating: 4.7,
        tags: ['development', 'ai'],
        homepage: 'https://devtools.io/plugins/code-assistant',
      ),
    ];
  }

  List<Marketplace> _getDefaultMarketplaces() {
    return [
      Marketplace(
        id: 'anthropic-official',
        name: 'Anthropic Official',
        description: 'Curated marketplace of plugins built by Anthropic',
        source: MarketplaceSource.anthropic,
        url: 'https://marketplace.anthropic.com/official',
        iconUrl: 'https://anthropic.com/favicon.ico',
        categories: ['Official', 'Featured', 'Recommended'],
        pluginCount: 15,
        isEnabled: true,
        lastSynced: DateTime.now(),
      ),
      Marketplace(
        id: 'community-plugins',
        name: 'Community Marketplace',
        description: 'Community-driven plugins from verified developers',
        source: MarketplaceSource.github,
        url: 'https://github.com/anthropic/community-plugins',
        categories: ['Community', 'Open Source'],
        pluginCount: 42,
        isEnabled: true,
        lastSynced: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  Future<void> _loadFromStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final pluginFile = File('${directory.path}/plugins.json');
      final marketplaceFile = File('${directory.path}/marketplaces.json');

      if (await pluginFile.exists()) {
        final content = await pluginFile.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _pluginCache = jsonList.map((json) => Plugin.fromJson(json)).toList();
      }

      if (await marketplaceFile.exists()) {
        final content = await marketplaceFile.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _marketplaceCache = jsonList
            .map((json) => Marketplace.fromJson(json))
            .toList();
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/plugins.json');
      final json = jsonEncode(_pluginCache.map((p) => p.toJson()).toList());
      await file.writeAsString(json);
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _saveMarketplacesToStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/marketplaces.json');
      final json = jsonEncode(
        _marketplaceCache.map((m) => m.toJson()).toList(),
      );
      await file.writeAsString(json);
    } catch (e) {
      // Silent fail
    }
  }

  Future<List<Plugin>> getPlugins() async {
    await _initialize();
    return _pluginCache;
  }

  Future<List<Marketplace>> getMarketplaces() async {
    await _initialize();
    return _marketplaceCache;
  }

  Future<void> addPlugin(Plugin plugin) async {
    _pluginCache = [..._pluginCache, plugin];
    await _saveToStorage();
  }

  Future<void> removePlugin(String id) async {
    _pluginCache = _pluginCache.where((p) => p.id != id).toList();
    await _saveToStorage();
  }

  Future<void> updatePlugin(Plugin plugin) async {
    final index = _pluginCache.indexWhere((p) => p.id == plugin.id);
    if (index != -1) {
      _pluginCache[index] = plugin;
      await _saveToStorage();
    }
  }

  Future<void> installPlugin(String id) async {
    final index = _pluginCache.indexWhere((p) => p.id == id);
    if (index != -1) {
      _pluginCache[index] = _pluginCache[index].copyWith(
        status: PluginStatus.installed,
        metadata: {
          ..._pluginCache[index].metadata,
          'installedAt': DateTime.now().toIso8601String(),
        },
      );
      await _saveToStorage();
    }
  }

  Future<void> addMarketplace(Marketplace marketplace) async {
    _marketplaceCache = [..._marketplaceCache, marketplace];
    await _saveMarketplacesToStorage();
  }

  Future<void> removeMarketplace(String id) async {
    _marketplaceCache = _marketplaceCache.where((m) => m.id != id).toList();
    await _saveMarketplacesToStorage();
  }

  Future<void> syncMarketplace(String marketplaceId) async {
    final index = _marketplaceCache.indexWhere((m) => m.id == marketplaceId);
    if (index != -1) {
      _marketplaceCache[index] = _marketplaceCache[index].copyWith(
        lastSynced: DateTime.now(),
      );
      await _saveMarketplacesToStorage();
    }
  }

  Future<List<Plugin>> getMarketplacePlugins(String marketplaceId) async {
    return _pluginCache.where((p) => p.marketplaceId == marketplaceId).toList();
  }

  Future<List<Plugin>> searchPlugins(String query) async {
    if (query.isEmpty) return _pluginCache;

    final lowerQuery = query.toLowerCase();
    return _pluginCache.where((plugin) {
      return plugin.name.toLowerCase().contains(lowerQuery) ||
          plugin.author.toLowerCase().contains(lowerQuery) ||
          (plugin.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          plugin.capabilities.any(
            (c) => c.toLowerCase().contains(lowerQuery),
          ) ||
          plugin.tags.any((t) => t.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  Future<List<Plugin>> getPluginsByType(PluginType type) async {
    return _pluginCache.where((p) => p.type == type).toList();
  }

  Future<List<Plugin>> getInstalledPlugins() async {
    return _pluginCache.where((p) => p.isInstalled).toList();
  }

  Future<void> syncMarketplacePlugins(
    String marketplaceId,
    List<Plugin> plugins,
  ) async {
    // Remove existing plugins from this marketplace
    _pluginCache = _pluginCache
        .where((p) => p.marketplaceId != marketplaceId)
        .toList();

    // Add new plugins
    _pluginCache = [..._pluginCache, ...plugins];
    await _saveToStorage();

    // Update marketplace sync time
    await syncMarketplace(marketplaceId);
  }
}

// ============ Service ============
class PluginService {
  final Ref ref;
  final PluginRepository _repository;

  PluginService(this.ref) : _repository = PluginRepository(ref);

  Future<List<Plugin>> fetchMarketplacePlugins(String marketplaceId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // In production, fetch from actual API
      final marketplace = (await _repository.getMarketplaces()).firstWhere(
        (m) => m.id == marketplaceId,
      );

      // Simulate fetching plugins from marketplace URL
      // final response = await http.get(Uri.parse(marketplace.url));
      // final List<dynamic> data = jsonDecode(response.body);

      return [
        Plugin(
          id: 'ai-writer',
          name: 'AI Writer Assistant',
          author: 'ContentAI',
          lastUpdated: DateTime(2026, 7, 12),
          description: 'AI-powered writing assistant for better content',
          version: '2.1.0',
          type: PluginType.marketplace,
          marketplaceId: marketplaceId,
          capabilities: ['writing', 'editing', 'grammar'],
          downloads: 8765,
          rating: 4.6,
          tags: ['writing', 'ai'],
        ),
        Plugin(
          id: 'data-viz',
          name: 'Data Visualizer',
          author: 'DataLabs',
          lastUpdated: DateTime(2026, 7, 11),
          description: 'Create beautiful data visualizations and charts',
          version: '1.5.2',
          type: PluginType.marketplace,
          marketplaceId: marketplaceId,
          capabilities: ['visualization', 'charts', 'data-analysis'],
          downloads: 5432,
          rating: 4.4,
          tags: ['data', 'visualization'],
        ),
      ];
    } catch (e) {
      throw Exception('Failed to fetch marketplace plugins: $e');
    }
  }

  Future<void> syncRepositoryMarketplace(String url, String name) async {
    try {
      // Validate URL
      final uri = Uri.parse(url);
      if (!uri.isAbsolute) {
        throw Exception('Invalid repository URL');
      }

      // In production, fetch from repository
      // final response = await http.get(uri);
      // final manifest = jsonDecode(response.body);

      final newMarketplace = Marketplace(
        id: 'repo-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: 'Synced from repository: $url',
        source: MarketplaceSource.git,
        url: url,
        lastSynced: DateTime.now(),
        pluginCount: 0,
        categories: ['Repository', 'Synced'],
      );

      await _repository.addMarketplace(newMarketplace);

      // Fetch and add plugins from repository
      final plugins = await fetchMarketplacePlugins(newMarketplace.id);
      await _repository.syncMarketplacePlugins(newMarketplace.id, plugins);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> installPluginFromSource(String pluginId) async {
    try {
      final plugin = (await _repository.getPlugins()).firstWhere(
        (p) => p.id == pluginId,
      );

      // Check compatibility
      await _checkCompatibility(plugin);

      // Install
      await _repository.installPlugin(pluginId);

      if (plugin.requiresRestart) {
        await _repository.updatePlugin(
          plugin.copyWith(
            status: PluginStatus.pendingRestart,
            metadata: {...plugin.metadata, 'pendingRestart': true},
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _checkCompatibility(Plugin plugin) async {
    // Check platform
    final platform = Platform.operatingSystem;
    final supportedPlatforms = plugin.metadata['platforms'] ?? ['all'];

    if (!supportedPlatforms.contains(platform) &&
        !supportedPlatforms.contains('all')) {
      throw Exception('Plugin not supported on $platform');
    }

    // Check version
    final minVersion = plugin.metadata['minVersion'] ?? '1.0.0';
    final currentVersion = '1.0.0';

    if (!_isVersionCompatible(currentVersion, minVersion)) {
      throw Exception('Plugin requires version $minVersion or higher');
    }
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

    if (plugin.isUploaded || plugin.isFromRepository) {
      await _repository.removePlugin(pluginId);
    } else {
      await _repository.updatePlugin(
        plugin.copyWith(
          status: PluginStatus.notInstalled,
          metadata: {
            ...plugin.metadata,
            'uninstalledAt': DateTime.now().toIso8601String(),
          },
        ),
      );
    }
  }

  Future<List<Plugin>> searchPlugins(String query) async {
    return await _repository.searchPlugins(query);
  }

  Future<List<Marketplace>> getMarketplaces() async {
    return await _repository.getMarketplaces();
  }
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

final marketplaceListProvider = FutureProvider<List<Marketplace>>((ref) async {
  final repository = ref.watch(pluginRepositoryProvider);
  return await repository.getMarketplaces();
});

final installedPluginsProvider = FutureProvider<List<Plugin>>((ref) async {
  final repository = ref.watch(pluginRepositoryProvider);
  return await repository.getInstalledPlugins();
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedMarketplaceIdProvider = StateProvider<String?>((ref) => null);

final filteredPluginsProvider = FutureProvider<List<Plugin>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final service = ref.watch(pluginServiceProvider);

  if (query.isEmpty) {
    final repository = ref.watch(pluginRepositoryProvider);
    return await repository.getPlugins();
  }

  return await service.searchPlugins(query);
});

final marketplacePluginsProvider = FutureProvider.family<List<Plugin>, String>((
  ref,
  marketplaceId,
) async {
  final repository = ref.watch(pluginRepositoryProvider);
  return await repository.getMarketplacePlugins(marketplaceId);
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

final syncInProgressProvider = StateProvider<Set<String>>((ref) => {});
final isInstallingProvider = StateProvider<Set<String>>((ref) => {});

// ============ Main Screen ============
class PluginManagerScreen extends ConsumerStatefulWidget {
  const PluginManagerScreen({super.key});

  @override
  ConsumerState<PluginManagerScreen> createState() =>
      _PluginManagerScreenState();
}

class _PluginManagerScreenState extends ConsumerState<PluginManagerScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pluginsAsync = ref.watch(filteredPluginsProvider);
    final marketplacesAsync = ref.watch(marketplaceListProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, marketplacesAsync),
            _buildSearchBar(context, query),
            _buildSectionTitle(context, pluginsAsync, marketplacesAsync),
            Expanded(
              child: _buildMainContent(
                context,
                pluginsAsync,
                marketplacesAsync,
              ),
            ),
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AsyncValue<List<Marketplace>> marketplacesAsync,
  ) {
    final hasMarketplaces = marketplacesAsync.when(
      data: (marketplaces) => marketplaces.isNotEmpty,
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
          if (hasMarketplaces) _buildMarketplaceIndicator(marketplacesAsync),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Focus search
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddMarketplaceDialog(context),
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

  Widget _buildMarketplaceIndicator(
    AsyncValue<List<Marketplace>> marketplacesAsync,
  ) {
    return marketplacesAsync.when(
      data: (marketplaces) {
        final activeCount = marketplaces.where((m) => m.isEnabled).length;
        return Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storefront, size: 14, color: Colors.blue[300]),
              const SizedBox(width: 4),
              Text(
                '$activeCount',
                style: TextStyle(
                  color: Colors.blue[300],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
      error: (_, __) => const SizedBox.shrink(),
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
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
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list),
      onSelected: (value) {
        switch (value) {
          case 'all':
            ref.read(searchQueryProvider.notifier).state = '';
            break;
          case 'installed':
            ref.read(searchQueryProvider.notifier).state = 'installed';
            break;
          case 'official':
            ref.read(searchQueryProvider.notifier).state = 'official';
            break;
          case 'marketplace':
            ref.read(searchQueryProvider.notifier).state = 'marketplace';
            break;
          case 'uploaded':
            ref.read(searchQueryProvider.notifier).state = 'uploaded';
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'all',
          child: Row(
            children: [
              Icon(Icons.all_inclusive, size: 20),
              SizedBox(width: 12),
              Text('All Plugins'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'installed',
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 20),
              SizedBox(width: 12),
              Text('Installed'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'official',
          child: Row(
            children: [
              Icon(Icons.verified, size: 20),
              SizedBox(width: 12),
              Text('Official'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'marketplace',
          child: Row(
            children: [
              Icon(Icons.storefront, size: 20),
              SizedBox(width: 12),
              Text('Marketplace'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'uploaded',
          child: Row(
            children: [
              Icon(Icons.cloud_upload, size: 20),
              SizedBox(width: 12),
              Text('Uploaded'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    AsyncValue<List<Plugin>> pluginsAsync,
    AsyncValue<List<Marketplace>> marketplacesAsync,
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
          marketplacesAsync.when(
            data: (marketplaces) {
              final totalPlugins = marketplaces.fold<int>(
                0,
                (sum, m) => sum + m.pluginCount,
              );
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.storefront, size: 16, color: Colors.blue[300]),
                    const SizedBox(width: 4),
                    Text(
                      '$totalPlugins available',
                      style: TextStyle(color: Colors.blue[300], fontSize: 12),
                    ),
                  ],
                ),
              );
            },
            error: (_, __) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    AsyncValue<List<Plugin>> pluginsAsync,
    AsyncValue<List<Marketplace>> marketplacesAsync,
  ) {
    final selectedMarketplaceId = ref.watch(selectedMarketplaceIdProvider);

    if (selectedMarketplaceId != null) {
      return _buildMarketplaceView(context, selectedMarketplaceId);
    }

    return _buildPluginList(context, pluginsAsync);
  }

  Widget _buildMarketplaceView(BuildContext context, String marketplaceId) {
    final pluginsAsync = ref.watch(marketplacePluginsProvider(marketplaceId));
    final marketplacesAsync = ref.watch(marketplaceListProvider);

    return Column(
      children: [
        _buildMarketplaceHeader(context, marketplaceId, marketplacesAsync),
        Expanded(child: _buildPluginList(context, pluginsAsync)),
      ],
    );
  }

  Widget _buildMarketplaceHeader(
    BuildContext context,
    String marketplaceId,
    AsyncValue<List<Marketplace>> marketplacesAsync,
  ) {
    return marketplacesAsync.when(
      data: (marketplaces) {
        final marketplace = marketplaces.firstWhere(
          (m) => m.id == marketplaceId,
          orElse: () => marketplaces.first,
        );

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.storefront,
                  color: Colors.blue[300],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      marketplace.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      marketplace.description,
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          '${marketplace.pluginCount} plugins',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Synced ${_formatTimeAgo(marketplace.lastSynced)}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey[400]),
                onPressed: () {
                  ref.read(selectedMarketplaceIdProvider.notifier).state = null;
                },
              ),
            ],
          ),
        );
      },
      error: (_, __) => const SizedBox.shrink(),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildPluginList(
    BuildContext context,
    AsyncValue<List<Plugin>> pluginsAsync,
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
            return _buildPluginItem(context, plugin);
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
            TextButton(
              onPressed: () => ref.invalidate(pluginListProvider),
              child: const Text('Retry'),
            ),
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
            Icons.extension_off,
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
            'Browse the marketplace or upload your own',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[500],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddMarketplaceDialog(context),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add Marketplace'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPluginItem(BuildContext context, Plugin plugin) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInstalling = ref.watch(isInstallingProvider).contains(plugin.id);
    final isInstalled = plugin.isInstalled;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: plugin.isUploaded
              ? Colors.orange.withOpacity(0.3)
              : (plugin.type == PluginType.marketplace
                    ? Colors.purple.withOpacity(0.3)
                    : (isDark ? Colors.grey[800]! : Colors.grey[200]!)),
          width: 1,
        ),
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
              _buildStatusChip('Uploaded', Colors.orange),
            ],
            if (plugin.type == PluginType.marketplace) ...[
              const SizedBox(width: 8),
              _buildStatusChip('Marketplace', Colors.purple),
            ],
            if (plugin.type == PluginType.repository) ...[
              const SizedBox(width: 8),
              _buildStatusChip('Repository', Colors.teal),
            ],
            if (plugin.status == PluginStatus.pendingRestart) ...[
              const SizedBox(width: 8),
              _buildStatusChip('Restart', Colors.orange),
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
                  'v${plugin.version}',
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
                if (plugin.downloads > 0) ...[
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.download,
                        size: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        plugin.formattedDownloads,
                        style: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
                if (plugin.rating > 0) ...[
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber[400]),
                      const SizedBox(width: 2),
                      Text(
                        plugin.rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
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
            if (plugin.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: plugin.tags.take(3).map((tag) {
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
                      '#$tag',
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
            : isInstalled
            ? _buildInstalledIndicator(plugin)
            : IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showPluginOptions(context, plugin),
              ),
        onTap: () => _showPluginDetails(context, plugin),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color[300],
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPluginIcon(Plugin plugin) {
    Color getColor() {
      if (plugin.isUploaded) return Colors.orange;
      if (plugin.type == PluginType.marketplace) return Colors.purple;
      if (plugin.type == PluginType.repository) return Colors.teal;
      if (plugin.status == PluginStatus.error) return Colors.red;
      if (plugin.status == PluginStatus.pendingRestart) return Colors.orange;
      return Colors.blue;
    }

    IconData getIcon() {
      if (plugin.isUploaded) return Icons.cloud_upload;
      if (plugin.type == PluginType.marketplace) return Icons.storefront;
      if (plugin.type == PluginType.repository) return Icons.code;
      if (plugin.status == PluginStatus.error) return Icons.error_outline;
      if (plugin.status == PluginStatus.pendingRestart)
        return Icons.restart_alt;
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
              ref.read(selectedMarketplaceIdProvider.notifier).state = null;
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
  void _showAddMarketplaceDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final _formKey = GlobalKey<FormState>();
    String? selectedOption = 'browse';
    String? repositoryUrl;
    String? customName;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: isDark ? Colors.grey[850] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              width: 450,
              constraints: const BoxConstraints(maxHeight: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Add Marketplace',
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
                    const SizedBox(height: 16),

                    // Browse option
                    InkWell(
                      onTap: () {
                        setDialogState(() => selectedOption = 'browse');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedOption == 'browse'
                              ? Colors.blue.withOpacity(0.1)
                              : isDark
                              ? Colors.grey[800]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedOption == 'browse'
                                ? Colors.blue
                                : Colors.grey[700]!,
                            width: selectedOption == 'browse' ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.storefront,
                              color: selectedOption == 'browse'
                                  ? Colors.blue
                                  : Colors.grey[400],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Browse Anthropic sources',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Curated marketplaces of plugins built by Anthropic',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selectedOption == 'browse')
                              Icon(Icons.check_circle, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Repository option
                    InkWell(
                      onTap: () {
                        setDialogState(() => selectedOption = 'repository');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedOption == 'repository'
                              ? Colors.blue.withOpacity(0.1)
                              : isDark
                              ? Colors.grey[800]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedOption == 'repository'
                                ? Colors.blue
                                : Colors.grey[700]!,
                            width: selectedOption == 'repository' ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.code,
                              color: selectedOption == 'repository'
                                  ? Colors.blue
                                  : Colors.grey[400],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add from a repository',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Sync a plugin marketplace from a GitHub repository or git URL',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selectedOption == 'repository')
                              Icon(Icons.check_circle, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),

                    if (selectedOption == 'repository') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Repository URL',
                          hintText: 'https://github.com/username/repo',
                          prefixIcon: const Icon(Icons.link),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a repository URL';
                          }
                          try {
                            final uri = Uri.parse(value);
                            if (!uri.isAbsolute) {
                              return 'Please enter a valid URL';
                            }
                          } catch (e) {
                            return 'Please enter a valid URL';
                          }
                          return null;
                        },
                        onChanged: (value) => repositoryUrl = value,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Marketplace Name (optional)',
                          hintText: 'Custom name for this marketplace',
                          prefixIcon: const Icon(Icons.label),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) => customName = value,
                      ),
                    ],

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (selectedOption == 'browse') {
                              // Add Anthropic marketplace
                              try {
                                final service = ref.read(pluginServiceProvider);
                                final marketplaces = await service
                                    .getMarketplaces();

                                // Check if already exists
                                if (marketplaces.any(
                                  (m) =>
                                      m.source == MarketplaceSource.anthropic,
                                )) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Anthropic marketplace already added',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                  return;
                                }

                                // Add marketplace and fetch plugins
                                final newMarketplace = Marketplace(
                                  id: 'anthropic-${DateTime.now().millisecondsSinceEpoch}',
                                  name: 'Anthropic Official',
                                  description:
                                      'Curated marketplace of plugins built by Anthropic',
                                  source: MarketplaceSource.anthropic,
                                  url: 'https://marketplace.anthropic.com',
                                  categories: ['Official', 'Featured'],
                                  lastSynced: DateTime.now(),
                                  isEnabled: true,
                                );

                                final repository = ref.read(
                                  pluginRepositoryProvider,
                                );
                                await repository.addMarketplace(newMarketplace);

                                // Fetch plugins
                                final plugins = await service
                                    .fetchMarketplacePlugins(newMarketplace.id);
                                await repository.syncMarketplacePlugins(
                                  newMarketplace.id,
                                  plugins,
                                );

                                ref.invalidate(marketplaceListProvider);
                                ref.invalidate(pluginListProvider);

                                Navigator.of(context).pop();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Added marketplace: ${newMarketplace.name}',
                                    ),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to add marketplace: ${e.toString()}',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else if (selectedOption == 'repository') {
                              // Validate form
                              if (!_formKey.currentState!.validate()) return;

                              try {
                                final service = ref.read(pluginServiceProvider);
                                final name = customName?.isNotEmpty == true
                                    ? customName!
                                    : 'Repository ${DateTime.now().millisecond.toString().padLeft(3, '0')}';

                                await service.syncRepositoryMarketplace(
                                  repositoryUrl!,
                                  name,
                                );

                                ref.invalidate(marketplaceListProvider);
                                ref.invalidate(pluginListProvider);

                                Navigator.of(context).pop();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Repository synced successfully: $name',
                                    ),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to sync repository: ${e.toString()}',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: selectedOption == 'browse'
                              ? const Text('Add Marketplace')
                              : const Text('Sync Repository'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
              subtitle: Text('v${plugin.version}'),
              onTap: () {
                Navigator.pop(context);
                _showPluginDetails(context, plugin);
              },
            ),
            if (!plugin.isInstalled)
              ListTile(
                leading: Icon(Icons.download_outlined, color: Colors.green),
                title: const Text('Install'),
                subtitle: Text('${plugin.formattedDownloads} downloads'),
                onTap: () => _installPlugin(context, plugin),
              ),
            if (plugin.isInstalled && plugin.type == PluginType.marketplace)
              ListTile(
                leading: Icon(Icons.update, color: Colors.blue),
                title: const Text('Check for Updates'),
                onTap: () => _checkForUpdates(context, plugin),
              ),
            if (plugin.isInstalled && !plugin.isUploaded)
              ListTile(
                leading: Icon(
                  Icons.disabled_by_default_outlined,
                  color: Colors.orange,
                ),
                title: const Text('Uninstall'),
                onTap: () => _uninstallPlugin(context, plugin),
              ),
            if (plugin.isUploaded || plugin.isFromRepository)
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete Plugin'),
                subtitle: const Text('Remove permanently'),
                onTap: () => _deletePlugin(context, plugin),
              ),
            if (plugin.homepage != null)
              ListTile(
                leading: Icon(Icons.open_in_browser, color: Colors.blue),
                title: const Text('View Homepage'),
                onTap: () => _openHomepage(plugin.homepage!),
              ),
            if (plugin.repositoryUrl != null)
              ListTile(
                leading: Icon(Icons.code, color: Colors.purple),
                title: const Text('View Repository'),
                onTap: () => _openHomepage(plugin.repositoryUrl!),
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
      Navigator.pop(context);

      ref.read(isInstallingProvider.notifier).state = {
        ...ref.read(isInstallingProvider),
        plugin.id,
      };

      final service = ref.read(pluginServiceProvider);
      await service.installPluginFromSource(plugin.id);

      ref.invalidate(pluginListProvider);
      ref.invalidate(installedPluginsProvider);

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
        content: Text('Are you sure you want to uninstall "${plugin.name}"?'),
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
      Navigator.pop(context);

      final service = ref.read(pluginServiceProvider);
      await service.uninstallPlugin(plugin.id);

      ref.invalidate(pluginListProvider);
      ref.invalidate(installedPluginsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plugin.name} uninstalled'),
            backgroundColor: Colors.orange,
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

  Future<void> _deletePlugin(BuildContext context, Plugin plugin) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plugin'),
        content: Text(
          'Are you sure you want to permanently delete "${plugin.name}"? '
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      Navigator.pop(context);

      final repository = ref.read(pluginRepositoryProvider);
      await repository.removePlugin(plugin.id);

      ref.invalidate(pluginListProvider);
      ref.invalidate(installedPluginsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plugin.name} deleted'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkForUpdates(BuildContext context, Plugin plugin) async {
    try {
      Navigator.pop(context);

      // Simulate update check
      await Future.delayed(const Duration(seconds: 1));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No updates available'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update check failed: ${e.toString()}'),
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
              if (plugin.downloads > 0)
                _buildDetailRow('Downloads', plugin.formattedDownloads),
              if (plugin.rating > 0)
                _buildDetailRow(
                  'Rating',
                  '${plugin.rating.toStringAsFixed(1)} ★',
                ),
              if (plugin.description != null)
                _buildDetailRow(
                  'Description',
                  plugin.description!,
                  multiline: true,
                ),
              if (plugin.capabilities.isNotEmpty)
                _buildDetailRow('Capabilities', plugin.capabilities.join(', ')),
              if (plugin.tags.isNotEmpty)
                _buildDetailRow('Tags', plugin.tags.join(', ')),
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
          if (plugin.isInstalled)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (plugin.isUploaded || plugin.isFromRepository) {
                  _deletePlugin(context, plugin);
                } else {
                  _uninstallPlugin(context, plugin);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(plugin.isUploaded ? 'Delete' : 'Uninstall'),
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
              onTap: () {},
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
${plugin.downloads > 0 ? 'Downloads: ${plugin.formattedDownloads}' : ''}
${plugin.rating > 0 ? 'Rating: ${plugin.rating.toStringAsFixed(1)} ★' : ''}
Capabilities: ${plugin.capabilities.join(', ')}
Tags: ${plugin.tags.join(', ')}
${plugin.homepage != null ? 'Homepage: ${plugin.homepage}' : ''}
''';

    await Share.share(shareText, subject: 'Plugin: ${plugin.name}');
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
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
