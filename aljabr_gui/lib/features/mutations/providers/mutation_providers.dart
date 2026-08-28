import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/backend_providers.dart';

final mutationIdsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final service = ref.read(backendServiceProvider);
  return await service.listMutations();
});
