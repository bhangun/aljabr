import '../features/project/models/project.dart';
import '../features/chat/models/attachment.dart';
import '../features/project/models/session.dart';

abstract class BackendService {
  // Projects
  Future<List<Project>> listProjects();
  Future<Project> createProject(
      String name, String description, String basePath);

  // Sessions
  Future<List<Session>> listSessions(String projectId);
  Future<Session> createSession(String projectId, String name);
  Future<void> deleteSession(String sessionId);
  Future<Session> forkSession(String sessionId, [String? messageId]);

  // Indexing & Intelligence
  Future<Map<String, dynamic>> indexWorkspace(String projectId,
      [String? workspacePath]);

  // Chat history
  Future<List<Map<String, dynamic>>> listMessages(String sessionId);
  Future<Map<String, dynamic>> addMessage(String sessionId, String text);

  // Agent execution – sends a prompt to the coder agent and returns the run
  // result. The caller is responsible for streaming / polling follow-up events.
  Stream<Map<String, dynamic>> runAgent({
    required String sessionId,
    required String prompt,
    String? providerId,
    String? modelId,
    String? workspacePath,
    List<Attachment> attachments = const [],
  });

  // Agent run APIs: start a named agent run and stream step/event updates.
  Stream<Map<String, dynamic>> startAgentRun({
    required String request,
    String? workspacePath,
  });

  // SDK / Provider Discovery
  Future<List<Map<String, dynamic>>> listProviders();
  Future<List<Map<String, dynamic>>> listModels(String providerId);

  // Mutation records (audit/evidence produced by workspace patches)
  Future<List<String>> listMutations([String? workspacePath]);
  Future<String?> readMutation(String id, [String? workspacePath]);

  // Skills Management
  Future<List<Map<String, dynamic>>> listSkills(
      {String? category, String? query, bool includeTrash = false});
  Future<Map<String, dynamic>> getSkill(String id);
  Future<Map<String, dynamic>> createSkill(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateSkill(
      String id, Map<String, dynamic> data);
  Future<void> deleteSkill(String id, {bool hard = false});
  Future<List<Map<String, dynamic>>> listTrashedSkills();
  Future<void> restoreSkill(String id);
  Future<void> reloadSkills();
}
