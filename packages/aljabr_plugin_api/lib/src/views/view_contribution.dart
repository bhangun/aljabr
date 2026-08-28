import 'package:flutter/widgets.dart';
import '../extensions/contribution_ordering.dart';
import 'ui_region.dart';
import 'view_area.dart';
import 'view_behavior.dart';
import 'view_placement.dart';

typedef ViewBuilder = Widget Function(BuildContext context);

class ViewContribution implements OrderedContribution {
  @override
  final String id;

  @override
  final String ownerId;

  final String title;
  final IconData? icon;
  final ViewPlacement preferredPlacement;
  final ViewBehavior behavior;

  @override
  final int order;

  final ViewBuilder builder;

  UiRegion get defaultRegion {
    switch (preferredPlacement.preferredArea) {
      case ViewArea.sidebar:
        return UiRegion.primarySidebar;
      case ViewArea.main:
        return UiRegion.mainWorkbench;
      case ViewArea.bottomPanel:
        return UiRegion.bottomPanel;
      case ViewArea.secondaryPanel:
        return UiRegion.secondarySidebar;
    }
  }

  const ViewContribution({
    required this.id,
    required this.ownerId,
    required this.title,
    this.icon,
    ViewPlacement? preferredPlacement,
    UiRegion? defaultRegion,
    this.behavior = ViewBehavior.panel,
    required this.builder,
    this.order = 0,
  }) : preferredPlacement = preferredPlacement ??
            (defaultRegion == UiRegion.primarySidebar || defaultRegion == UiRegion.sidebarFooter
                ? ViewPlacement.sidebar
                : defaultRegion == UiRegion.bottomPanel
                    ? ViewPlacement.bottomPanel
                    : defaultRegion == UiRegion.secondarySidebar
                        ? ViewPlacement.secondaryPanel
                        : ViewPlacement.main);
}
