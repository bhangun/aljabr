import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import '../extensions/placed_contribution_registry.dart';

class ActivityBarRegistry
    extends PlacedContributionRegistry<ActivityBarContribution> {
  List<ActivityBarContribution> resolve(
    ActivityBarSection section, {
    String? activeActivityId,
  }) {
    final items = getAll()
        .where((item) => item.section == section)
        .where((item) => item.isVisible?.call(activeActivityId) ?? true)
        .toList();

    items.sort(ContributionOrdering.compare);
    return items;
  }

  List<ActivityBarContribution> get primaryItems =>
      resolve(ActivityBarSection.primary);

  List<ActivityBarContribution> get secondaryItems =>
      resolve(ActivityBarSection.secondary);

  List<ActivityBarContribution> get bottomItems =>
      resolve(ActivityBarSection.bottom);
}
