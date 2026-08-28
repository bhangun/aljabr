import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import 'view_location.dart';

class WorkbenchPanelDimensions {
  final double sidebarWidth;
  final double secondaryWidth;
  final double bottomHeight;
  final bool isSidebarVisible;
  final bool isSecondaryVisible;
  final bool isBottomVisible;

  const WorkbenchPanelDimensions({
    this.sidebarWidth = 260.0,
    this.secondaryWidth = 300.0,
    this.bottomHeight = 220.0,
    this.isSidebarVisible = true,
    this.isSecondaryVisible = false,
    this.isBottomVisible = false,
  });

  WorkbenchPanelDimensions copyWith({
    double? sidebarWidth,
    double? secondaryWidth,
    double? bottomHeight,
    bool? isSidebarVisible,
    bool? isSecondaryVisible,
    bool? isBottomVisible,
  }) {
    return WorkbenchPanelDimensions(
      sidebarWidth: (sidebarWidth ?? this.sidebarWidth).clamp(160.0, 700.0),
      secondaryWidth: (secondaryWidth ?? this.secondaryWidth).clamp(180.0, 700.0),
      bottomHeight: (bottomHeight ?? this.bottomHeight).clamp(80.0, 600.0),
      isSidebarVisible: isSidebarVisible ?? this.isSidebarVisible,
      isSecondaryVisible: isSecondaryVisible ?? this.isSecondaryVisible,
      isBottomVisible: isBottomVisible ?? this.isBottomVisible,
    );
  }

  Map<String, dynamic> toJson() => {
        'sidebarWidth': sidebarWidth,
        'secondaryWidth': secondaryWidth,
        'bottomHeight': bottomHeight,
        'isSidebarVisible': isSidebarVisible,
        'isSecondaryVisible': isSecondaryVisible,
        'isBottomVisible': isBottomVisible,
      };

  factory WorkbenchPanelDimensions.fromJson(Map<String, dynamic> json) {
    return WorkbenchPanelDimensions(
      sidebarWidth: (json['sidebarWidth'] as num?)?.toDouble() ?? 260.0,
      secondaryWidth: (json['secondaryWidth'] as num?)?.toDouble() ?? 300.0,
      bottomHeight: (json['bottomHeight'] as num?)?.toDouble() ?? 220.0,
      isSidebarVisible: json['isSidebarVisible'] as bool? ?? true,
      isSecondaryVisible: json['isSecondaryVisible'] as bool? ?? false,
      isBottomVisible: json['isBottomVisible'] as bool? ?? false,
    );
  }
}

class WorkbenchLayoutState {
  final Map<String, ViewLocation> locations;
  final Map<ViewArea, List<String>> openViews;
  final Map<ViewArea, String?> activeViews;
  final String? activeActivityId;
  final WorkbenchPanelDimensions dimensions;

  const WorkbenchLayoutState({
    required this.locations,
    required this.openViews,
    required this.activeViews,
    this.activeActivityId,
    this.dimensions = const WorkbenchPanelDimensions(),
  });

  factory WorkbenchLayoutState.empty() {
    return const WorkbenchLayoutState(
      locations: {},
      openViews: {},
      activeViews: {},
      activeActivityId: null,
      dimensions: WorkbenchPanelDimensions(),
    );
  }

  String? activeViewIn(ViewArea area) => activeViews[area];

  List<String> viewsIn(ViewArea area) => openViews[area] ?? const [];

  ViewLocation? locationOf(String viewId) => locations[viewId];

  WorkbenchLayoutState copyWith({
    Map<String, ViewLocation>? locations,
    Map<ViewArea, List<String>>? openViews,
    Map<ViewArea, String?>? activeViews,
    String? activeActivityId,
    WorkbenchPanelDimensions? dimensions,
  }) {
    return WorkbenchLayoutState(
      locations: locations ?? this.locations,
      openViews: openViews ?? this.openViews,
      activeViews: activeViews ?? this.activeViews,
      activeActivityId: activeActivityId ?? this.activeActivityId,
      dimensions: dimensions ?? this.dimensions,
    );
  }
}
