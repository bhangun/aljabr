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
      title: 'Connectors Marketplace',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      darkTheme: ThemeData.dark(),
      home: const ConnectorsMarketplaceScreen(),
    );
  }
}

// ============ Models ============
enum ConnectorCategory {
  popular('Popular', Icons.trending_up),
  productivity('Productivity', Icons.speed),
  communication('Communication', Icons.chat),
  storage('Storage', Icons.cloud),
  finance('Finance', Icons.attach_money),
  social('Social', Icons.share),
  community('Community', Icons.people),
  analytics('Analytics', Icons.analytics);

  final String label;
  final IconData icon;
  const ConnectorCategory(this.label, this.icon);
}

enum ConnectorStatus {
  available('Available'),
  connected('Connected'),
  comingSoon('Coming Soon');

  final String label;
  const ConnectorStatus(this.label);
}

enum ConnectorType {
  popular('Popular'),
  newConnector('New'),
  community('Community'),
  partner('Partner');

  final String label;
  const ConnectorType(this.type);
}

class Connector {
  final String id;
  final String name;
  final String? description;
  final String? longDescription;
  final String author;
  final String? authorLogo;
  final ConnectorCategory category;
  final ConnectorStatus status;
  final ConnectorType type;
  final int popularityRank;
  final int? usageCount;
  final double? rating;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final String? iconUrl;
  final List<String> features;
  final bool isCommunity;
  final String? partnerUrl;
  final DateTime addedDate;
  final List<String> screenshots;

  Connector({
    required this.id,
    required this.name,
    this.description,
    this.longDescription,
    required this.author,
    this.authorLogo,
    required this.category,
    this.status = ConnectorStatus.available,
    this.type = ConnectorType.popular,
    this.popularityRank = 0,
    this.usageCount,
    this.rating,
    this.tags = const [],
    this.metadata = const {},
    this.iconUrl,
    this.features = const [],
    this.isCommunity = false,
    this.partnerUrl,
    required this.addedDate,
    this.screenshots = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'longDescription': longDescription,
    'author': author,
    'authorLogo': authorLogo,
    'category': category.toString(),
    'status': status.toString(),
    'type': type.toString(),
    'popularityRank': popularityRank,
    'usageCount': usageCount,
    'rating': rating,
    'tags': tags,
    'metadata': metadata,
    'iconUrl': iconUrl,
    'features': features,
    'isCommunity': isCommunity,
    'partnerUrl': partnerUrl,
    'addedDate': addedDate.toIso8601String(),
    'screenshots': screenshots,
  };

  factory Connector.fromJson(Map<String, dynamic> json) => Connector(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    longDescription: json['longDescription'],
    author: json['author'],
    authorLogo: json['authorLogo'],
    category: ConnectorCategory.values.firstWhere(
      (e) => e.toString() == json['category'],
      orElse: () => ConnectorCategory.popular,
    ),
    status: ConnectorStatus.values.firstWhere(
      (e) => e.toString() == json['status'],
      orElse: () => ConnectorStatus.available,
    ),
    type: ConnectorType.values.firstWhere(
      (e) => e.toString() == json['type'],
      orElse: () => ConnectorType.popular,
    ),
    popularityRank: json['popularityRank'] ?? 0,
    usageCount: json['usageCount'],
    rating: json['rating']?.toDouble(),
    tags: List<String>.from(json['tags'] ?? []),
    metadata: json['metadata'] ?? {},
    iconUrl: json['iconUrl'],
    features: List<String>.from(json['features'] ?? []),
    isCommunity: json['isCommunity'] ?? false,
    partnerUrl: json['partnerUrl'],
    addedDate: DateTime.parse(json['addedDate']),
    screenshots: List<String>.from(json['screenshots'] ?? []),
  );

  String get formattedAddedDate {
    final now = DateTime.now();
    final difference = now.difference(addedDate);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }

  bool get isPopular => type == ConnectorType.popular;
  bool get isNew => type == ConnectorType.newConnector;
  bool get isCommunityConnector => type == ConnectorType.community;
  bool get isPartner => type == ConnectorType.partner;
  bool get isConnected => status == ConnectorStatus.connected;
}

// ============ Repository ============
class ConnectorRepository {
  final Ref ref;
  List<Connector> _cache = [];
  bool _initialized = false;

  ConnectorRepository(this.ref);

  Future<void> _initialize() async {
    if (_initialized) return;

    try {
      await _loadFromStorage();
      if (_cache.isEmpty) {
        _cache = _getDefaultConnectors();
        await _saveToStorage();
      }
    } catch (e) {
      _cache = _getDefaultConnectors();
    }
    _initialized = true;
  }

  List<Connector> _getDefaultConnectors() {
    return [
      Connector(
        id: 'gmail',
        name: 'Gmail',
        description: 'Draft replies, summarize threads, & search your inbox',
        longDescription:
            'Connect your Gmail account to draft intelligent replies, summarize long email threads, search through your inbox with natural language, and manage your email workflow efficiently.',
        author: 'Google',
        category: ConnectorCategory.communication,
        status: ConnectorStatus.connected,
        type: ConnectorType.popular,
        popularityRank: 2,
        usageCount: 15234,
        rating: 4.8,
        tags: ['email', 'communication', 'productivity'],
        iconUrl:
            'https://www.gstatic.com/images/branding/product/1x/gmail_2020q4_48dp.png',
        features: [
          'Email drafting',
          'Thread summarization',
          'Natural language search',
          'Smart replies',
        ],
        addedDate: DateTime(2026, 7, 10),
        partnerUrl: 'https://workspace.google.com/products/gmail/',
      ),
      Connector(
        id: 'googledrive',
        name: 'Google Drive',
        description: 'Search, read, and upload files instantly',
        longDescription:
            'Integrate with Google Drive to search across your entire storage, read document content, upload files instantly, and organize your files with AI-powered suggestions.',
        author: 'Google',
        category: ConnectorCategory.storage,
        status: ConnectorStatus.connected,
        type: ConnectorType.popular,
        popularityRank: 1,
        usageCount: 18765,
        rating: 4.9,
        tags: ['storage', 'documents', 'cloud'],
        iconUrl:
            'https://www.gstatic.com/images/branding/product/1x/drive_2020q4_48dp.png',
        features: [
          'File search',
          'Content reading',
          'Instant upload',
          'AI organization',
        ],
        addedDate: DateTime(2026, 7, 8),
        partnerUrl: 'https://workspace.google.com/products/drive/',
      ),
      Connector(
        id: 'slack',
        name: 'Slack',
        description: 'Turn your fund into something you can talk to',
        longDescription:
            'Connect Slack to turn your company knowledge into an interactive assistant. Query channels, search conversations, and get summarized insights from your team\'s communication.',
        author: 'Slack',
        category: ConnectorCategory.communication,
        status: ConnectorStatus.available,
        type: ConnectorType.popular,
        popularityRank: 3,
        usageCount: 12345,
        rating: 4.7,
        tags: ['communication', 'team', 'messaging'],
        iconUrl:
            'https://upload.wikimedia.org/wikipedia/commons/d/d5/Slack_icon_2019.svg',
        features: [
          'Conversation search',
          'Channel insights',
          'Team analytics',
          'Smart summaries',
        ],
        addedDate: DateTime(2026, 7, 5),
        partnerUrl: 'https://slack.com/',
      ),
      Connector(
        id: 'travex',
        name: 'TravEx',
        description: 'Create rich, interactive travel itineraries',
        longDescription:
            'Plan and manage travel with AI-powered itineraries. Get real-time flight information, hotel suggestions, restaurant recommendations, and interactive maps for your travel plans.',
        author: 'Anthropic & Partners',
        category: ConnectorCategory.productivity,
        status: ConnectorStatus.available,
        type: ConnectorType.newConnector,
        popularityRank: 5,
        usageCount: 8765,
        rating: 4.6,
        tags: ['travel', 'planning', 'itinerary'],
        iconUrl: 'https://example.com/travex.png',
        features: [
          'Interactive itineraries',
          'Real-time updates',
          'Recommendations',
          'Maps integration',
        ],
        addedDate: DateTime(2026, 7, 14),
        isCommunity: false,
        partnerUrl: 'https://example.com/travex',
      ),
      Connector(
        id: 'angellist',
        name: 'AngelList',
        description: 'Turn your fund into something you can talk to',
        longDescription:
            'Connect with your investment portfolio on AngelList. Get real-time updates, analyze performance, and interact with your investments through natural language.',
        author: 'AngelList',
        category: ConnectorCategory.finance,
        status: ConnectorStatus.available,
        type: ConnectorType.community,
        popularityRank: 4,
        usageCount: 6543,
        rating: 4.4,
        tags: ['finance', 'investments', 'startup'],
        iconUrl: 'https://example.com/angellist.png',
        features: [
          'Portfolio management',
          'Performance analysis',
          'Natural language queries',
          'Real-time updates',
        ],
        addedDate: DateTime(2026, 7, 12),
        isCommunity: true,
        partnerUrl: 'https://angel.co/',
      ),
      Connector(
        id: 'yogi',
        name: 'Yogi',
        description: 'Ask your consumers anything. Credible VoC insights.',
        longDescription:
            'Yogi provides consumer insights through voice of customer (VoC) analysis. Ask questions about your consumers, get credible insights, and understand customer sentiment.',
        author: 'Yogi',
        category: ConnectorCategory.analytics,
        status: ConnectorStatus.available,
        type: ConnectorType.newConnector,
        popularityRank: 6,
        usageCount: 5432,
        rating: 4.5,
        tags: ['analytics', 'consumer', 'insights'],
        iconUrl: 'https://example.com/yogi.png',
        features: [
          'Consumer insights',
          'Sentiment analysis',
          'Question answering',
          'Data visualization',
        ],
        addedDate: DateTime(2026, 7, 13),
        isCommunity: true,
        partnerUrl: 'https://yogi.ai/',
      ),
      Connector(
        id: 'contract-factory',
        name: 'Contract-Factory',
        description: 'Infos officielles des entreprises françaises (RNE)',
        longDescription:
            'Access official French business information (RNE) directly from Contract-Factory. Verify companies, retrieve legal documents, and streamline your business verification process.',
        author: 'Contract-Factory',
        category: ConnectorCategory.productivity,
        status: ConnectorStatus.available,
        type: ConnectorType.community,
        popularityRank: 7,
        usageCount: 4321,
        rating: 4.3,
        tags: ['legal', 'business', 'france'],
        iconUrl: 'https://example.com/contract-factory.png',
        features: [
          'Business verification',
          'Legal document retrieval',
          'RNE integration',
          'French companies data',
        ],
        addedDate: DateTime(2026, 7, 11),
        isCommunity: true,
        partnerUrl: 'https://contract-factory.com/',
      ),
      Connector(
        id: 'societes',
        name: 'Sociétés &...',
        description: 'Infos officielles des entreprises françaises (RNE)',
        longDescription:
            'Comprehensive French business information platform with official RNE data, company registration details, and real-time business intelligence.',
        author: 'Sociétés',
        category: ConnectorCategory.finance,
        status: ConnectorStatus.available,
        type: ConnectorType.community,
        popularityRank: 8,
        usageCount: 3210,
        rating: 4.2,
        tags: ['business', 'france', 'legal'],
        iconUrl: 'https://example.com/societes.png',
        features: [
          'Company registration',
          'RNE data',
          'Business intelligence',
          'Real-time updates',
        ],
        addedDate: DateTime(2026, 7, 9),
        isCommunity: true,
        partnerUrl: 'https://societes.com/',
      ),
    ];
  }

  Future<void> _loadFromStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/connectors.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _cache = jsonList.map((json) => Connector.fromJson(json)).toList();
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/connectors.json');
      final json = jsonEncode(_cache.map((c) => c.toJson()).toList());
      await file.writeAsString(json);
    } catch (e) {
      // Silent fail
    }
  }

  Future<List<Connector>> getConnectors() async {
    await _initialize();
    return _cache;
  }

  Future<List<Connector>> getConnectorsByCategory(
    ConnectorCategory category,
  ) async {
    await _initialize();
    if (category == ConnectorCategory.popular) {
      return _cache.where((c) => c.isPopular).toList();
    }
    return _cache.where((c) => c.category == category).toList();
  }

  Future<List<Connector>> getPopularConnectors() async {
    await _initialize();
    return _cache.where((c) => c.isPopular).toList()
      ..sort((a, b) => a.popularityRank.compareTo(b.popularityRank));
  }

  Future<List<Connector>> getNewConnectors() async {
    await _initialize();
    return _cache.where((c) => c.isNew).toList()
      ..sort((a, b) => b.addedDate.compareTo(a.addedDate));
  }

  Future<List<Connector>> getCommunityConnectors() async {
    await _initialize();
    return _cache.where((c) => c.isCommunityConnector).toList();
  }

  Future<List<Connector>> searchConnectors(String query) async {
    await _initialize();
    if (query.isEmpty) return _cache;

    final lowerQuery = query.toLowerCase();
    return _cache.where((connector) {
      return connector.name.toLowerCase().contains(lowerQuery) ||
          connector.author.toLowerCase().contains(lowerQuery) ||
          (connector.description?.toLowerCase().contains(lowerQuery) ??
              false) ||
          connector.tags.any((t) => t.toLowerCase().contains(lowerQuery)) ||
          connector.features.any((f) => f.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  Future<void> connectConnector(String id) async {
    final index = _cache.indexWhere((c) => c.id == id);
    if (index != -1) {
      _cache[index] = _cache[index].copyWith(
        status: ConnectorStatus.connected,
        metadata: {
          ..._cache[index].metadata,
          'connectedAt': DateTime.now().toIso8601String(),
        },
      );
      await _saveToStorage();
    }
  }

  Future<void> disconnectConnector(String id) async {
    final index = _cache.indexWhere((c) => c.id == id);
    if (index != -1) {
      _cache[index] = _cache[index].copyWith(
        status: ConnectorStatus.available,
        metadata: {
          ..._cache[index].metadata,
          'disconnectedAt': DateTime.now().toIso8601String(),
        },
      );
      await _saveToStorage();
    }
  }
}

// ============ Providers ============
final connectorRepositoryProvider = Provider<ConnectorRepository>((ref) {
  return ConnectorRepository(ref);
});

final connectorListProvider = FutureProvider<List<Connector>>((ref) async {
  final repository = ref.watch(connectorRepositoryProvider);
  return await repository.getConnectors();
});

final popularConnectorsProvider = FutureProvider<List<Connector>>((ref) async {
  final repository = ref.watch(connectorRepositoryProvider);
  return await repository.getPopularConnectors();
});

final newConnectorsProvider = FutureProvider<List<Connector>>((ref) async {
  final repository = ref.watch(connectorRepositoryProvider);
  return await repository.getNewConnectors();
});

final communityConnectorsProvider = FutureProvider<List<Connector>>((
  ref,
) async {
  final repository = ref.watch(connectorRepositoryProvider);
  return await repository.getCommunityConnectors();
});

final selectedCategoryProvider = StateProvider<ConnectorCategory>(
  (ref) => ConnectorCategory.popular,
);
final selectedFilterProvider = StateProvider<String>(
  (ref) => 'Anthropic & Partners',
);
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedConnectorIdProvider = StateProvider<String?>((ref) => null);
final isConnectingProvider = StateProvider<Set<String>>((ref) => {});

final filteredConnectorsProvider = FutureProvider<List<Connector>>((ref) async {
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider);
  final filter = ref.watch(selectedFilterProvider);
  final repository = ref.watch(connectorRepositoryProvider);

  List<Connector> connectors;

  if (query.isEmpty) {
    connectors = await repository.getConnectorsByCategory(category);
  } else {
    connectors = await repository.searchConnectors(query);
    if (category != ConnectorCategory.popular) {
      connectors = connectors.where((c) => c.category == category).toList();
    }
  }

  // Apply filter
  if (filter == 'Anthropic & Partners') {
    connectors = connectors.where((c) => !c.isCommunityConnector).toList();
  } else if (filter == 'Community') {
    connectors = connectors.where((c) => c.isCommunityConnector).toList();
  }

  return connectors;
});

// ============ Reusable Widgets ============

// Reusable Connector Card Widget
class ConnectorCard extends StatelessWidget {
  final Connector connector;
  final VoidCallback? onTap;
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;
  final bool isConnected;

  const ConnectorCard({
    super.key,
    required this.connector,
    this.onTap,
    this.onConnect,
    this.onDisconnect,
    this.isConnected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConnected
                ? Colors.green.withOpacity(0.5)
                : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
            width: isConnected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isConnected
                  ? Colors.green.withOpacity(0.1)
                  : (isDark ? Colors.black54 : Colors.grey.withOpacity(0.1)),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isConnected
                    ? Colors.green.withOpacity(0.1)
                    : (isDark ? Colors.grey[800] : Colors.grey[100]),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  _buildConnectorIcon(connector, isDark),
                  const SizedBox(width: 10),
                  // Name and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                connector.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildTypeBadge(connector),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              connector.author,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                            if (connector.popularityRank > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.trending_up,
                                      size: 10,
                                      color: Colors.amber[400],
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '#${connector.popularityRank}',
                                      style: TextStyle(
                                        color: Colors.amber[400],
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status indicator
                  if (isConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Connected',
                            style: TextStyle(
                              color: Colors.green[300],
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
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
                      connector.description ?? 'No description available',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Tags and features
                    if (connector.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: connector.tags.take(2).map((tag) {
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
                      const SizedBox(height: 6),
                    ],
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (connector.rating != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber[400],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                connector.rating!.toStringAsFixed(1),
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (connector.usageCount != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 14,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _formatCount(connector.usageCount!),
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Spacer(),
                        if (connector.status == ConnectorStatus.comingSoon)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Coming Soon',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else if (isConnected)
                          _buildActionButton(
                            icon: Icons.link_off,
                            label: 'Disconnect',
                            color: Colors.red,
                            onPressed: onDisconnect,
                          )
                        else
                          _buildActionButton(
                            icon: Icons.add_link,
                            label: 'Connect',
                            color: Colors.blue,
                            onPressed: onConnect,
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

  Widget _buildConnectorIcon(Connector connector, bool isDark) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          connector.name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: isDark ? Colors.blue[300] : Colors.blue[700],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(Connector connector) {
    Color getColor() {
      if (connector.isNew) return Colors.green;
      if (connector.isCommunityConnector) return Colors.purple;
      if (connector.isPopular) return Colors.amber;
      return Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: getColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        connector.type.label,
        style: TextStyle(
          color: getColor(),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

// Reusable Category Filter Widget
class CategoryFilterWidget extends StatelessWidget {
  final ConnectorCategory selectedCategory;
  final Function(ConnectorCategory) onCategorySelected;

  const CategoryFilterWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: ConnectorCategory.values.length,
        itemBuilder: (context, index) {
          final category = ConnectorCategory.values[index];
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
                  onCategorySelected(category);
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
}

// Reusable Filter Bar Widget
class FilterBarWidget extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final int itemCount;
  final bool showFilter;

  const FilterBarWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.itemCount,
    this.showFilter = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filters = ['Anthropic & Partners', 'Community'];

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
          if (showFilter) ...[
            PopupMenuButton<String>(
              onSelected: onFilterChanged,
              child: Row(
                children: [
                  Text(
                    selectedFilter,
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
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
              itemBuilder: (context) => filters.map((filter) {
                return PopupMenuItem(
                  value: filter,
                  child: Row(
                    children: [
                      if (selectedFilter == filter)
                        Icon(Icons.check, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(filter),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(width: 16),
          ],
          const Spacer(),
          Text(
            '$itemCount connectors',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Search Bar Widget
class SearchBarWidget extends StatelessWidget {
  final String query;
  final Function(String) onSearchChanged;

  const SearchBarWidget({
    super.key,
    required this.query,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search connectors...',
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
                    onSearchChanged('');
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
}

// Reusable Section Header Widget
class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showDivider;

  const SectionHeaderWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ============ Main Screen ============
class ConnectorsMarketplaceScreen extends ConsumerStatefulWidget {
  const ConnectorsMarketplaceScreen({super.key});

  @override
  ConsumerState<ConnectorsMarketplaceScreen> createState() =>
      _ConnectorsMarketplaceScreenState();
}

class _ConnectorsMarketplaceScreenState
    extends ConsumerState<ConnectorsMarketplaceScreen> {
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
    final connectorsAsync = ref.watch(filteredConnectorsProvider);
    final popularAsync = ref.watch(popularConnectorsProvider);
    final newAsync = ref.watch(newConnectorsProvider);
    final communityAsync = ref.watch(communityConnectorsProvider);
    final category = ref.watch(selectedCategoryProvider);
    final filter = ref.watch(selectedFilterProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            SearchBarWidget(
              query: query,
              onSearchChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
            CategoryFilterWidget(
              selectedCategory: category,
              onCategorySelected: (category) {
                ref.read(selectedCategoryProvider.notifier).state = category;
              },
            ),
            FilterBarWidget(
              selectedFilter: filter,
              onFilterChanged: (value) {
                ref.read(selectedFilterProvider.notifier).state = value;
              },
              itemCount: connectorsAsync.when(
                data: (connectors) => connectors.length,
                error: (_, __) => 0,
                loading: () => 0,
              ),
              showFilter: category == ConnectorCategory.popular,
            ),
            Expanded(
              child: Stack(
                children: [
                  _buildContent(
                    context,
                    connectorsAsync,
                    popularAsync,
                    newAsync,
                    communityAsync,
                  ),
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
            onPressed: () => _showAddConnectorDialog(context),
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

  Widget _buildContent(
    BuildContext context,
    AsyncValue<List<Connector>> connectorsAsync,
    AsyncValue<List<Connector>> popularAsync,
    AsyncValue<List<Connector>> newAsync,
    AsyncValue<List<Connector>> communityAsync,
  ) {
    final category = ref.watch(selectedCategoryProvider);

    if (category == ConnectorCategory.popular &&
        ref.watch(searchQueryProvider).isEmpty) {
      return _buildPopularView(context, popularAsync, newAsync, communityAsync);
    }

    return _buildConnectorGrid(context, connectorsAsync);
  }

  Widget _buildPopularView(
    BuildContext context,
    AsyncValue<List<Connector>> popularAsync,
    AsyncValue<List<Connector>> newAsync,
    AsyncValue<List<Connector>> communityAsync,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular section
          SectionHeaderWidget(
            title: 'POPULAR',
            subtitle: 'Most used connectors',
            trailing: TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
            showDivider: true,
          ),
          SizedBox(
            height: 240,
            child: popularAsync.when(
              data: (connectors) {
                if (connectors.isEmpty) {
                  return const Center(child: Text('No popular connectors'));
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: connectors.length,
                  itemBuilder: (context, index) {
                    final connector = connectors[index];
                    final isConnected = connector.isConnected;

                    return Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 12),
                      child: ConnectorCard(
                        connector: connector,
                        isConnected: isConnected,
                        onTap: () => _showConnectorDetails(context, connector),
                        onConnect: () => _connectConnector(context, connector),
                        onDisconnect: () =>
                            _disconnectConnector(context, connector),
                      ),
                    );
                  },
                );
              },
              error: (_, __) => Center(
                child: Text(
                  'Failed to load popular connectors',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),

          // New section
          const SizedBox(height: 16),
          SectionHeaderWidget(
            title: 'NEW',
            subtitle: 'Recently added connectors',
            trailing: TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
            showDivider: true,
          ),
          SizedBox(
            height: 240,
            child: newAsync.when(
              data: (connectors) {
                if (connectors.isEmpty) {
                  return const Center(child: Text('No new connectors'));
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: connectors.length,
                  itemBuilder: (context, index) {
                    final connector = connectors[index];
                    final isConnected = connector.isConnected;

                    return Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 12),
                      child: ConnectorCard(
                        connector: connector,
                        isConnected: isConnected,
                        onTap: () => _showConnectorDetails(context, connector),
                        onConnect: () => _connectConnector(context, connector),
                        onDisconnect: () =>
                            _disconnectConnector(context, connector),
                      ),
                    );
                  },
                );
              },
              error: (_, __) => Center(
                child: Text(
                  'Failed to load new connectors',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),

          // Community section
          const SizedBox(height: 16),
          SectionHeaderWidget(
            title: 'COMMUNITY',
            subtitle: 'Community-built connectors',
            trailing: TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
            showDivider: true,
          ),
          SizedBox(
            height: 240,
            child: communityAsync.when(
              data: (connectors) {
                if (connectors.isEmpty) {
                  return const Center(child: Text('No community connectors'));
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: connectors.length,
                  itemBuilder: (context, index) {
                    final connector = connectors[index];
                    final isConnected = connector.isConnected;

                    return Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 12),
                      child: ConnectorCard(
                        connector: connector,
                        isConnected: isConnected,
                        onTap: () => _showConnectorDetails(context, connector),
                        onConnect: () => _connectConnector(context, connector),
                        onDisconnect: () =>
                            _disconnectConnector(context, connector),
                      ),
                    );
                  },
                );
              },
              error: (_, __) => Center(
                child: Text(
                  'Failed to load community connectors',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildConnectorGrid(
    BuildContext context,
    AsyncValue<List<Connector>> connectorsAsync,
  ) {
    return connectorsAsync.when(
      data: (connectors) {
        if (connectors.isEmpty) {
          return _buildEmptyState(context);
        }

        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 350,
            childAspectRatio: 1.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: connectors.length,
          itemBuilder: (context, index) {
            final connector = connectors[index];
            final isConnected = connector.isConnected;

            return ConnectorCard(
              connector: connector,
              isConnected: isConnected,
              onTap: () => _showConnectorDetails(context, connector),
              onConnect: () => _connectConnector(context, connector),
              onDisconnect: () => _disconnectConnector(context, connector),
            );
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
              'Failed to load connectors',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.invalidate(connectorListProvider);
                ref.invalidate(filteredConnectorsProvider);
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
          maxCrossAxisExtent: 350,
          childAspectRatio: 1.4,
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

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = ref.watch(searchQueryProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            query.isEmpty ? Icons.link_off : Icons.search_off,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty
                ? 'No connectors in this category'
                : 'No results found',
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
        ],
      ),
    );
  }

  // ============ Dialog Methods ============
  void _showAddConnectorDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Connector'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_link, color: Colors.blue),
              title: const Text('Connect Service'),
              subtitle: const Text('Connect to popular services'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.code, color: Colors.purple),
              title: const Text('Custom API'),
              subtitle: const Text('Connect to a custom API endpoint'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file, color: Colors.green),
              title: const Text('Import from File'),
              subtitle: const Text('Import connector configuration'),
              onTap: () {
                Navigator.pop(context);
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
              title: const Text('Auto-connect'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Show Beta Connectors'),
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

  void _showConnectorDetails(BuildContext context, Connector connector) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isConnected = connector.isConnected;
    final isConnecting = ref.watch(isConnectingProvider).contains(connector.id);

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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        connector.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: Colors.blue[300],
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          connector.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              connector.author,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: connector.type == ConnectorType.popular
                                    ? Colors.amber.withOpacity(0.2)
                                    : Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                connector.type.label,
                                style: TextStyle(
                                  color: connector.type == ConnectorType.popular
                                      ? Colors.amber[300]
                                      : Colors.green[300],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        connector.longDescription ??
                            connector.description ??
                            'No description available',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (connector.features.isNotEmpty) ...[
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
                          children: connector.features.map((feature) {
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
                      const SizedBox(height: 12),
                      if (connector.tags.isNotEmpty) ...[
                        const Text(
                          'Tags',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: connector.tags.map((tag) {
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
                                '#$tag',
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
                          if (connector.rating != null) ...[
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              connector.rating!.toStringAsFixed(1),
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          if (connector.usageCount != null) ...[
                            Icon(
                              Icons.people,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_formatCount(connector.usageCount!)} users',
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
                            'Added ${connector.formattedAddedDate}',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      if (connector.partnerUrl != null) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _openUrl(connector.partnerUrl!),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Visit Partner Page'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                          ),
                        ),
                      ],
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
                  if (connector.status == ConnectorStatus.comingSoon)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Coming Soon'),
                    )
                  else if (isConnected)
                    ElevatedButton.icon(
                      onPressed: () => _disconnectConnector(context, connector),
                      icon: const Icon(Icons.link_off),
                      label: const Text('Disconnect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: isConnecting
                          ? null
                          : () => _connectConnector(context, connector),
                      icon: isConnecting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_link),
                      label: Text(isConnecting ? 'Connecting...' : 'Connect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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

  Future<void> _connectConnector(
    BuildContext context,
    Connector connector,
  ) async {
    try {
      Navigator.of(context).pop();

      ref.read(isConnectingProvider.notifier).state = {
        ...ref.read(isConnectingProvider),
        connector.id,
      };

      final repository = ref.read(connectorRepositoryProvider);
      await repository.connectConnector(connector.id);

      ref.invalidate(connectorListProvider);
      ref.invalidate(filteredConnectorsProvider);
      ref.invalidate(popularConnectorsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${connector.name}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      ref.read(isConnectingProvider.notifier).state = ref
          .read(isConnectingProvider)
          .where((id) => id != connector.id)
          .toSet();
    }
  }

  Future<void> _disconnectConnector(
    BuildContext context,
    Connector connector,
  ) async {
    final shouldDisconnect = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Connector'),
        content: Text(
          'Are you sure you want to disconnect "${connector.name}"?',
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
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (shouldDisconnect != true) return;

    try {
      Navigator.of(context).pop();

      final repository = ref.read(connectorRepositoryProvider);
      await repository.disconnectConnector(connector.id);

      ref.invalidate(connectorListProvider);
      ref.invalidate(filteredConnectorsProvider);
      ref.invalidate(popularConnectorsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Disconnected from ${connector.name}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to disconnect: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open URL: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
