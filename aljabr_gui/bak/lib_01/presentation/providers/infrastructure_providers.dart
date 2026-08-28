import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/claude_api_datasource.dart';
import '../../data/datasources/wayang_pro_api_datasource.dart';
import '../../data/datasources/local_storage_datasource.dart';
import '../../data/datasources/snippets_datasource.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/snippets_repository.dart';

// ── Shared Preferences (async singleton, overridden in main()) ────────────────

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('Override in main()'),
);

// ── Datasources ───────────────────────────────────────────────────────────────

final localStorageDatasourceProvider = Provider<LocalStorageDatasource>((ref) {
  return LocalStorageDatasource(ref.watch(sharedPreferencesProvider));
});

final snippetsDatasourceProvider = Provider<SnippetsDatasource>((ref) {
  return SnippetsDatasource(ref.watch(sharedPreferencesProvider));
});

final claudeApiDatasourceProvider = Provider<ClaudeApiDatasource>((ref) {
  final ds = ClaudeApiDatasource();
  ref.onDispose(ds.dispose);
  return ds;
});

final wayangProApiDatasourceProvider = Provider<WayangProApiDatasource>((ref) {
  final ds = WayangProApiDatasource();
  ref.onDispose(ds.dispose);
  return ds;
});

// ── Repositories ──────────────────────────────────────────────────────────────

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(
    ref.watch(wayangProApiDatasourceProvider),
    ref.watch(settingsRepositoryProvider),
  );
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(
    ref.watch(wayangProApiDatasourceProvider),
    ref.watch(settingsRepositoryProvider),
  );
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(localStorageDatasourceProvider));
});


final snippetsRepositoryProvider = Provider<SnippetsRepository>((ref) {
  return SnippetsRepository(ref.watch(snippetsDatasourceProvider));
});
