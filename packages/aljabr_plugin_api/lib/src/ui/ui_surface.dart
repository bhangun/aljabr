/// Stable UI extension surface identifiers for Aljabr workbench.
abstract final class UiSurfaces {
  static const activityBar = 'aljabr.ui.activityBar';
  static const globalToolbar = 'aljabr.ui.globalToolbar';
  static const statusBarLeft = 'aljabr.ui.statusBar.left';
  static const statusBarRight = 'aljabr.ui.statusBar.right';
  static const viewToolbar = 'aljabr.ui.viewToolbar';
  static const tabContextMenu = 'aljabr.ui.tabContextMenu';
  static const commandPalette = 'aljabr.ui.commandPalette';
  static const emptyState = 'aljabr.ui.emptyState';
  static const regionHeader = 'aljabr.ui.regionHeader';
}

/// Kinds of UI surfaces.
enum UiSurfaceKind {
  toolbar,
  menu,
  activityBar,
  statusBar,
  widget,
  command,
}

/// Definition of an extensible UI surface.
class UiSurfaceDefinition {
  final String id;
  final UiSurfaceKind kind;
  final bool allowThirdParty;

  const UiSurfaceDefinition({
    required this.id,
    required this.kind,
    this.allowThirdParty = true,
  });
}
