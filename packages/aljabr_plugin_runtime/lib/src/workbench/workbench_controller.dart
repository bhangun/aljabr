import 'dart:async';
import 'package:aljabr_plugin_api/aljabr_plugin_api.dart';
import '../views/view_registry.dart';
import 'view_location.dart';
import 'workbench_layout_resolver.dart';
import 'workbench_layout_state.dart';

abstract interface class WorkbenchControllerApi {
  WorkbenchLayoutState get layout;
  String? get activeActivityId;
  WorkbenchPanelDimensions get dimensions;

  void activateActivity(String activityId, {String? defaultViewId});
  void openView(String viewId, {ViewArea? area});
  void closeView(String viewId);
  void activateView(String viewId);
  void moveView(String viewId, ViewArea destination);

  void resizeSidebar(double width);
  void resizeSecondary(double width);
  void resizeBottom(double height);

  void toggleSidebar({bool? visible});
  void toggleSecondary({bool? visible});
  void toggleBottom({bool? visible});
}

class WorkbenchController implements WorkbenchControllerApi {
  final ViewRegistry views;
  final WorkbenchLayoutResolver layoutResolver;
  final StreamController<WorkbenchLayoutState> _stateController =
      StreamController<WorkbenchLayoutState>.broadcast();

  WorkbenchLayoutState _state = WorkbenchLayoutState.empty();

  WorkbenchController({
    required this.views,
    WorkbenchLayoutResolver? layoutResolver,
    WorkbenchPanelDimensions? initialDimensions,
  }) : layoutResolver = layoutResolver ?? WorkbenchLayoutResolver(views: views) {
    if (initialDimensions != null) {
      _state = _state.copyWith(dimensions: initialDimensions);
    }
  }

  @override
  WorkbenchLayoutState get layout => _state;

  @override
  String? get activeActivityId => _state.activeActivityId;

  @override
  WorkbenchPanelDimensions get dimensions => _state.dimensions;

  Stream<WorkbenchLayoutState> get onLayoutChanged => _stateController.stream;

  void _notify() {
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  @override
  void activateActivity(String activityId, {String? defaultViewId}) {
    final isSameActivity = _state.activeActivityId == activityId;
    if (isSameActivity && _state.dimensions.isSidebarVisible) {
      // Toggle sidebar if clicking already active activity
      toggleSidebar(visible: false);
      return;
    }

    _state = _state.copyWith(
      activeActivityId: activityId,
      dimensions: _state.dimensions.copyWith(isSidebarVisible: true),
    );

    if (defaultViewId != null) {
      openView(defaultViewId);
    } else {
      _notify();
    }
  }

  @override
  void openView(String viewId, {ViewArea? area}) {
    final existing = _state.locationOf(viewId);
    if (existing != null) {
      activateView(viewId);
      return;
    }

    final location = area != null
        ? ViewLocation(viewId: viewId, area: area)
        : layoutResolver.resolveInitialLocation(viewId);

    final newLocations = Map<String, ViewLocation>.from(_state.locations)
      ..[viewId] = location;

    final openViewsForArea =
        List<String>.from(_state.openViews[location.area] ?? [])..add(viewId);
    final newOpenViews = Map<ViewArea, List<String>>.from(_state.openViews)
      ..[location.area] = openViewsForArea;

    final newActiveViews = Map<ViewArea, String?>.from(_state.activeViews)
      ..[location.area] = viewId;

    var dimensions = _state.dimensions;
    if (location.area == ViewArea.sidebar && !dimensions.isSidebarVisible) {
      dimensions = dimensions.copyWith(isSidebarVisible: true);
    } else if (location.area == ViewArea.bottomPanel && !dimensions.isBottomVisible) {
      dimensions = dimensions.copyWith(isBottomVisible: true);
    } else if (location.area == ViewArea.secondaryPanel && !dimensions.isSecondaryVisible) {
      dimensions = dimensions.copyWith(isSecondaryVisible: true);
    }

    _state = _state.copyWith(
      locations: newLocations,
      openViews: newOpenViews,
      activeViews: newActiveViews,
      dimensions: dimensions,
    );
    _notify();
  }

  @override
  void closeView(String viewId) {
    final location = _state.locationOf(viewId);
    if (location == null) return;

    final newLocations = Map<String, ViewLocation>.from(_state.locations)
      ..remove(viewId);

    final openViewsForArea =
        List<String>.from(_state.openViews[location.area] ?? [])
          ..remove(viewId);
    final newOpenViews = Map<ViewArea, List<String>>.from(_state.openViews)
      ..[location.area] = openViewsForArea;

    final newActiveViews = Map<ViewArea, String?>.from(_state.activeViews);
    if (newActiveViews[location.area] == viewId) {
      newActiveViews[location.area] =
          openViewsForArea.isNotEmpty ? openViewsForArea.last : null;
    }

    _state = _state.copyWith(
      locations: newLocations,
      openViews: newOpenViews,
      activeViews: newActiveViews,
    );
    _notify();
  }

  @override
  void activateView(String viewId) {
    final location = _state.locationOf(viewId);
    if (location == null) {
      openView(viewId);
      return;
    }

    final newActiveViews = Map<ViewArea, String?>.from(_state.activeViews)
      ..[location.area] = viewId;

    var dimensions = _state.dimensions;
    if (location.area == ViewArea.sidebar && !dimensions.isSidebarVisible) {
      dimensions = dimensions.copyWith(isSidebarVisible: true);
    } else if (location.area == ViewArea.bottomPanel && !dimensions.isBottomVisible) {
      dimensions = dimensions.copyWith(isBottomVisible: true);
    } else if (location.area == ViewArea.secondaryPanel && !dimensions.isSecondaryVisible) {
      dimensions = dimensions.copyWith(isSecondaryVisible: true);
    }

    _state = _state.copyWith(activeViews: newActiveViews, dimensions: dimensions);
    _notify();
  }

  @override
  void moveView(String viewId, ViewArea destination) {
    final view = views.get(viewId);
    if (view == null || !view.behavior.movable) return;

    final current = _state.locationOf(viewId);
    if (current == null || current.area == destination) return;

    closeView(viewId);
    openView(viewId, area: destination);
  }

  @override
  void resizeSidebar(double width) {
    _state = _state.copyWith(
      dimensions: _state.dimensions.copyWith(sidebarWidth: width),
    );
    _notify();
  }

  @override
  void resizeSecondary(double width) {
    _state = _state.copyWith(
      dimensions: _state.dimensions.copyWith(secondaryWidth: width),
    );
    _notify();
  }

  @override
  void resizeBottom(double height) {
    _state = _state.copyWith(
      dimensions: _state.dimensions.copyWith(bottomHeight: height),
    );
    _notify();
  }

  @override
  void toggleSidebar({bool? visible}) {
    final current = _state.dimensions.isSidebarVisible;
    _state = _state.copyWith(
      dimensions: _state.dimensions.copyWith(
        isSidebarVisible: visible ?? !current,
      ),
    );
    _notify();
  }

  @override
  void toggleSecondary({bool? visible}) {
    final current = _state.dimensions.isSecondaryVisible;
    _state = _state.copyWith(
      dimensions: _state.dimensions.copyWith(
        isSecondaryVisible: visible ?? !current,
      ),
    );
    _notify();
  }

  @override
  void toggleBottom({bool? visible}) {
    final current = _state.dimensions.isBottomVisible;
    _state = _state.copyWith(
      dimensions: _state.dimensions.copyWith(
        isBottomVisible: visible ?? !current,
      ),
    );
    _notify();
  }

  void removeViewsOwnedBy(String ownerId) {
    final ownedViewIds = views
        .getAllForOwner(ownerId)
        .map((v) => v.id)
        .where((id) => _state.locations.containsKey(id))
        .toList();

    for (final viewId in ownedViewIds) {
      closeView(viewId);
    }
  }

  void dispose() {
    _stateController.close();
  }
}
