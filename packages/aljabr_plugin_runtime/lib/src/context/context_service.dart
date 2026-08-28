import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import 'context_contributor_registry.dart';

class ContextService {
  final ContextContributorRegistry registry;

  const ContextService({
    required this.registry,
  });

  ContextSnapshot snapshot() {
    final builder = ContextBuilder();
    registry.build(builder);
    return builder.build();
  }
}
