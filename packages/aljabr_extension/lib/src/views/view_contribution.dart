import 'package:flutter/widgets.dart';
import 'ui_region.dart';

class ViewContribution {
  final String id;
  final String title;
  final IconData? icon;
  final UiRegion defaultRegion;
  final Widget Function(BuildContext context) builder;

  const ViewContribution({
    required this.id,
    required this.title,
    this.icon,
    required this.defaultRegion,
    required this.builder,
  });
}
