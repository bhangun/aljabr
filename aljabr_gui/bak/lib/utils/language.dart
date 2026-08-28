/// Maps a file path to a highlighter language id, based on its extension.
String languageForPath(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.properties')) return 'properties';
  if (lower.endsWith('.yml') || lower.endsWith('.yaml')) return 'yaml';
  if (lower.endsWith('.java')) return 'java';
  if (lower.endsWith('.sql')) return 'sql';
  if (lower.endsWith('.md')) return 'markdown';
  if (lower.endsWith('.xml') || lower.endsWith('.pom')) return 'xml';
  if (lower.endsWith('.json')) return 'json';
  if (lower.endsWith('.dart')) return 'dart';
  return 'text';
}
