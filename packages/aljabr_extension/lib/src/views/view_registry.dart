import '../extensions/contribution_registry.dart';
import 'ui_region.dart';
import 'view_contribution.dart';

class ViewRegistry extends ContributionRegistry<ViewContribution> {
  List<ViewContribution> forRegion(UiRegion region) {
    final views = getAll().where((view) => view.defaultRegion == region).toList();
    views.sort((a, b) => a.order.compareTo(b.order));
    return views;
  }
}
