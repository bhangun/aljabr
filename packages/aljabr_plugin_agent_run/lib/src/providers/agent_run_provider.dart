import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/agent_run.dart';
import '../models/agent_step.dart';
import '../models/agent_run_status.dart';
import '../services/agent_run_service.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';

final agentRunProvider = StateNotifierProvider<AgentRunNotifier, AgentRun?>(
  (ref) => AgentRunNotifier(ref),
);

class AgentRunNotifier extends StateNotifier<AgentRun?> {
  final Ref _ref;
  StreamSubscription? _sub;

  AgentRunNotifier(this._ref) : super(null);

  void startRun(String request) {
    final now = DateTime.now();
    final run = AgentRun(
      id: 'run-${now.millisecondsSinceEpoch}',
      request: request,
      status: AgentRunStatus.planning,
      steps: [],
      startedAt: now,
    );
    state = run;

    // Prefer backend-run stream if available
    try {
      final backend = _ref.read(backendServiceProvider);
      final stream =
          backend.startAgentRun(request: request, workspacePath: null);
      _sub = stream.listen((event) {
        final ev = event['event'] as String?;
        if (ev == 'step') {
          final data = Map<String, dynamic>.from(event['data'] as Map);
          final step = AgentStep.fromMap(data);
          _applyStepUpdate(step);
          if (step.type == AgentStepType.approval &&
              step.status == AgentStepStatus.pending) {
            // pause run
            state = state?.copyWith(status: AgentRunStatus.waitingForApproval);
          }
        } else if (ev == 'done') {
          final current = state;
          if (current != null) {
            state = current.copyWith(
                status: AgentRunStatus.completed, completedAt: DateTime.now());
          }
          _sub?.cancel();
          _sub = null;
        }
      }, onError: (e) {
        final current = state;
        if (current != null) {
          state = current.copyWith(
              status: AgentRunStatus.failed, error: e.toString());
        }
      });
    } catch (e) {
      // fallback to local simulation
      final svc = _ref.read(agentRunServiceProvider);
      svc.startRun(run, onStepUpdate: (step) {
        _applyStepUpdate(step);
      }, onComplete: (finalRun) {
        state = finalRun;
      });
    }
  }

  void _applyStepUpdate(AgentStep step) {
    final current = state;
    if (current == null) return;
    final idx = current.steps.indexWhere((s) => s.id == step.id);
    List<AgentStep> next = List.from(current.steps);
    if (idx >= 0) {
      next[idx] = step;
    } else {
      next.add(step);
    }
    state = current.copyWith(status: AgentRunStatus.running, steps: next);
  }

  void approve() {
    final current = state;
    if (current == null) return;
    state = current.copyWith(status: AgentRunStatus.running);
    // resume backend subscription if paused — no-op for demo
  }

  void cancel() {
    final current = state;
    if (current == null) return;
    state = current.copyWith(
        status: AgentRunStatus.cancelled, completedAt: DateTime.now());
    _sub?.cancel();
    _sub = null;
  }
}
