import 'package:flutter/widgets.dart';
import '../extensions/contribution.dart';
import 'ui_region.dart';

typedef ViewBuilder = Widget Function(BuildContext context);

class ViewContribution implements OwnedContribution {
  @override
  final String id;

  @override
  final String ownerId;

  final String title;
  final IconData icon;
  final UiRegion defaultRegion;
  final int order;
  final ViewBuilder builder;

  const ViewContribution({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.icon,
    required this.defaultRegion,
    required this.builder,
    this.order = 0,
  });
}
