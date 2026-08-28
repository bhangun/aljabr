import '../extensions/contribution_registry.dart';
import 'capability.dart';

class CapabilityRegistry extends ContributionRegistry<CapabilityContribution> {
  bool has(String capabilityId) => contains(capabilityId);

  List<String> get availableCapabilities =>
      getAll().map((c) => c.id).toList();
}
