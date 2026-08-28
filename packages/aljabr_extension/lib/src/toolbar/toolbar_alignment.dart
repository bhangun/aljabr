abstract final class ToolbarTargets {
  static const app = 'aljabr.toolbar.app';
  static const editor = 'aljabr.toolbar.editor';
  static const agent = 'aljabr.toolbar.agent';
  static const terminal = 'aljabr.toolbar.terminal';
}

enum ToolbarAlignment {
  start,
  center,
  end,
}

enum ToolbarItemKind {
  command,
  action,
  widget,
  menu,
}
