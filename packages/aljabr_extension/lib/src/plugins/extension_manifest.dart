class ExtensionManifest {
  final String id;
  final String name;
  final String version;
  final String description;
  final String? author;
  final List<String> capabilities;
  final List<String> dependencies;
  final String? main;

  const ExtensionManifest({
    required this.id,
    required this.name,
    required this.version,
    this.description = '',
    this.author,
    this.capabilities = const [],
    this.dependencies = const [],
    this.main,
  });

  factory ExtensionManifest.fromJson(Map<String, dynamic> json) {
    return ExtensionManifest(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      version: json['version'] as String? ?? '1.0.0',
      description: json['description'] as String? ?? '',
      author: json['author'] as String?,
      capabilities: (json['capabilities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      dependencies: (json['dependencies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      main: json['main'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'version': version,
        'description': description,
        if (author != null) 'author': author,
        'capabilities': capabilities,
        'dependencies': dependencies,
        if (main != null) 'main': main,
      };
}
