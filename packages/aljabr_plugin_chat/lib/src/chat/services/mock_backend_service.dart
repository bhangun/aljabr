import 'package:aljabr_coding_core/aljabr_coding_core.dart';

class MockBackendService implements BackendService {
  final List<Map<String, dynamic>> _messages = [];
  Future<Map<String, dynamic>> sendMessage(
      String sessionId, String content) async {
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 500));

    final response = {
      'id': 'msg-${DateTime.now().millisecondsSinceEpoch}',
      'content': 'Processing: $content',
      'status': 'completed',
      'toolCalls': [
        {
          'id': 'tc-${DateTime.now().millisecondsSinceEpoch}',
          'kind': 'runCommand',
          'summary': 'Processed: $content',
          'status': 'success',
        }
      ],
    };

    _messages.add(response);
    return response;
  }

  @override
  Future<List<Map<String, dynamic>>> listMessages(String sessionId) async {
    return _messages;
  }

  // Add test helpers
  void simulateError() {
    // Implementation
  }

  void simulateSlowResponse(Duration delay) {
    // Implementation
  }

  @override
  Future<Map<String, dynamic>> addMessage(String sessionId, String text) {
    // TODO: implement addMessage
    throw UnimplementedError();
  }

  @override
  Future<Project> createProject(
      String name, String description, String basePath) {
    // TODO: implement createProject
    throw UnimplementedError();
  }

  @override
  Future<Session> createSession(String projectId, String name) {
    // TODO: implement createSession
    throw UnimplementedError();
  }

  @override
  Future<Session> forkSession(String sessionId, [String? messageId]) {
    // TODO: implement forkSession
    throw UnimplementedError();
  }

  @override
  Future<List<Project>> listProjects() {
    // TODO: implement listProjects
    throw UnimplementedError();
  }

  @override
  Future<List<Session>> listSessions(String projectId) {
    // TODO: implement listSessions
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> listModels(String providerId) {
    // TODO: implement listModels
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> listProviders() {
    // TODO: implement listProviders
    throw UnimplementedError();
  }

  @override
  Stream<Map<String, dynamic>> runAgent(
      {required String sessionId,
      required String prompt,
      String? providerId,
      String? modelId,
      String? workspacePath,
      List<Attachment> attachments = const []}) {
    // TODO: implement runAgent
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    // Mock: no-op
  }

  @override
  Future<Map<String, dynamic>> indexWorkspace(String projectId,
      [String? workspacePath]) {
    // TODO: implement indexWorkspace
    throw UnimplementedError();
  }

  @override
  Future<List<String>> listMutations([String? providerId]) async {
    final id = providerId ?? 'default';
    return ['mutation-$id-1', 'mutation-$id-2'];
  }

  @override
  Future<String?> readMutation(String providerId, [String? mutationId]) async {
    if (mutationId == null) return null;
    return 'Mutation details for $providerId/$mutationId';
  }

  @override
  Stream<Map<String, dynamic>> startAgentRun(
      {required String request, String? workspacePath}) {
    // Emit structured step events so UI can consume planning->running->done.
    return (() async* {
      final now = DateTime.now();
      List<Map<String, dynamic>> steps = [
        {
          'id': 's1',
          'type': 'analysis',
          'status': 'pending',
          'title': 'Analyze repository',
          'description': 'Scanning for relevant code locations',
          'startedAt': now.toIso8601String(),
        },
        {
          'id': 's2',
          'type': 'fileRead',
          'status': 'pending',
          'title': 'Read target files',
          'description': 'Open files to inspect implementation',
          'startedAt': now.toIso8601String(),
        },
        {
          'id': 's3',
          'type': 'fileWrite',
          'status': 'pending',
          'title': 'Apply patch',
          'description': 'Modify code to implement requested change',
          'startedAt': now.toIso8601String(),
        },
        {
          'id': 's4',
          'type': 'test',
          'status': 'pending',
          'title': 'Run tests',
          'description': 'Execute unit test suite',
          'startedAt': now.toIso8601String(),
        },
        {
          'id': 's5',
          'type': 'verification',
          'status': 'pending',
          'title': 'Verify changes',
          'description': 'Check that tests and static checks pass',
          'startedAt': now.toIso8601String(),
        },
      ];

      // emit planning snapshot
      for (var s in steps) {
        yield {'event': 'step', 'data': s};
      }

      // run steps with delays to simulate actionable progress
      for (var s in steps) {
        await Future.delayed(const Duration(milliseconds: 500));
        var running = Map.of(s);
        running['status'] = 'running';
        yield {'event': 'step', 'data': running};

        await Future.delayed(const Duration(milliseconds: 800));
        var completed = Map.of(s);
        completed['status'] = s['type'] == 'test' ? 'failed' : 'completed';
        completed['completedAt'] = DateTime.now().toIso8601String();
        completed['durationMs'] = 1000;
        yield {'event': 'step', 'data': completed};

        if (s['type'] == 'test') {
          // emit inspect and retry steps
          await Future.delayed(const Duration(milliseconds: 300));
          var inspect = {
            'id': '${s['id']}-inspect',
            'type': 'analysis',
            'status': 'pending',
            'title': 'Inspect failures',
            'description': 'Analyze failing tests',
            'startedAt': DateTime.now().toIso8601String(),
          };
          yield {'event': 'step', 'data': inspect};
          await Future.delayed(const Duration(milliseconds: 400));
          inspect['status'] = 'completed';
          inspect['completedAt'] = DateTime.now().toIso8601String();
          yield {'event': 'step', 'data': inspect};

          var retry = {
            'id': '${s['id']}-retry',
            'type': 'fileWrite',
            'status': 'running',
            'title': 'Adjust implementation',
            'description': 'Fix failing assertion',
            'startedAt': DateTime.now().toIso8601String(),
          };
          yield {'event': 'step', 'data': retry};
          await Future.delayed(const Duration(milliseconds: 600));
          retry['status'] = 'completed';
          retry['completedAt'] = DateTime.now().toIso8601String();
          yield {'event': 'step', 'data': retry};

          var rerun = {
            'id': '${s['id']}-rerun',
            'type': 'test',
            'status': 'running',
            'title': 'Run tests (iteration 2)',
            'description': 'Run test suite again',
            'startedAt': DateTime.now().toIso8601String(),
          };
          yield {'event': 'step', 'data': rerun};
          await Future.delayed(const Duration(milliseconds: 800));
          rerun['status'] = 'completed';
          rerun['completedAt'] = DateTime.now().toIso8601String();
          yield {'event': 'step', 'data': rerun};
        }
      }

      // done
      yield {'event': 'done'};
    })();
  }

  @override
  Future<List<Map<String, dynamic>>> listSkills(
          {String? category, String? query, bool includeTrash = false}) async =>
      [];
  @override
  Future<Map<String, dynamic>> getSkill(String id) async =>
      throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> createSkill(Map<String, dynamic> data) async =>
      throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> updateSkill(
          String id, Map<String, dynamic> data) async =>
      throw UnimplementedError();
  @override
  Future<void> deleteSkill(String id, {bool hard = false}) async =>
      throw UnimplementedError();
  @override
  Future<List<Map<String, dynamic>>> listTrashedSkills() async => [];
  @override
  Future<void> restoreSkill(String id) async => throw UnimplementedError();
  @override
  Future<void> reloadSkills() async => throw UnimplementedError();
}
