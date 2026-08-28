import 'package:flutter_riverpod/legacy.dart';

import '../models/problem_item.dart';

/// Diagnostics & Problems list (populated from verification ladder / LSP / compiler)
class ProblemsNotifier extends StateNotifier<List<ProblemItem>> {
  ProblemsNotifier()
      : super(const [
          ProblemItem(
            id: 'prob-1',
            filePath: 'src/main/java/com/wayang/SessionResource.java',
            line: 155,
            column: 9,
            message: 'TODO: paginate this once we have real volume',
            ruleId: 'java:S1135',
            category: 'CODE_SMELL',
            severity: ProblemSeverity.info,
          ),
          ProblemItem(
            id: 'prob-2',
            filePath: 'src/main/resources/application.properties',
            line: 88,
            column: 1,
            message: 'Default dummy master key in application properties',
            ruleId: 'CWE-798',
            category: 'SECURITY',
            severity: ProblemSeverity.warning,
          ),
        ]);

  void setProblems(List<ProblemItem> problems) => state = problems;

  void addProblem(ProblemItem problem) => state = [...state, problem];

  void removeProblem(String id) =>
      state = state.where((p) => p.id != id).toList();

  void clear() => state = const [];
}

final problemsProvider =
    StateNotifierProvider<ProblemsNotifier, List<ProblemItem>>(
  (ref) => ProblemsNotifier(),
);
