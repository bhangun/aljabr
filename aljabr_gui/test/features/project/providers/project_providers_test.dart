import 'package:aljabr/features/project/providers/project_list_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aljabr/data/backend_providers.dart';

import '../../../mock_backend_service.dart';

void main() {
  group('Project Providers Unit Tests', () {
    late MockBackendService mockBackendService;
    late ProviderContainer container;

    setUp(() {
      mockBackendService = MockBackendService();

      // Override the real backend service with our mock
      container = ProviderContainer(
        overrides: [
          backendServiceProvider.overrideWithValue(mockBackendService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('projectListProvider loads projects on initialization', () async {
      // Setup mock response
      when(() => mockBackendService.listProjects())
          .thenAnswer((_) async => TestData.projects);

      // Read the provider. This triggers the constructor and the refresh/retry logic
      container.read(projectListProvider.notifier);

      // Initial state is empty
      expect(container.read(projectListProvider), isEmpty);

      // Wait for the async load to complete
      // We yield a few microtasks to let the Future in the constructor resolve
      await Future.delayed(Duration.zero);

      // State should now have the projects
      final projects = container.read(projectListProvider);
      expect(projects, isNotEmpty);
      expect(projects.length, 2);
      expect(projects.first.id, 'proj-1');

      // Verify that listProjects was called exactly once
      verify(() => mockBackendService.listProjects()).called(1);
    });

    test('projectListProvider retries when backend is down', () async {
      // First call throws, second call succeeds
      var callCount = 0;
      when(() => mockBackendService.listProjects()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw Exception('Connection refused');
        }
        return TestData.projects;
      });

      // The notifier's constructor calls _loadWithRetry which waits 2 seconds on failure
      container.read(projectListProvider.notifier);

      // First attempt failed, state is empty
      await Future.delayed(Duration.zero);
      expect(container.read(projectListProvider), isEmpty);

      // Wait for the retry delay (2 seconds)
      await Future.delayed(const Duration(seconds: 2, milliseconds: 100));

      // Second attempt should have succeeded
      final projects = container.read(projectListProvider);
      expect(projects.length, 2);

      // Verify listProjects was called twice
      verify(() => mockBackendService.listProjects()).called(2);
    });
  });
}
