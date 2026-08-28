import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aljabr/data/backend_providers.dart';
import 'package:aljabr/features/chat/providers/model_agent_providers.dart';

import 'package:aljabr/features/backend_monitor/providers/backend_process_provider.dart';

import '../../../mock_backend_service.dart';

class _RunningBackendProcessNotifier extends BackendProcessNotifier {
  @override
  BackendState build() => BackendState(status: BackendStatus.running);
}

void main() {
  group('Model and Provider Option Tests', () {
    late MockBackendService mockBackendService;
    late ProviderContainer container;

    setUp(() {
      mockBackendService = MockBackendService();
      
      container = ProviderContainer(
        overrides: [
          backendServiceProvider.overrideWithValue(mockBackendService),
          backendProcessProvider.overrideWith(() => _RunningBackendProcessNotifier()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('providerOptionsProvider loads successfully', () async {
      when(() => mockBackendService.listProviders())
          .thenAnswer((_) async => TestData.providers);

      final providers = await container.read(providerOptionsProvider.future);
      
      expect(providers.length, 4);
      expect(providers.first['id'], 'gollek');
      verify(() => mockBackendService.listProviders()).called(1);
    });

    test('modelOptionsProvider loads default models when no provider is selected', () async {
      when(() => mockBackendService.listProviders())
          .thenAnswer((_) async => TestData.providers);
      
      // We expect the first provider is 'gollek'
      when(() => mockBackendService.listModels('gollek'))
          .thenAnswer((_) async => TestData.gollekModels);

      // We haven't selected a provider, so it should default to the first one's models
      final models = await container.read(modelOptionsProvider.future);
      
      expect(models.length, 2);
      expect(models.first['id'], 'llama-3-8b');
      
      verify(() => mockBackendService.listModels('gollek')).called(1);
    });

    test('modelOptionsProvider loads specific models when provider is selected', () async {
      when(() => mockBackendService.listModels('openai'))
          .thenAnswer((_) async => TestData.openaiModels);

      // Select openai provider
      container.read(selectedProviderProvider.notifier).state = 'openai';

      final models = await container.read(modelOptionsProvider.future);
      
      expect(models.length, 2);
      expect(models.first['id'], 'gpt-4o');
      
      // Verify it didn't call listProviders, only listModels for openai
      verifyNever(() => mockBackendService.listProviders());
      verify(() => mockBackendService.listModels('openai')).called(1);
    });
  });
}
