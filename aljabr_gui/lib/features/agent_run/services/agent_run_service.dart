import 'dart:async';
import '../models/agent_run.dart';
import '../models/agent_step.dart';
import '../models/agent_run_status.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final agentRunServiceProvider =
    Provider<AgentRunService>((ref) => AgentRunService());

class AgentRunService {
  /// Start a simulated run. Calls callbacks for each step update and final run.
  void startRun(AgentRun run,
      {required void Function(AgentStep) onStepUpdate,
      required void Function(AgentRun) onComplete}) {
    // Simulate a plan then step execution with delays
    final steps = [
      AgentStep(
          id: 's1',
          type: AgentStepType.analysis,
          status: AgentStepStatus.pending,
          title: 'Analyze repository',
          description: 'Scanning for auth flow',
          startedAt: DateTime.now()),
      AgentStep(
          id: 's2',
          type: AgentStepType.fileRead,
          status: AgentStepStatus.pending,
          title: 'Read SessionService.java',
          description: 'Open file to inspect auth logic',
          startedAt: DateTime.now()),
      AgentStep(
          id: 's3',
          type: AgentStepType.fileWrite,
          status: AgentStepStatus.pending,
          title: 'Modify SessionService.java',
          description: 'Make session lookup null-safe',
          startedAt: DateTime.now()),
      AgentStep(
          id: 's4',
          type: AgentStepType.test,
          status: AgentStepStatus.pending,
          title: 'Run tests',
          description: 'Execute unit test suite',
          startedAt: DateTime.now()),
      AgentStep(
          id: 's5',
          type: AgentStepType.verification,
          status: AgentStepStatus.pending,
          title: 'Verify changes',
          description: 'Check that failing tests are resolved',
          startedAt: DateTime.now()),
    ];

    // schedule timeline: initial planning
    Timer(const Duration(milliseconds: 200), () {
      for (var s in steps) {
        onStepUpdate(s);
      }
    });

    // run steps sequentially
    Future<void>.delayed(const Duration(milliseconds: 600), () async {
      for (var s in steps) {
        // running
        var running = s.copyWith(status: AgentStepStatus.running);
        onStepUpdate(running);
        await Future.delayed(const Duration(milliseconds: 800));

        // simulate success/failure
        var completed = running.copyWith(
            status: s.type == AgentStepType.test
                ? AgentStepStatus.failed
                : AgentStepStatus.completed,
            completedAt: DateTime.now(),
            duration: const Duration(seconds: 1));
        onStepUpdate(completed);

        // if test failed, create an approval step or iteration
        if (s.type == AgentStepType.test &&
            completed.status == AgentStepStatus.failed) {
          var inspect = AgentStep(
              id: '${s.id}-inspect',
              type: AgentStepType.analysis,
              status: AgentStepStatus.pending,
              title: 'Inspect failures',
              description: 'Analyze failing tests',
              startedAt: DateTime.now());
          onStepUpdate(inspect);
          await Future.delayed(const Duration(milliseconds: 400));
          onStepUpdate(inspect.copyWith(
              status: AgentStepStatus.completed,
              completedAt: DateTime.now(),
              duration: const Duration(milliseconds: 300)));

          // retry modify+test
          var retry = AgentStep(
              id: '${s.id}-retry',
              type: AgentStepType.fileWrite,
              status: AgentStepStatus.running,
              title: 'Adjust implementation',
              description: 'Fix failing assertion',
              startedAt: DateTime.now());
          onStepUpdate(retry);
          await Future.delayed(const Duration(milliseconds: 600));
          onStepUpdate(retry.copyWith(
              status: AgentStepStatus.completed, completedAt: DateTime.now()));

          var rerun = AgentStep(
              id: '${s.id}-rerun',
              type: AgentStepType.test,
              status: AgentStepStatus.running,
              title: 'Run tests (iteration 2)',
              description: 'Run test suite again',
              startedAt: DateTime.now());
          onStepUpdate(rerun);
          await Future.delayed(const Duration(milliseconds: 800));
          onStepUpdate(rerun.copyWith(
              status: AgentStepStatus.completed, completedAt: DateTime.now()));
        }
      }

      // final run complete
      var finalRun =
          run.copyWith(status: AgentRunStatus.completed, steps: steps);
      onComplete(finalRun);
    });
  }
}
