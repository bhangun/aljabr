import 'dart:convert';
import '../../core/errors/app_error.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/result.dart';
import '../../features/chat/models/project.dart';
import '../../core/entities/app_settings.dart';
import '../datasources/wayang_pro_api_datasource.dart';
import 'settings_repository.dart';

class ProjectRepository {
  ProjectRepository(this._api, this._settings);

  final WayangProApiDatasource _api;
  final SettingsRepository _settings;

  Future<Result<List<Project>>> getProjects() async {
    try {
      final settings = await _settings.getSettings();
      if (settings.isFailure) return const Failure(StorageError('Failed to load settings'));
      final baseUrl = settings.valueOrNull!.wayangProBaseUrl;
      final result = await _api.getProjects(baseUrl);
      if (result.isSuccess) {
        final projects = result.valueOrNull!;
        projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return Success(projects);
      }
      return result;
    } catch (e) {
      return Failure(StorageError('Failed to load projects: $e'));
    }
  }

  Future<Result<Project>> createProject({
    required String name,
    String? path,
  }) async {
    try {
      final settings = await _settings.getSettings();
      if (settings.isFailure) return const Failure(StorageError('Failed to load settings'));
      final baseUrl = settings.valueOrNull!.wayangProBaseUrl;
      return await _api.createProject(baseUrl, name);
    } catch (e) {
      return Failure(StorageError('Failed to create project: $e'));
    }
  }

  Future<Result<void>> updateProject(Project project) async {
    // Note: The backend doesn't currently expose project updates
    return const Success(null);
  }

  Future<Result<void>> deleteProject(String id) async {
    // Note: The backend doesn't currently expose project deletion
    return const Success(null);
  }
}
