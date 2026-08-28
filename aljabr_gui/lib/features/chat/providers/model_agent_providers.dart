import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_entry.dart';
import '../../../data/backend_providers.dart';
import '../../backend_monitor/providers/backend_process_provider.dart';

const _kPrefsBox = 'aljabr_prefs';
const _kLastProvider = 'last_provider';
const _kLastModel = 'last_model';

/// Reads persisted value from Hive synchronously (box must already be open).
String _readPref(String key, String defaultValue) {
  try {
    final box = Hive.box(_kPrefsBox);
    return (box.get(key) as String?) ?? defaultValue;
  } catch (_) {
    return defaultValue;
  }
}

/// Writes a pref to Hive.
Future<void> _writePref(String key, String value) async {
  try {
    final box = Hive.box(_kPrefsBox);
    await box.put(key, value);
  } catch (_) {}
}

// ── Selected Provider ───────────────────────────────────────────────────────

class SelectedProviderNotifier extends StateNotifier<String> {
  SelectedProviderNotifier() : super(_readPref(_kLastProvider, 'gollek'));

  void select(String id) {
    state = id;
    _writePref(_kLastProvider, id);
  }
}

final selectedProviderProvider =
    StateNotifierProvider<SelectedProviderNotifier, String>(
  (ref) => SelectedProviderNotifier(),
);

// ── Selected Model ──────────────────────────────────────────────────────────

class SelectedModelNotifier extends StateNotifier<String> {
  SelectedModelNotifier()
      : super(_readPref(_kLastModel, 'hf:unsloth/gemma-4-12b-it-gguf'));

  void select(String id) {
    state = id;
    _writePref(_kLastModel, id);
  }
}

final selectedModelProvider =
    StateNotifierProvider<SelectedModelNotifier, String>(
  (ref) => SelectedModelNotifier(),
);

// ── Provider Options ────────────────────────────────────────────────────────

final providerOptionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final backendStatus = ref.watch(backendProcessProvider).status;
  if (backendStatus == BackendStatus.stopped ||
      backendStatus == BackendStatus.error) {
    return [];
  }
  final backendService = ref.watch(backendServiceProvider);
  for (int attempt = 0; attempt < 30; attempt++) {
    try {
      final providers = await backendService.listProviders();
      if (providers.isNotEmpty) {
        final current = ref.read(selectedProviderProvider);
        if (current.isEmpty) {
          final ids = providers.map((p) => p['id'] as String).toSet();
          final preferred = ids.contains('gollek')
              ? 'gollek'
              : providers.first['id'] as String;
          ref.read(selectedProviderProvider.notifier).select(preferred);
        }
      }
      return providers;
    } catch (e) {
      await Future.delayed(const Duration(seconds: 2));
    }
  }
  return [];
});

// ── Model Options ───────────────────────────────────────────────────────────

final modelOptionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final backendStatus = ref.watch(backendProcessProvider).status;
  if (backendStatus == BackendStatus.stopped ||
      backendStatus == BackendStatus.error) {
    return [];
  }
  final providerId = ref.watch(selectedProviderProvider);
  final backendService = ref.watch(backendServiceProvider);
  final resolvedProvider = providerId.isEmpty ? 'gollek' : providerId;

  for (int attempt = 0; attempt < 30; attempt++) {
    try {
      final models = await backendService.listModels(resolvedProvider);
      if (models.isNotEmpty) {
        final current = ref.read(selectedModelProvider);
        if (current.isEmpty) {
          ref
              .read(selectedModelProvider.notifier)
              .select(models.first['id'] as String);
        }
      }
      return models;
    } catch (e) {
      await Future.delayed(const Duration(seconds: 2));
    }
  }
  return [];
});

// ── Agent events ────────────────────────────────────────────────────────────

final agentEventsProvider =
    StreamProvider.family<ChatEntry, String>((ref, sessionId) {
  return ref.watch(agentRepositoryProvider).observeSession(sessionId);
});
