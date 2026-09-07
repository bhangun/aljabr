enum ProblemSeverity { error, warning, info }

class ProblemItem {
  final String id;
  final String filePath;
  final int line;
  final int column;
  final String message;
  final String ruleId;
  final String category; // SECURITY, BUG, CODE_SMELL, COMPILER
  final ProblemSeverity severity;

  const ProblemItem({
    required this.id,
    required this.filePath,
    required this.line,
    this.column = 1,
    required this.message,
    required this.ruleId,
    required this.category,
    required this.severity,
  });
}
