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
      title: 'Plugin Marketplace',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      darkTheme: ThemeData.dark(),
      home: const MarketplaceBrowserScreen(),
    );
  }
}

// ============ Models ============
enum PluginType { official, marketplace, uploaded, repository }

enum PluginStatus { installed, notInstalled, updating, error, pendingRestart }

enum Category {
  all('All', Icons.dashboard),
  smallBusiness('Small Business', Icons.business_center),
  operations('Operations', Icons.settings_applications),
  design('Design', Icons.design_services),
  humanResources('Human Resources', Icons.people),
  engineering('Engineering', Icons.code),
  bioResearch('Bio Research', Icons.science),
  productivity('Productivity', Icons.speed),
  analytics('Analytics', Icons.analytics),
  education('Education', Icons.school);

  final String label;
  final IconData icon;

  const Category(this.label, this.icon);
}

enum SortOption {
  relevance('Relevance'),
  downloads('Most Downloads'),
  rating('Highest Rated'),
  newest('Newest'),
  oldest('Oldest');

  final String label;
  const SortOption(this.label);
}

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
  final Category category;
  final String? longDescription;
  final List<String> features;
  final bool isFeatured;

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
    this.category = Category.all,
    this.longDescription,
    this.features = const [],
    this.isFeatured = false,
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
    Category? category,
    String? longDescription,
    List<String>? features,
    bool? isFeatured,
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
      category: category ?? this.category,
      longDescription: longDescription ?? this.longDescription,
      features: features ?? this.features,
      isFeatured: isFeatured ?? this.isFeatured,
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
    'category': category.toString(),
    'longDescription': longDescription,
    'features': features,
    'isFeatured': isFeatured,
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
    category: Category.values.firstWhere(
      (e) => e.toString() == json['category'],
      orElse: () => Category.all,
    ),
    longDescription: json['longDescription'],
    features: List<String>.from(json['features'] ?? []),
    isFeatured: json['isFeatured'] ?? false,
  );

  bool get isInstalled =>
      status == PluginStatus.installed || status == PluginStatus.pendingRestart;
  bool get isUploaded => type == PluginType.uploaded;
  bool get isOfficial => type == PluginType.official;

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

// ============ Repository ============
class PluginRepository {
  final Ref ref;
  List<Plugin> _pluginCache = [];
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
    } catch (e) {
      _pluginCache = _getDefaultPlugins();
    }
    _initialized = true;
  }

  List<Plugin> _getDefaultPlugins() {
    return [
      Plugin(
        id: 'pdf-viewer',
        name: 'PDF Viewer',
        author: 'Anthropic',
        lastUpdated: DateTime(2026, 7, 15),
        description:
            'View, annotate, and sign PDFs in a live interactive viewer.',
        longDescription:
            'View, annotate, and sign PDFs in a live interactive viewer. Mark up contracts, fill forms with visual feedback, stamp documents with e-signatures, and collaborate in real-time. Supports all major PDF features including form filling, digital signatures, and text annotations.',
        version: '2.3.1',
        type: PluginType.official,
        category: Category.all,
        capabilities: [
          'PDF Viewing',
          'Annotation',
          'Signatures',
          'Form Filling',
        ],
        features: [
          'Real-time collaboration',
          'E-signatures',
          'Form filling',
          'Text annotations',
          'Stamps',
        ],
        downloads: 15234,
        rating: 4.8,
        tags: ['productivity', 'document', 'PDF'],
        homepage: 'https://anthropic.com/plugins/pdf-viewer',
        isFeatured: true,
      ),
      Plugin(
        id: 'small-business',
        name: 'Small Business',
        author: 'Anthropic',
        lastUpdated: DateTime(2026, 7, 15),
        description:
            'Pre-built small business workflows (including payroll planning, month-end close, weekly briefs, and growth...',
        longDescription:
            'Pre-built small business workflows including payroll planning, month-end close, weekly briefs, and growth forecasting. Automate recurring tasks, track key metrics, and make data-driven decisions with ease.',
        version: '1.5.0',
        type: PluginType.official,
        category: Category.smallBusiness,
        capabilities: ['Workflows', 'Automation', 'Reporting'],
        features: [
          'Payroll planning',
          'Month-end close',
          'Weekly briefs',
          'Growth forecasting',
        ],
        downloads: 8765,
        rating: 4.6,
        tags: ['business', 'automation', 'workflows'],
        homepage: 'https://anthropic.com/plugins/small-business',
      ),
      Plugin(
        id: 'operations',
        name: 'Operations',
        author: 'Anthropic',
        lastUpdated: DateTime(2026, 7, 14),
        description:
            'Optimize business operations — vendor management, process documentation, change management, capacity...',
        longDescription:
            'Optimize business operations with comprehensive tools for vendor management, process documentation, change management, capacity planning, and operational analytics.',
        version: '2.0.0',
        type: PluginType.official,
        category: Category.operations,
        capabilities: [
          'Operations Management',
          'Process Automation',
          'Analytics',
        ],
        features: [
          'Vendor management',
          'Process documentation',
          'Change management',
          'Capacity planning',
        ],
        downloads: 6543,
        rating: 4.5,
        tags: ['operations', 'management', 'process'],
        homepage: 'https://anthropic.com/plugins/operations',
      ),
      Plugin(
        id: 'design',
        name: 'Design',
        author: 'Anthropic',
        lastUpdated: DateTime(2026, 7, 13),
        description:
            'Accelerate design workflows — critique, design system management, UX writing, accessibility audits, research...',
        longDescription:
            'Accelerate design workflows with tools for critique sessions, design system management, UX writing, accessibility audits, user research, and prototyping.',
        version: '1.8.0',
        type: PluginType.official,
        category: Category.design,
        capabilities: ['Design Tools', 'UX', 'Accessibility'],
        features: [
          'Design critique',
          'System management',
          'UX writing',
          'Accessibility audits',
          'Research tools',
        ],
        downloads: 5432,
        rating: 4.7,
        tags: ['design', 'ux', 'accessibility'],
        homepage: 'https://anthropic.com/plugins/design',
      ),
      Plugin(
        id: 'hr',
        name: 'Human Resources',
        author: 'Anthropic',
        lastUpdated: DateTime(2026, 7, 12),
        description:
            'Streamline people operations — recruiting, onboarding, performance reviews, compensation analysis, and policy...',
        longDescription:
            'Streamline people operations with integrated tools for recruiting, onboarding, performance reviews, compensation analysis, policy management, and employee engagement.',
        version: '2.1.0',
        type: PluginType.official,
        category: Category.humanResources,
        capabilities: ['HR Management', 'Recruiting', 'Performance'],
        features: [
          'Recruiting pipeline',
          'Onboarding',
          'Performance reviews',
          'Compensation analysis',
          'Policy management',
        ],
        downloads: 9876,
        rating: 4.4,
        tags: ['hr', 'people', 'recruiting'],
        homepage: 'https://anthropic.com/plugins/hr',
      ),
      Plugin(
        id: 'engineering',
        name: 'Engineering',
        author: 'Anthropic',
        lastUpdated: DateTime(2026, 7, 11),
        description:
            'Streamline engineering workflows — standups, code review, architecture decisions, incident response, and...',
        longDescription:
            'Streamline engineering workflows with tools for standups, code review, architecture decisions, incident response, sprint planning, and technical documentation.',
        version: '3.0.0',
        type: PluginType.official,
        category: Category.engineering,
        capabilities: ['Development', 'Code Review', 'Incident Response'],
        features: [
          'Standups',
          'Code review',
          'Architecture decisions',
          'Incident response',
          'Sprint planning',
        ],
        downloads: 23456,
        rating: 4.9,
        tags: ['engineering', 'development', 'code'],
        homepage: 'https://anthropic.com/plugins/engineering',
        isFeatured: true,
      ),
      Plugin(
        id: 'bio-research',
        name: 'Bio Research',
        author: 'Anthropic',
        lastUpdated: DateTime(2026, 7, 10),
        description:
            'Advanced research tools for bioinformatics, genomic analysis, and scientific discovery...',
        longDescription:
            'Advanced research tools for bioinformatics, genomic analysis, and scientific discovery. Support for common bioinformatics formats, visualization tools, and statistical analysis.',
        version: '1.2.0',
        type: PluginType.official,
        category: Category.bioResearch,
        capabilities: ['Bioinformatics', 'Genomics', 'Research'],
        features: [
          'Genomic analysis',
          'Visualization tools',
          'Statistical analysis',
          'Data import/export',
        ],
        downloads: 4321,
        rating: 4.3,
        tags: ['research', 'bioinformatics', 'science'],
        homepage: 'https://anthropic.com/plugins/bio-research',
      ),
      Plugin(
        id: 'productivity-plus',
        name: 'Productivity Plus',
        author: 'Partners',
        lastUpdated: DateTime(2026, 7, 9),
        description:
            'Advanced productivity suite with time tracking, focus mode, and task automation...',
        longDescription:
            'Advanced productivity suite with time tracking, focus mode, task automation, project management, and collaboration tools.',
        version: '1.9.0',
        type: PluginType.marketplace,
        category: Category.productivity,
        capabilities: ['Productivity', 'Time Management', 'Automation'],
        features: [
          'Time tracking',
          'Focus mode',
          'Task automation',
          'Project management',
        ],
        downloads: 7654,
        rating: 4.2,
        tags: ['productivity', 'time', 'focus'],
        homepage: 'https://partners.io/plugins/productivity',
      ),
    ];
  }

  Future<void> _loadFromStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/plugins.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _pluginCache = jsonList.map((json) => Plugin.fromJson(json)).toList();
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

  Future<List<Plugin>> getPlugins() async {
    await _initialize();
    return _pluginCache;
  }

  Future<List<Plugin>> getPluginsByCategory(Category category) async {
    await _initialize();
    if (category == Category.all) return _pluginCache;
    return _pluginCache.where((p) => p.category == category).toList();
  }

  Future<List<Plugin>> getFeaturedPlugins() async {
    await _initialize();
    return _pluginCache.where((p) => p.isFeatured).toList();
  }

  Future<List<Plugin>> searchPlugins(String query) async {
    await _initialize();
    if (query.isEmpty) return _pluginCache;

    final lowerQuery = query.toLowerCase();
    return _pluginCache.where((plugin) {
      return plugin.name.toLowerCase().contains(lowerQuery) ||
          plugin.author.toLowerCase().contains(lowerQuery) ||
          (plugin.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          (plugin.longDescription?.toLowerCase().contains(lowerQuery) ??
              false) ||
          plugin.capabilities.any(
            (c) => c.toLowerCase().contains(lowerQuery),
          ) ||
          plugin.tags.any((t) => t.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  Future<List<Plugin>> sortPlugins(
    List<Plugin> plugins,
    SortOption sort,
  ) async {
    switch (sort) {
      case SortOption.relevance:
        return plugins;
      case SortOption.downloads:
        return [...plugins]..sort((a, b) => b.downloads.compareTo(a.downloads));
      case SortOption.rating:
        return [...plugins]..sort((a, b) => b.rating.compareTo(a.rating));
      case SortOption.newest:
        return [...plugins]
          ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
      case SortOption.oldest:
        return [...plugins]
          ..sort((a, b) => a.lastUpdated.compareTo(b.lastUpdated));
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

  Future<void> uninstallPlugin(String id) async {
    final index = _pluginCache.indexWhere((p) => p.id == id);
    if (index != -1) {
      _pluginCache[index] = _pluginCache[index].copyWith(
        status: PluginStatus.notInstalled,
        metadata: {
          ..._pluginCache[index].metadata,
          'uninstalledAt': DateTime.now().toIso8601String(),
        },
      );
      await _saveToStorage();
    }
  }
}

// ============ Providers ============
final pluginRepositoryProvider = Provider<PluginRepository>((ref) {
  return PluginRepository(ref);
});

final pluginListProvider = FutureProvider<List<Plugin>>((ref) async {
  final repository = ref.watch(pluginRepositoryProvider);
  return await repository.getPlugins();
});

final featuredPluginsProvider = FutureProvider<List<Plugin>>((ref) async {
  final repository = ref.watch(pluginRepositoryProvider);
  return await repository.getFeaturedPlugins();
});

final selectedCategoryProvider = StateProvider<Category>((ref) => Category.all);
final selectedSortProvider = StateProvider<SortOption>(
  (ref) => SortOption.relevance,
);
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedPluginIdProvider = StateProvider<String?>((ref) => null);
final isInstallingProvider = StateProvider<Set<String>>((ref) => {});

final filteredAndSortedPluginsProvider = FutureProvider<List<Plugin>>((
  ref,
) async {
  final category = ref.watch(selectedCategoryProvider);
  final sort = ref.watch(selectedSortProvider);
  final query = ref.watch(searchQueryProvider);
  final repository = ref.watch(pluginRepositoryProvider);

  // Get plugins by category
  List<Plugin> plugins;
  if (query.isEmpty) {
    plugins = await repository.getPluginsByCategory(category);
  } else {
    plugins = await repository.searchPlugins(query);
    // If search returns results, filter by category
    if (category != Category.all) {
      plugins = plugins.where((p) => p.category == category).toList();
    }
  }

  // Sort plugins
  return await repository.sortPlugins(plugins, sort);
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

// ============ Main Screen ============
class MarketplaceBrowserScreen extends ConsumerStatefulWidget {
  const MarketplaceBrowserScreen({super.key});

  @override
  ConsumerState<MarketplaceBrowserScreen> createState() =>
      _MarketplaceBrowserScreenState();
}

class _MarketplaceBrowserScreenState
    extends ConsumerState<MarketplaceBrowserScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _showScrollToTop = _scrollController.offset > 300;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pluginsAsync = ref.watch(filteredAndSortedPluginsProvider);
    final featuredAsync = ref.watch(featuredPluginsProvider);
    final category = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(context),
            _buildCategoryTabs(context),
            _buildFilterBar(context),
            Expanded(
              child: Stack(
                children: [
                  _buildPluginGrid(context, pluginsAsync, featuredAsync),
                  if (_showScrollToTop)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton.small(
                        onPressed: () {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                          );
                        },
                        backgroundColor: Colors.blue,
                        child: const Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[800]!, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Open drawer
            },
          ),
          const SizedBox(width: 4),
          const Text(
            'Directory',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Focus search
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddPluginDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsDialog(context),
          ),
          const SizedBox(width: 4),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue[700],
            child: const Icon(Icons.person, size: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = ref.watch(searchQueryProvider);

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
              : null,
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

  Widget _buildCategoryTabs(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: Category.values.length,
        itemBuilder: (context, index) {
          final category = Category.values[index];
          final isSelected = category == selectedCategory;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(
                category.label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey[300] : Colors.grey[700]),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(selectedCategoryProvider.notifier).state = category;
                }
              },
              avatar: Icon(
                category.icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              selectedColor: Colors.blue[700],
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sort = ref.watch(selectedSortProvider);
    final pluginsAsync = ref.watch(filteredAndSortedPluginsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                'Partners',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ],
          ),
          const SizedBox(width: 16),
          PopupMenuButton<SortOption>(
            onSelected: (value) {
              ref.read(selectedSortProvider.notifier).state = value;
            },
            child: Row(
              children: [
                Text(
                  'Sort by',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  sort.label,
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
            itemBuilder: (context) => SortOption.values.map((option) {
              return PopupMenuItem(
                value: option,
                child: Row(
                  children: [
                    if (sort == option) Icon(Icons.check, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(option.label),
                  ],
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          pluginsAsync.when(
            data: (plugins) => Text(
              '${plugins.length} plugins',
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                fontSize: 13,
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            loading: () => const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPluginGrid(
    BuildContext context,
    AsyncValue<List<Plugin>> pluginsAsync,
    AsyncValue<List<Plugin>> featuredAsync,
  ) {
    return pluginsAsync.when(
      data: (plugins) {
        if (plugins.isEmpty) {
          return _buildEmptyState(context);
        }

        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: plugins.length,
          itemBuilder: (context, index) {
            final plugin = plugins[index];
            final isFeatured = plugin.isFeatured;

            return _buildPluginCard(context, plugin, isFeatured);
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
              onPressed: () {
                ref.invalidate(pluginListProvider);
                ref.invalidate(filteredAndSortedPluginsProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      loading: () => GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildPluginCard(
    BuildContext context,
    Plugin plugin,
    bool isFeatured,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInstalling = ref.watch(isInstallingProvider).contains(plugin.id);
    final isInstalled = plugin.isInstalled;

    return GestureDetector(
      onTap: () => _showPluginDetails(context, plugin),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFeatured
                ? Colors.blue.withOpacity(0.5)
                : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
            width: isFeatured ? 2 : 1,
          ),
          boxShadow: isFeatured
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and author
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFeatured
                    ? Colors.blue.withOpacity(0.1)
                    : (isDark ? Colors.grey[800] : Colors.grey[100]),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  _buildPluginIcon(plugin, isDark),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plugin.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isFeatured) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Featured',
                                  style: TextStyle(
                                    color: Colors.blue[300],
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          plugin.author,
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plugin.description ?? 'No description available',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Tags
                    if (plugin.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: plugin.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Footer with stats and actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (plugin.downloads > 0) ...[
                              Icon(
                                Icons.download,
                                size: 14,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                plugin.formattedDownloads,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (plugin.rating > 0) ...[
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber[400],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                plugin.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                        isInstalling
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : isInstalled
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green[300],
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Installed',
                                      style: TextStyle(
                                        color: Colors.green[300],
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.download_outlined,
                                      color: Colors.blue[300],
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Install',
                                      style: TextStyle(
                                        color: Colors.blue[300],
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPluginIcon(Plugin plugin, bool isDark) {
    Color getColor() {
      if (plugin.isUploaded) return Colors.orange;
      if (plugin.type == PluginType.marketplace) return Colors.purple;
      if (plugin.status == PluginStatus.error) return Colors.red;
      if (plugin.status == PluginStatus.pendingRestart) return Colors.orange;
      if (plugin.isFeatured) return Colors.blue;
      return Colors.grey;
    }

    IconData getIcon() {
      if (plugin.isUploaded) return Icons.cloud_upload;
      if (plugin.type == PluginType.marketplace) return Icons.storefront;
      if (plugin.status == PluginStatus.error) return Icons.error_outline;
      if (plugin.status == PluginStatus.pendingRestart)
        return Icons.restart_alt;
      return Icons.extension;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: getColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(getIcon(), color: getColor(), size: 18),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = ref.watch(searchQueryProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            query.isEmpty ? Icons.category : Icons.search_off,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty ? 'No plugins in this category' : 'No results found',
            style: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[600],
              fontSize: 16,
            ),
          ),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search terms',
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
          if (query.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Explore other categories or browse the marketplace',
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============ Dialogs ============
  void _showAddPluginDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Plugin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.cloud_upload, color: Colors.orange),
              title: const Text('Upload from file'),
              subtitle: const Text('Upload a plugin package file'),
              onTap: () {
                Navigator.pop(context);
                _showUploadDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.storefront, color: Colors.purple),
              title: const Text('Browse Marketplace'),
              subtitle: const Text('Explore official and community plugins'),
              onTap: () {
                Navigator.pop(context);
                ref.read(selectedCategoryProvider.notifier).state =
                    Category.all;
              },
            ),
            ListTile(
              leading: const Icon(Icons.code, color: Colors.teal),
              title: const Text('Add from Repository'),
              subtitle: const Text('Sync from a git repository'),
              onTap: () {
                Navigator.pop(context);
                _showRepositoryDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Upload Plugin',
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
                        'Make sure you trust a plugin before installing. '
                        'Uploaded plugins are not controlled by Anthropic.',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                    style: BorderStyle.dashed,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 32,
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Drag and drop or click to upload',
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
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
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Plugin upload feature coming soon!'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Upload'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRepositoryDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final _formKey = GlobalKey<FormState>();
    String? repoUrl;
    String? customName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add from Repository'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Repository URL',
                  hintText: 'https://github.com/username/repo',
                  prefixIcon: Icon(Icons.link),
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
                onChanged: (value) => repoUrl = value,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Name (optional)',
                  hintText: 'Custom name for this source',
                  prefixIcon: Icon(Icons.label),
                ),
                onChanged: (value) => customName = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Syncing repository: ${customName ?? repoUrl}'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sync'),
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
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: isDark,
              onChanged: (value) {
                // Toggle theme
              },
            ),
            SwitchListTile(
              title: const Text('Auto-Update Plugins'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Show Beta Plugins'),
              value: false,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Developer Mode'),
              value: false,
              onChanged: (value) {},
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

  void _showPluginDetails(BuildContext context, Plugin plugin) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInstalled = plugin.isInstalled;
    final isInstalling = ref.watch(isInstallingProvider).contains(plugin.id);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 500,
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildPluginIcon(plugin, isDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plugin.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          '${plugin.author} • v${plugin.version}',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
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
              if (plugin.isFeatured)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.blue[300], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Featured Plugin',
                        style: TextStyle(
                          color: Colors.blue[300],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plugin.longDescription ??
                            plugin.description ??
                            'No description available',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (plugin.features.isNotEmpty) ...[
                        const Text(
                          'Features',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: plugin.features.map((feature) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[700]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.green[300],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    feature,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (plugin.capabilities.isNotEmpty) ...[
                        const Text(
                          'Capabilities',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: plugin.capabilities.map((capability) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[700]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                capability,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (plugin.downloads > 0) ...[
                            Icon(
                              Icons.download,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${plugin.formattedDownloads} downloads',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          if (plugin.rating > 0) ...[
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              plugin.rating.toStringAsFixed(1),
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Text(
                            'Updated ${plugin.formattedDate}',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  if (plugin.homepage != null)
                    TextButton(
                      onPressed: () => _openHomepage(plugin.homepage!),
                      child: const Text('Homepage'),
                    ),
                  if (!isInstalled)
                    ElevatedButton.icon(
                      onPressed: isInstalling
                          ? null
                          : () => _installPlugin(context, plugin),
                      icon: isInstalling
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download_outlined),
                      label: Text(isInstalling ? 'Installing...' : 'Install'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (isInstalled)
                    ElevatedButton.icon(
                      onPressed: () => _uninstallPlugin(context, plugin),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Uninstall'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _installPlugin(BuildContext context, Plugin plugin) async {
    try {
      Navigator.of(context).pop();

      ref.read(isInstallingProvider.notifier).state = {
        ...ref.read(isInstallingProvider),
        plugin.id,
      };

      final repository = ref.read(pluginRepositoryProvider);
      await repository.installPlugin(plugin.id);

      ref.invalidate(pluginListProvider);
      ref.invalidate(filteredAndSortedPluginsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plugin.name} installed successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Installation failed: ${e.toString()}'),
            backgroundColor: Colors.red,
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
      Navigator.of(context).pop();

      final repository = ref.read(pluginRepositoryProvider);
      await repository.uninstallPlugin(plugin.id);

      ref.invalidate(pluginListProvider);
      ref.invalidate(filteredAndSortedPluginsProvider);

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
}
