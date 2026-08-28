import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/project_service.dart';

final projectServiceProvider = Provider<ProjectService>((ref) {
  final service = ProjectService();
  // Initialize immediately
  Future.microtask(() => service.init());
  return service;
});
