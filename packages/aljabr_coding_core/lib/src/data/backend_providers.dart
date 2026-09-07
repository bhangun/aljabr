import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'backend_service.dart';

/// Provides the active [BackendService] implementation.
/// Host applications override this provider with GrpcBackendService or RestBackendService.
final backendServiceProvider = Provider<BackendService>((ref) {
  throw UnimplementedError('backendServiceProvider must be overridden by host application or provider scope');
});
