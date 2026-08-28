/// Maps file extensions → highlight.js language identifiers.
abstract final class LanguageDetector {
  static const _map = {
    'dart': 'dart',
    'js': 'javascript',
    'ts': 'typescript',
    'jsx': 'javascript',
    'tsx': 'typescript',
    'py': 'python',
    'rb': 'ruby',
    'go': 'go',
    'rs': 'rust',
    'java': 'java',
    'kt': 'kotlin',
    'swift': 'swift',
    'cpp': 'cpp',
    'c': 'c',
    'h': 'c',
    'cs': 'csharp',
    'php': 'php',
    'html': 'html',
    'css': 'css',
    'scss': 'scss',
    'less': 'less',
    'json': 'json',
    'yaml': 'yaml',
    'yml': 'yaml',
    'toml': 'toml',
    'md': 'markdown',
    'sh': 'bash',
    'bash': 'bash',
    'zsh': 'bash',
    'sql': 'sql',
    'graphql': 'graphql',
    'tf': 'terraform',
    'xml': 'xml',
    'vue': 'xml',
    'svelte': 'xml',
    'r': 'r',
    'lua': 'lua',
    'ex': 'elixir',
    'exs': 'elixir',
    'erl': 'erlang',
    'hs': 'haskell',
    'clj': 'clojure',
    'scala': 'scala',
    'fs': 'fsharp',
  };

  static String fromExtension(String ext) =>
      _map[ext.toLowerCase()] ?? 'plaintext';

  static String fromPath(String path) {
    final idx = path.lastIndexOf('.');
    if (idx == -1) return 'plaintext';
    return fromExtension(path.substring(idx + 1));
  }

  static String fromFileName(String name) => fromPath(name);

  /// Icon codepoint for a language/extension
  static int iconFor(String ext) {
    return switch (ext.toLowerCase()) {
      'dart' => 0xe1bc,  // code icon
      'js' || 'ts' || 'jsx' || 'tsx' => 0xf15c,
      'py' => 0xe68a,
      'json' || 'yaml' || 'yml' => 0xe1b8,
      'md' => 0xe3c9,
      'html' || 'css' || 'scss' => 0xe1bb,
      'sh' || 'bash' => 0xe40c,
      _ => 0xe14e,  // description
    };
  }
}
