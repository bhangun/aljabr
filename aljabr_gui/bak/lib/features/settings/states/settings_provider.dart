import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/entities/app_settings.dart';
import '../../../presentation/providers/infrastructure_providers.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._ref) : super(const AppSettings()) {
    _load();
  }

  final Ref _ref;

  void _load() {
    final result = _ref.read(settingsRepositoryProvider).getSettings();
    result.fold(
      onSuccess: (s) => state = s,
      onFailure: (_) {}, // keep default
    );
  }

  Future<void> updateProvider(AiProvider provider) async {
    state = state.copyWith(provider: provider);
    await _save();
  }

  Future<void> updateWayangProBaseUrl(String url) async {
    state = state.copyWith(wayangProBaseUrl: url);
    await _save();
  }

  Future<void> updateApiKey(String key) async {
    state = state.copyWith(apiKey: key);
    await _save();
  }

  Future<void> updateModel(String model) async {
    state = state.copyWith(model: model);
    await _save();
  }

  Future<void> updateSystemPrompt(String prompt) async {
    state = state.copyWith(systemPrompt: prompt);
    await _save();
  }

  Future<void> updateStreamingEnabled(bool enabled) async {
    state = state.copyWith(streamingEnabled: enabled);
    await _save();
  }

  Future<void> updateFontSize(double size) async {
    state = state.copyWith(fontSize: size);
    await _save();
  }

  Future<void> updateMaxTokens(int tokens) async {
    state = state.copyWith(maxTokens: tokens);
    await _save();
  }

  Future<void> _save() async {
    await _ref.read(settingsRepositoryProvider).saveSettings(state);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier(ref);
});
