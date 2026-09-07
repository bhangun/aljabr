import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aljabr_coding_core/aljabr_coding_core.dart';

final mutationIdsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final service = ref.read(backendServiceProvider);
  return await service.listMutations();
});
