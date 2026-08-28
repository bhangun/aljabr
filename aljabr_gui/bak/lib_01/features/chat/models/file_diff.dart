import 'package:equatable/equatable.dart';

class FileDiff extends Equatable {
  const FileDiff({
    required this.fileId,
    required this.fileName,
    required this.originalContent,
    required this.modifiedContent,
    required this.lines,
    required this.addedLines,
    required this.removedLines,
  });

  final String fileId;
  final String fileName;
  final String originalContent;
  final String modifiedContent;
  final List<DiffLine> lines;
  final int addedLines;
  final int removedLines;

  bool get hasChanges => addedLines > 0 || removedLines > 0;

  @override
  List<Object?> get props => [
    fileId,
    fileName,
    originalContent,
    modifiedContent,
  ];
}

enum DiffLineType { added, removed, context }

class DiffLine extends Equatable {
  const DiffLine({
    required this.type,
    required this.content,
    this.oldLineNumber,
    this.newLineNumber,
  });

  final DiffLineType type;
  final String content;
  final int? oldLineNumber;
  final int? newLineNumber;

  @override
  List<Object?> get props => [type, content, oldLineNumber, newLineNumber];
}
