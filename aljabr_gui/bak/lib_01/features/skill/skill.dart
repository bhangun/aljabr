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
      title: 'Skills Marketplace',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      darkTheme: ThemeData.dark(),
      home: const SkillsMarketplaceScreen(),
    );
  }
}

// ============ Models ============
enum SkillCategory {
  all('All', Icons.dashboard),
  development('Development', Icons.code),
  design('Design', Icons.design_services),
  productivity('Productivity', Icons.speed),
  ai('AI & ML', Icons.psychology),
  business('Business', Icons.business_center),
  creativity('Creativity', Icons.brush),
  education('Education', Icons.school);

  final String label;
  final IconData icon;
  const SkillCategory(this.label, this.icon);
}

enum SkillStatus {
  available('Available'),
  installed('Installed'),
  updating('Updating'),
  error('Error');

  final String label;
  const SkillStatus(this.label);
}

class Skill {
  final String id;
  final String name;
  final String command;
  final String author;
  final String? authorLogo;
  final String? description;
  final String? longDescription;
  final SkillCategory category;
  final SkillStatus status;
  final int usageCount;
  final double? rating;
  final DateTime lastUpdated;
  final List<String> tags;
  final List<String> features;
  final Map<String, dynamic> metadata;
  final String? iconUrl;
  final bool isFeatured;
  final String? documentationUrl;
  final List<String> screenshots;
  final String version;

  Skill({
    required this.id,
    required this.name,
    required this.command,
    required this.author,
    this.authorLogo,
    this.description,
    this.longDescription,
    required this.category,
    this.status = SkillStatus.available,
    this.usageCount = 0,
    this.rating,
    required this.lastUpdated,
    this.tags = const [],
    this.features = const [],
    this.metadata = const {},
    this.iconUrl,
    this.isFeatured = false,
    this.documentationUrl,
    this.screenshots = const [],
    this.version = '1.0.0',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'command': command,
    'author': author,
    'authorLogo': authorLogo,
    'description': description,
    'longDescription': longDescription,
    'category': category.toString(),
    'status': status.toString(),
    'usageCount': usageCount,
    'rating': rating,
    'lastUpdated': lastUpdated.toIso8601String(),
    'tags': tags,
    'features': features,
    'metadata': metadata,
    'iconUrl': iconUrl,
    'isFeatured': isFeatured,
    'documentationUrl': documentationUrl,
    'screenshots': screenshots,
    'version': version,
  };

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
    id: json['id'],
    name: json['name'],
    command: json['command'],
    author: json['author'],
    authorLogo: json['authorLogo'],
    description: json['description'],
    longDescription: json['longDescription'],
    category: SkillCategory.values.firstWhere(
      (e) => e.toString() == json['category'],
      orElse: () => SkillCategory.all,
    ),
    status: SkillStatus.values.firstWhere(
      (e) => e.toString() == json['status'],
      orElse: () => SkillStatus.available,
    ),
    usageCount: json['usageCount'] ?? 0,
    rating: json['rating']?.toDouble(),
    lastUpdated: DateTime.parse(json['lastUpdated']),
    tags: List<String>.from(json['tags'] ?? []),
    features: List<String>.from(json['features'] ?? []),
    metadata: json['metadata'] ?? {},
    iconUrl: json['iconUrl'],
    isFeatured: json['isFeatured'] ?? false,
    documentationUrl: json['documentationUrl'],
    screenshots: List<String>.from(json['screenshots'] ?? []),
    version: json['version'] ?? '1.0.0',
  );

  String get formattedUsage {
    if (usageCount >= 1000000) {
      return '${(usageCount / 1000000).toStringAsFixed(1)}M';
    } else if (usageCount >= 1000) {
      return '${(usageCount / 1000).toStringAsFixed(1)}K';
    }
    return usageCount.toString();
  }

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
    } else {
      return 'Just now';
    }
  }

  bool get isInstalled => status == SkillStatus.installed;
}

// ============ Repository ============
class SkillRepository {
  final Ref ref;
  List<Skill> _cache = [];
  bool _initialized = false;

  SkillRepository(this.ref);

  Future<void> _initialize() async {
    if (_initialized) return;

    try {
      await _loadFromStorage();
      if (_cache.isEmpty) {
        _cache = _getDefaultSkills();
        await _saveToStorage();
      }
    } catch (e) {
      _cache = _getDefaultSkills();
    }
    _initialized = true;
  }

  List<Skill> _getDefaultSkills() {
    return [
      Skill(
        id: 'mcp-builder',
        name: '/mcp-builder',
        command: '/mcp-builder',
        author: 'Anthropic',
        description:
            'Guide for creating high-quality MCP (Model Context Protocol) servers that enable LLMs to interact with...',
        longDescription:
            'A comprehensive guide for creating high-quality Model Context Protocol (MCP) servers that enable LLMs to interact with external tools and data sources. Includes best practices, architecture patterns, and implementation examples.',
        category: SkillCategory.development,
        status: SkillStatus.available,
        usageCount: 807500,
        rating: 4.9,
        lastUpdated: DateTime(2026, 7, 15),
        tags: ['mcp', 'protocol', 'llm', 'integration'],
        features: [
          'MCP server creation',
          'Tool integration',
          'Best practices',
          'Architecture patterns',
        ],
        isFeatured: true,
        version: '2.1.0',
        documentationUrl: 'https://anthropic.com/docs/mcp-builder',
      ),
      Skill(
        id: 'morning',
        name: '/morning',
        command: '/morning',
        author: 'Anthropic',
        description:
            'Render the user\'s morning brief as a styled HTML artifact, or set it up as a recurring weekday task. Use only when t...',
        longDescription:
            'Render the user\'s morning brief as a styled HTML artifact with personalized content, weather updates, calendar events, and priority tasks. Can be configured as a recurring weekday task.',
        category: SkillCategory.productivity,
        status: SkillStatus.installed,
        usageCount: 432,
        rating: 4.5,
        lastUpdated: DateTime(2026, 7, 14),
        tags: ['morning', 'brief', 'productivity', 'automation'],
        features: [
          'Morning briefing',
          'HTML artifacts',
          'Recurring tasks',
          'Personalized content',
        ],
        isFeatured: false,
        version: '1.2.0',
        documentationUrl: 'https://anthropic.com/docs/morning',
      ),
      Skill(
        id: 'web-artifacts-builder',
        name: '/web-artifacts-builder',
        command: '/web-artifacts-builder',
        author: 'Anthropic',
        description:
            'Suite of tools for creating elaborate, multi-component claude.ai HTML artifacts using modern frontend web...',
        longDescription:
            'A comprehensive suite of tools for creating elaborate, multi-component claude.ai HTML artifacts using modern frontend web technologies including React, Vue, and vanilla JavaScript with advanced styling capabilities.',
        category: SkillCategory.development,
        status: SkillStatus.available,
        usageCount: 980400,
        rating: 4.8,
        lastUpdated: DateTime(2026, 7, 13),
        tags: ['web', 'frontend', 'artifacts', 'html'],
        features: [
          'Multi-component artifacts',
          'Modern web tech',
          'React/Vue support',
          'Advanced styling',
        ],
        isFeatured: true,
        version: '3.0.0',
        documentationUrl: 'https://anthropic.com/docs/web-artifacts-builder',
      ),
      Skill(
        id: 'brand-guidelines',
        name: '/brand-guidelines',
        command: '/brand-guidelines',
        author: 'Anthropic',
        description:
            'Applies Anthropic\'s official brand colors and typography to...',
        longDescription:
            'Applies Anthropic\'s official brand colors, typography, and design system to all artifacts and outputs. Ensures consistency with Anthropic\'s visual identity guidelines.',
        category: SkillCategory.design,
        status: SkillStatus.available,
        usageCount: 706400,
        rating: 4.7,
        lastUpdated: DateTime(2026, 7, 12),
        tags: ['brand', 'design', 'guidelines', 'identity'],
        features: [
          'Brand colors',
          'Typography',
          'Design system',
          'Consistency',
        ],
        isFeatured: false,
        version: '1.5.0',
        documentationUrl: 'https://anthropic.com/docs/brand-guidelines',
      ),
      Skill(
        id: 'skill-creator',
        name: '/skill-creator',
        command: '/skill-creator',
        author: 'Anthropic',
        description:
            'Create new skills, modify and improve existing skills, and measure skill performance. Use when users want to crea...',
        longDescription:
            'Create new skills, modify and improve existing skills, and measure skill performance. Provides templates, best practices, and testing tools for skill development.',
        category: SkillCategory.development,
        status: SkillStatus.available,
        usageCount: 127600,
        rating: 4.6,
        lastUpdated: DateTime(2026, 7, 11),
        tags: ['skill-creation', 'development', 'performance'],
        features: [
          'Skill creation',
          'Modification',
          'Performance measurement',
          'Templates',
        ],
        isFeatured: false,
        version: '2.0.0',
        documentationUrl: 'https://anthropic.com/docs/skill-creator',
      ),
      Skill(
        id: 'canvas-design',
        name: '/canvas-design',
        command: '/canvas-design',
        author: 'Anthropic',
        description:
            'Create beautiful visual art in .png and .pdf documents using design philosophy. You should use this skill when t...',
        longDescription:
            'Create beautiful visual art in .png and .pdf documents using design philosophy and principles. Supports various art styles, color palettes, and compositional techniques.',
        category: SkillCategory.creativity,
        status: SkillStatus.available,
        usageCount: 1500000,
        rating: 4.9,
        lastUpdated: DateTime(2026, 7, 10),
        tags: ['design', 'art', 'visual', 'creative'],
        features: [
          'Visual art creation',
          'PNG/PDF export',
          'Design principles',
          'Various art styles',
        ],
        isFeatured: true,
        version: '1.8.0',
        documentationUrl: 'https://anthropic.com/docs/canvas-design',
      ),
      Skill(
        id: 'theme-factory',
        name: '/theme-factory',
        command: '/theme-factory',
        author: 'Anthropic',
        description:
            'Toolkit for styling artifacts with a theme. These artifacts can be slides, docs, reportings, HTML landing pages, etc...',
        longDescription:
            'Toolkit for styling artifacts with a theme. These artifacts can be slides, docs, reportings, HTML landing pages, and more. Includes pre-built themes and custom theme creation.',
        category: SkillCategory.design,
        status: SkillStatus.available,
        usageCount: 777200,
        rating: 4.7,
        lastUpdated: DateTime(2026, 7, 9),
        tags: ['theme', 'styling', 'design', 'artifacts'],
        features: [
          'Theme application',
          'Custom themes',
          'Multiple artifact types',
          'Pre-built themes',
        ],
        isFeatured: false,
        version: '1.3.0',
        documentationUrl: 'https://anthropic.com/docs/theme-factory',
      ),
      Skill(
        id: 'doc-coauthoring',
        name: '/doc-coauthoring',
        command: '/doc-coauthoring',
        author: 'Anthropic',
        description: 'Guide users through a structured workflow for co...',
        longDescription:
            'Guide users through a structured workflow for collaborative document creation and editing. Provides real-time feedback, suggestions, and version control.',
        category: SkillCategory.productivity,
        status: SkillStatus.available,
        usageCount: 686300,
        rating: 4.6,
        lastUpdated: DateTime(2026, 7, 8),
        tags: ['documentation', 'collaboration', 'writing'],
        features: [
          'Structured workflow',
          'Real-time feedback',
          'Suggestions',
          'Version control',
        ],
        isFeatured: false,
        version: '1.1.0',
        documentationUrl: 'https://anthropic.com/docs/doc-coauthoring',
      ),
    ];
  }

  Future<void> _loadFromStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/skills.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _cache = jsonList.map((json) => Skill.fromJson(json)).toList();
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/skills.json');
      final json = jsonEncode(_cache.map((s) => s.toJson()).toList());
      await file.writeAsString(json);
    } catch (e) {
      // Silent fail
    }
  }

  Future<List<Skill>> getSkills() async {
    await _initialize();
    return _cache;
  }

  Future<List<Skill>> getSkillsByCategory(SkillCategory category) async {
    await _initialize();
    if (category == SkillCategory.all) return _cache;
    return _cache.where((s) => s.category == category).toList();
  }

  Future<List<Skill>> getFeaturedSkills() async {
    await _initialize();
    return _cache.where((s) => s.isFeatured).toList();
  }

  Future<List<Skill>> searchSkills(String query) async {
    await _initialize();
    if (query.isEmpty) return _cache;

    final lowerQuery = query.toLowerCase();
    return _cache.where((skill) {
      return skill.name.toLowerCase().contains(lowerQuery) ||
          skill.command.toLowerCase().contains(lowerQuery) ||
          skill.author.toLowerCase().contains(lowerQuery) ||
          (skill.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          (skill.longDescription?.toLowerCase().contains(lowerQuery) ??
              false) ||
          skill.tags.any((t) => t.toLowerCase().contains(lowerQuery)) ||
          skill.features.any((f) => f.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  Future<void> installSkill(String id) async {
    final index = _cache.indexWhere((s) => s.id == id);
    if (index != -1) {
      _cache[index] = _cache[index].copyWith(
        status: SkillStatus.installed,
        metadata: {
          ..._cache[index].metadata,
          'installedAt': DateTime.now().toIso8601String(),
        },
      );
      await _saveToStorage();
    }
  }

  Future<void> uninstallSkill(String id) async {
    final index = _cache.indexWhere((s) => s.id == id);
    if (index != -1) {
      _cache[index] = _cache[index].copyWith(
        status: SkillStatus.available,
        metadata: {
          ..._cache[index].metadata,
          'uninstalledAt': DateTime.now().toIso8601String(),
        },
      );
      await _saveToStorage();
    }
  }
}

// ============ Providers ============
final skillRepositoryProvider = Provider<SkillRepository>((ref) {
  return SkillRepository(ref);
});

final skillListProvider = FutureProvider<List<Skill>>((ref) async {
  final repository = ref.watch(skillRepositoryProvider);
  return await repository.getSkills();
});

final featuredSkillsProvider = FutureProvider<List<Skill>>((ref) async {
  final repository = ref.watch(skillRepositoryProvider);
  return await repository.getFeaturedSkills();
});

final selectedCategoryProvider = StateProvider<SkillCategory>(
  (ref) => SkillCategory.all,
);
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedSkillIdProvider = StateProvider<String?>((ref) => null);
final isInstallingProvider = StateProvider<Set<String>>((ref) => {});

final filteredSkillsProvider = FutureProvider<List<Skill>>((ref) async {
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider);
  final repository = ref.watch(skillRepositoryProvider);

  if (query.isEmpty) {
    return await repository.getSkillsByCategory(category);
  } else {
    final skills = await repository.searchSkills(query);
    if (category != SkillCategory.all) {
      return skills.where((s) => s.category == category).toList();
    }
    return skills;
  }
});

final skillDetailProvider = FutureProvider.family<Skill?, String>((
  ref,
  id,
) async {
  final skills = await ref.watch(skillListProvider.future);
  try {
    return skills.firstWhere((s) => s.id == id);
  } catch (e) {
    return null;
  }
});

// ============ Reusable Widgets ============

// Reusable Skill Card Widget
class SkillCard extends StatelessWidget {
  final Skill skill;
  final VoidCallback? onTap;
  final VoidCallback? onInstall;
  final VoidCallback? onUninstall;
  final bool isInstalling;

  const SkillCard({
    super.key,
    required this.skill,
    this.onTap,
    this.onInstall,
    this.onUninstall,
    this.isInstalling = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInstalled = skill.isInstalled;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: skill.isFeatured
                ? Colors.blue.withOpacity(0.5)
                : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
            width: skill.isFeatured ? 2 : 1,
          ),
          boxShadow: skill.isFeatured
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
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: skill.isFeatured
                    ? Colors.blue.withOpacity(0.1)
                    : (isDark ? Colors.grey[800] : Colors.grey[100]),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  _buildSkillIcon(skill, isDark),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                skill.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black,
                                  fontFamily: 'monospace',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (skill.isFeatured) ...[
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
                        Row(
                          children: [
                            Text(
                              skill.author,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[400],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 12,
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  skill.formattedUsage,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            if (skill.rating != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[400],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.amber[400],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    skill.rating!.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
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
                      skill.description ?? 'No description available',
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
                    if (skill.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: skill.tags.take(2).map((tag) {
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
                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'v${skill.version}',
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                        if (isInstalling)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else if (isInstalled)
                          _buildStatusChip(
                            label: 'Installed',
                            icon: Icons.check_circle,
                            color: Colors.green,
                            isDark: isDark,
                          )
                        else
                          _buildActionButton(
                            label: 'Install',
                            color: Colors.blue,
                            onPressed: onInstall,
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

  Widget _buildSkillIcon(Skill skill, bool isDark) {
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
          '⚡',
          style: TextStyle(
            fontSize: 18,
            color: isDark ? Colors.blue[300] : Colors.blue[700],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
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
    );
  }

  Widget _buildActionButton({
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
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Reusable Category Filter Widget
class SkillCategoryFilterWidget extends StatelessWidget {
  final SkillCategory selectedCategory;
  final Function(SkillCategory) onCategorySelected;

  const SkillCategoryFilterWidget({
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
        itemCount: SkillCategory.values.length,
        itemBuilder: (context, index) {
          final category = SkillCategory.values[index];
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

// Reusable Search Bar Widget
class SkillSearchBarWidget extends StatelessWidget {
  final String query;
  final Function(String) onSearchChanged;

  const SkillSearchBarWidget({
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
          hintText: 'Search skills...',
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

// Reusable Skill Grid Widget
class SkillGridWidget extends StatelessWidget {
  final List<Skill> skills;
  final bool isLoading;
  final VoidCallback? onRetry;
  final Function(Skill) onSkillTap;
  final Function(Skill) onInstall;
  final Function(Skill) onUninstall;
  final Set<String> installingIds;

  const SkillGridWidget({
    super.key,
    required this.skills,
    this.isLoading = false,
    this.onRetry,
    required this.onSkillTap,
    required this.onInstall,
    required this.onUninstall,
    this.installingIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 350,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    if (skills.isEmpty) {
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
              'No skills found',
              style: TextStyle(
                color: isDark ? Colors.grey[600] : Colors.grey[600],
                fontSize: 16,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        final isInstalling = installingIds.contains(skill.id);

        return SkillCard(
          skill: skill,
          isInstalling: isInstalling,
          onTap: () => onSkillTap(skill),
          onInstall: () => onInstall(skill),
          onUninstall: () => onUninstall(skill),
        );
      },
    );
  }
}

// ============ Main Screen ============
class SkillsMarketplaceScreen extends ConsumerStatefulWidget {
  const SkillsMarketplaceScreen({super.key});

  @override
  ConsumerState<SkillsMarketplaceScreen> createState() =>
      _SkillsMarketplaceScreenState();
}

class _SkillsMarketplaceScreenState
    extends ConsumerState<SkillsMarketplaceScreen> {
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
    final skillsAsync = ref.watch(filteredSkillsProvider);
    final featuredAsync = ref.watch(featuredSkillsProvider);
    final category = ref.watch(selectedCategoryProvider);
    final query = ref.watch(searchQueryProvider);
    final installing = ref.watch(isInstallingProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            SkillSearchBarWidget(
              query: query,
              onSearchChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
            SkillCategoryFilterWidget(
              selectedCategory: category,
              onCategorySelected: (category) {
                ref.read(selectedCategoryProvider.notifier).state = category;
              },
            ),
            _buildFilterBar(context, skillsAsync),
            Expanded(
              child: Stack(
                children: [
                  skillsAsync.when(
                    data: (skills) => SkillGridWidget(
                      skills: skills,
                      onSkillTap: _showSkillDetails,
                      onInstall: _installSkill,
                      onUninstall: _uninstallSkill,
                      installingIds: installing,
                    ),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load skills',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              ref.invalidate(skillListProvider);
                              ref.invalidate(filteredSkillsProvider);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                    loading: () => SkillGridWidget(
                      skills: [],
                      isLoading: true,
                      onSkillTap: (_) {},
                      onInstall: (_) {},
                      onUninstall: (_) {},
                    ),
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
            onPressed: () => _showAddSkillDialog(context),
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

  Widget _buildFilterBar(
    BuildContext context,
    AsyncValue<List<Skill>> skillsAsync,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                'Filters by',
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
          Row(
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
              Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ],
          ),
          const Spacer(),
          skillsAsync.when(
            data: (skills) => Text(
              '${skills.length} skills',
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

  // ============ Dialog Methods ============
  void _showAddSkillDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Skill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.blue),
              title: const Text('Create New Skill'),
              subtitle: const Text('Build a custom skill from scratch'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.green),
              title: const Text('Install from Marketplace'),
              subtitle: const Text('Browse and install skills'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file, color: Colors.orange),
              title: const Text('Import Skill'),
              subtitle: const Text('Import from a file or URL'),
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
              title: const Text('Auto-Install Skills'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Show Beta Skills'),
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

  void _showSkillDetails(BuildContext context, Skill skill) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInstalled = skill.isInstalled;
    final isInstalling = ref.watch(isInstallingProvider).contains(skill.id);

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
                    child: const Center(
                      child: Text('⚡', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skill.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              skill.author,
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
                                color: skill.isFeatured
                                    ? Colors.blue.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                skill.isFeatured
                                    ? 'Featured'
                                    : 'v${skill.version}',
                                style: TextStyle(
                                  color: skill.isFeatured
                                      ? Colors.blue[300]
                                      : Colors.grey[400],
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
                        skill.longDescription ??
                            skill.description ??
                            'No description available',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (skill.features.isNotEmpty) ...[
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
                          children: skill.features.map((feature) {
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
                      if (skill.tags.isNotEmpty) ...[
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
                          children: skill.tags.map((tag) {
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
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${skill.formattedUsage} uses',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          if (skill.rating != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber[400],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  skill.rating!.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                          ],
                          Text(
                            'Updated ${skill.formattedDate}',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      if (skill.documentationUrl != null) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _openUrl(skill.documentationUrl!),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('View Documentation'),
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
                  if (isInstalled)
                    ElevatedButton.icon(
                      onPressed: () => _uninstallSkill(context, skill),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Uninstall'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: isInstalling
                          ? null
                          : () => _installSkill(context, skill),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _installSkill(BuildContext context, Skill skill) async {
    try {
      Navigator.of(context).pop();

      ref.read(isInstallingProvider.notifier).state = {
        ...ref.read(isInstallingProvider),
        skill.id,
      };

      final repository = ref.read(skillRepositoryProvider);
      await repository.installSkill(skill.id);

      ref.invalidate(skillListProvider);
      ref.invalidate(filteredSkillsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${skill.name} installed successfully!'),
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
          .where((id) => id != skill.id)
          .toSet();
    }
  }

  Future<void> _uninstallSkill(BuildContext context, Skill skill) async {
    final shouldUninstall = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uninstall Skill'),
        content: Text('Are you sure you want to uninstall "${skill.name}"?'),
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

      final repository = ref.read(skillRepositoryProvider);
      await repository.uninstallSkill(skill.id);

      ref.invalidate(skillListProvider);
      ref.invalidate(filteredSkillsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${skill.name} uninstalled'),
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
}
