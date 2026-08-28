// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
class Plugin {
  final String name;
  final String author;
  final String lastUpdated;
  final String? description;
  final bool isInstalled;
  final bool isUploaded;

  Plugin({
    required this.name,
    required this.author,
    required this.lastUpdated,
    this.description,
    this.isInstalled = false,
    this.isUploaded = false,
  });

  Plugin copyWith({
    String? name,
    String? author,
    String? lastUpdated,
    String? description,
    bool? isInstalled,
    bool? isUploaded,
  }) {
    return Plugin(
      name: name ?? this.name,
      author: author ?? this.author,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      description: description ?? this.description,
      isInstalled: isInstalled ?? this.isInstalled,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }
}

// ============ Providers ============
final pluginListProvider = StateProvider<List<Plugin>>((ref) {
  return [
    Plugin(
      name: 'PDFViewer',
      author: 'Anthropic',
      lastUpdated: '7/15/26',
      description: 'View and annotate PDF documents',
    ),
    Plugin(
      name: 'Reflect',
      author: 'Anthropic',
      lastUpdated: '7/15/26',
      description: 'Reflection and analysis tools',
    ),
    Plugin(
      name: 'Claude Code',
      author: 'Anthropic',
      lastUpdated: '7/15/26',
      description: 'Code generation and analysis',
    ),
    Plugin(
      name: 'Custom Plugin',
      author: 'Developer',
      lastUpdated: '7/15/26',
      description: 'User-uploaded custom plugin',
      isUploaded: true,
    ),
  ];
});

final selectedPluginProvider = StateProvider<Plugin?>((ref) => null);

final isUploadDialogOpenProvider = StateProvider<bool>((ref) => false);

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredPluginsProvider = Provider<List<Plugin>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final plugins = ref.watch(pluginListProvider);

  if (query.isEmpty) return plugins;

  return plugins.where((plugin) {
    return plugin.name.toLowerCase().contains(query) ||
        plugin.author.toLowerCase().contains(query) ||
        (plugin.description?.toLowerCase().contains(query) ?? false);
  }).toList();
});

// ============ Main Screen ============
class PluginManagerScreen extends ConsumerStatefulWidget {
  const PluginManagerScreen({super.key});

  @override
  ConsumerState<PluginManagerScreen> createState() =>
      _PluginManagerScreenState();
}

class _PluginManagerScreenState extends ConsumerState<PluginManagerScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Search Bar
            _buildSearchBar(context),

            // Section Title
            _buildSectionTitle(),

            // Plugin List
            Expanded(child: _buildPluginList(context)),

            // Bottom Navigation
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            onPressed: () {
              // Navigate to settings
            },
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

  Widget _buildSearchBar(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: 'Search plugins...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[500]),
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

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Plugins',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton(onPressed: () {}, child: const Text('Browse')),
        ],
      ),
    );
  }

  Widget _buildPluginList(BuildContext context) {
    final plugins = ref.watch(filteredPluginsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (plugins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No plugins found',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: plugins.length,
      itemBuilder: (context, index) {
        final plugin = plugins[index];
        return _buildPluginItem(context, plugin);
      },
    );
  }

  Widget _buildPluginItem(BuildContext context, Plugin plugin) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: plugin.isUploaded
              ? Colors.orange.withOpacity(0.3)
              : Colors.grey[800]!,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: plugin.isUploaded
                ? Colors.orange.withOpacity(0.2)
                : Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            plugin.isUploaded ? Icons.cloud_upload : Icons.extension,
            color: plugin.isUploaded ? Colors.orange : Colors.blue,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              plugin.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                const SizedBox(width: 12),
                Text('•', style: TextStyle(color: Colors.grey[500])),
                const SizedBox(width: 12),
                Text(
                  plugin.lastUpdated,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
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
          ],
        ),
        trailing: plugin.isInstalled
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[300],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Installed',
                      style: TextStyle(color: Colors.green[300], fontSize: 12),
                    ),
                  ],
                ),
              )
            : IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  ref.read(selectedPluginProvider.notifier).state = plugin;
                  _showPluginOptions(context, plugin);
                },
              ),
        onTap: () {
          ref.read(selectedPluginProvider.notifier).state = plugin;
          _showPluginDetails(context, plugin);
        },
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
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icons[index],
                color: index == 0 ? Colors.blue : Colors.grey[500],
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                tabs[index],
                style: TextStyle(
                  color: index == 0 ? Colors.blue : Colors.grey[500],
                  fontSize: 12,
                  fontWeight: index == 0 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ============ Dialogs ============
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
                    'Upload local plugin',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[500]),
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
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[600]!,
                    style: BorderStyle.dashed,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, size: 40, color: Colors.grey[500]),
                    const SizedBox(height: 8),
                    Text(
                      'Drag and drop or click to upload',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
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
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Simulate upload
                      final newPlugin = Plugin(
                        name: 'Uploaded Plugin ${DateTime.now().millisecond}',
                        author: 'User',
                        lastUpdated: DateTime.now().toString().substring(0, 10),
                        description: 'Custom uploaded plugin',
                        isUploaded: true,
                      );

                      ref.read(pluginListProvider.notifier).state = [
                        ...ref.read(pluginListProvider),
                        newPlugin,
                      ];

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Plugin uploaded successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
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
        ),
      ),
    );
  }

  void _showPluginOptions(BuildContext context, Plugin plugin) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[850]
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.blue),
              title: const Text('Details'),
              onTap: () {
                Navigator.pop(context);
                _showPluginDetails(context, plugin);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined, color: Colors.green),
              title: const Text('Install'),
              onTap: () {
                final updatedPlugins = ref.read(pluginListProvider).map((p) {
                  if (p.name == plugin.name) {
                    return p.copyWith(isInstalled: true);
                  }
                  return p;
                }).toList();

                ref.read(pluginListProvider.notifier).state = updatedPlugins;
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${plugin.name} installed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            if (plugin.isUploaded)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete'),
                onTap: () {
                  final updatedPlugins = ref.read(pluginListProvider).where((
                    p,
                  ) {
                    return p.name != plugin.name;
                  }).toList();

                  ref.read(pluginListProvider.notifier).state = updatedPlugins;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Plugin deleted'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showPluginDetails(BuildContext context, Plugin plugin) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: plugin.isUploaded
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                plugin.isUploaded ? Icons.cloud_upload : Icons.extension,
                color: plugin.isUploaded ? Colors.orange : Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                plugin.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Author', plugin.author),
            _buildInfoRow('Last Updated', plugin.lastUpdated),
            if (plugin.description != null)
              _buildInfoRow('Description', plugin.description!),
            _buildInfoRow(
              'Status',
              plugin.isInstalled ? 'Installed' : 'Not installed',
            ),
            _buildInfoRow('Type', plugin.isUploaded ? 'Uploaded' : 'Official'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!plugin.isInstalled)
            ElevatedButton(
              onPressed: () {
                final updatedPlugins = ref.read(pluginListProvider).map((p) {
                  if (p.name == plugin.name) {
                    return p.copyWith(isInstalled: true);
                  }
                  return p;
                }).toList();

                ref.read(pluginListProvider.notifier).state = updatedPlugins;
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${plugin.name} installed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Install'),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
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
            ),
          ),
        ],
      ),
    );
  }
}
