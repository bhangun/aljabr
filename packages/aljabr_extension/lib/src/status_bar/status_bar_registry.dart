import '../extensions/contribution_registry.dart';
import 'status_bar_alignment.dart';
import 'status_bar_context.dart';
import 'status_bar_contribution.dart';

class StatusBarRegistry extends ContributionRegistry<StatusBarContribution> {
  List<StatusBarContribution> resolve(
    StatusBarContext context,
    StatusBarAlignment alignment,
  ) {
    final items = getAll()
        .where((item) => item.alignment == alignment)
        .where((item) => item.isVisible?.call(context) ?? true)
        .toList();

    items.sort((a, b) => a.order.compareTo(b.order));
    return items;
  }

  List<StatusBarContribution> forAlignment(StatusBarAlignment alignment) {
    return resolve(const StatusBarContext(), alignment);
  }

  List<StatusBarContribution> get leftItems => forAlignment(StatusBarAlignment.start);
  List<StatusBarContribution> get rightItems => forAlignment(StatusBarAlignment.end);
}
