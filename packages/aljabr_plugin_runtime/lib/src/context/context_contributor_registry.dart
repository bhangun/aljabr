import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import '../extensions/contribution_registry.dart';

class ContextContributorRegistry
    extends ContributionRegistry<ContextContribution> {
  void build(ContextWriter writer) {
    final contributions = getAll();
    for (final contribution in contributions) {
      try {
        contribution.contribute(writer);
      } catch (_) {}
    }
  }
}
