import '../extensions/contribution_registry.dart';
import 'activity_bar_contribution.dart';

class ActivityBarRegistry
    extends ContributionRegistry<ActivityBarContribution> {
  List<ActivityBarContribution> forPlacement(ActivityBarPlacement placement) {
    final items = getAll()
        .where((item) => item.placement == placement)
        .toList();
    items.sort((a, b) => a.order.compareTo(b.order));
    return items;
  }

  List<ActivityBarContribution> get topItems =>
      forPlacement(ActivityBarPlacement.top);

  List<ActivityBarContribution> get bottomItems =>
      forPlacement(ActivityBarPlacement.bottom);
}
