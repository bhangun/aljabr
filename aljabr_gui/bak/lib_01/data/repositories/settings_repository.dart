import '../../core/entities/app_settings.dart';
import '../../core/utils/result.dart';
import '../datasources/local_storage_datasource.dart';

class SettingsRepository {
  SettingsRepository(this._storage);

  final LocalStorageDatasource _storage;

  Result<AppSettings> getSettings() => _storage.loadSettings();

  Future<Result<void>> saveSettings(AppSettings settings) =>
      _storage.saveSettings(settings);

  Future<Result<void>> updateApiKey(String key) async {
    final result = getSettings();
    return result.fold(
      onSuccess: (s) => saveSettings(s.copyWith(apiKey: key)),
      onFailure: (e) async => Failure(e),
    );
  }
}
