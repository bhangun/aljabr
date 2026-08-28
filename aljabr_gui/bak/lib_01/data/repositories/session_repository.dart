import 'dart:convert';
import '../../core/errors/app_error.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/result.dart';
import '../../features/chat/models/message.dart';
import '../../features/chat/models/session.dart';
import '../datasources/local_storage_datasource.dart';
import '../models/json_models.dart';

/// Repository mediating between the domain layer and storage.
/// Business rules (sorting, generating IDs, import/export) live here.
import '../../core/entities/app_settings.dart';
import '../datasources/wayang_pro_api_datasource.dart';
import 'settings_repository.dart';

/// Repository mediating between the domain layer and storage.
/// Business rules (sorting, generating IDs, import/export) live here.
class SessionRepository {
  SessionRepository(this._api, this._settings);

  final WayangProApiDatasource _api;
  final SettingsRepository _settings;

  Future<Result<List<Session>>> getSessions(String projectId) async {
    final settings = await _settings.getSettings();
    if (settings.isFailure) return const Failure(StorageError('Failed to load settings'));
    return _api.getSessions(settings.valueOrNull!.wayangProBaseUrl, projectId);
  }

  Future<Result<Session>> createSession({
    String? title,
    String? systemPrompt,
    String? projectId,
  }) async {
    if (projectId == null) return const Failure(StorageError('Project ID is required'));
    final settings = await _settings.getSettings();
    if (settings.isFailure) return const Failure(StorageError('Failed to load settings'));
    return _api.createSession(settings.valueOrNull!.wayangProBaseUrl, projectId, title ?? 'New session');
  }

  Future<Result<void>> updateSession(Session session) async {
    if (session.projectId == null) return const Failure(StorageError('Project ID is required'));
    final settings = await _settings.getSettings();
    if (settings.isFailure) return const Failure(StorageError('Failed to load settings'));
    return _api.updateSession(settings.valueOrNull!.wayangProBaseUrl, session.projectId!, session);
  }

  Future<Result<void>> deleteSession(String id, {String? projectId}) async {
    if (projectId == null) return const Failure(StorageError('Project ID is required'));
    final settings = await _settings.getSettings();
    if (settings.isFailure) return const Failure(StorageError('Failed to load settings'));
    return _api.deleteSession(settings.valueOrNull!.wayangProBaseUrl, projectId, id);
  }

  Future<Result<void>> deleteAllSessions() async => const Success(null);

  Future<Result<void>> pinSession(String id, {required bool pinned, String? projectId, required Session session}) async {
    final updated = session.copyWith(isPinned: pinned);
    return updateSession(updated);
  }

  Future<Result<void>> renameSession(String id, String newTitle, {required Session session}) async {
    final updated = session.copyWith(title: newTitle);
    return updateSession(updated);
  }

  Future<Result<Session>> duplicateSession(String id, {required String projectId, required String newTitle}) async {
    final settings = await _settings.getSettings();
    if (settings.isFailure) return const Failure(StorageError('Failed to load settings'));
    return _api.duplicateSession(settings.valueOrNull!.wayangProBaseUrl, projectId, id, newTitle);
  }

  Future<Result<void>> saveSessionTranscript(String sessionId, String projectId, List<Message> messages) async {
    final settings = await _settings.getSettings();
    if (settings.isFailure) return const Failure(StorageError('Failed to load settings'));
    return _api.updateSessionTranscript(settings.valueOrNull!.wayangProBaseUrl, projectId, sessionId, messages);
  }

  Future<Result<List<Message>>> getSessionTranscript(String sessionId, String projectId) async {
    final settings = await _settings.getSettings();
    if (settings.isFailure) return const Failure(StorageError('Failed to load settings'));
    return _api.getSessionTranscript(settings.valueOrNull!.wayangProBaseUrl, projectId, sessionId);
  }

  // Legacy local storage specific methods:
  Future<Result<void>> addMessageToSession(String sessionId, Message message) async => const Success(null);
  Future<Result<void>> updateLastMessage(String sessionId, Message message) async => const Success(null);
  Future<Result<void>> truncateMessagesFrom(String sessionId, int fromIndex) async => const Success(null);

  // ── Export / Import ─────────────────────────────────────────────────────────

  Result<String> exportSession(Session session) => const Failure(StorageError('Not implemented'));
  Result<String> exportAllSessions(List<Session> sessions) => const Failure(StorageError('Not implemented'));
  Future<Result<List<Session>>> importFromJson(String jsonString) async => const Failure(StorageError('Not implemented'));
}
