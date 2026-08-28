import 'package:flutter/foundation.dart';

enum ComposerContextType {
  file,
  selection,
  folder,
  symbol,
  changeSet,
  execution,
  test,
  terminal
}

@immutable
class ComposerContext {
  final String id;
  final ComposerContextType type;
  final String label;
  final String? path;
  final int? startLine;
  final int? endLine;

  const ComposerContext({
    required this.id,
    required this.type,
    required this.label,
    this.path,
    this.startLine,
    this.endLine,
  });

  String get displayLabel {
    if (startLine != null && endLine != null) {
      return '$label:$startLine-$endLine';
    }
    return label;
  }
}
