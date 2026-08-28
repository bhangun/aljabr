## Next: Phase A — AppTheme + Design Tokens

We now turn the checkpoint into **real implementation**. I would make this the first foundational layer before touching more UI behavior.

Assuming the existing app is Flutter/Dart, create:

```text
lib/
├── app/
│   ├── app.dart
│   └── theme/
│       ├── app_theme.dart
│       ├── app_colors.dart
│       ├── app_spacing.dart
│       ├── app_radii.dart
│       ├── app_typography.dart
│       └── app_motion.dart
│
└── core/
    └── widgets/
        └── app_surface.dart
```

---

# 1. `app_colors.dart`

```dart
import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceActive;

  final Color border;
  final Color borderStrong;

  final Color text;
  final Color textMuted;
  final Color textSubtle;

  final Color accent;
  final Color accentMuted;

  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceActive,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textMuted,
    required this.textSubtle,
    required this.accent,
    required this.accentMuted,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  static const dark = AppColors(
    background: Color(0xFF101114),
    surface: Color(0xFF17181C),
    surfaceElevated: Color(0xFF1D1F24),
    surfaceActive: Color(0xFF252831),

    border: Color(0xFF292C33),
    borderStrong: Color(0xFF3A3E47),

    text: Color(0xFFE7E9ED),
    textMuted: Color(0xFF9CA1AA),
    textSubtle: Color(0xFF70757F),

    accent: Color(0xFF7C9CFF),
    accentMuted: Color(0xFF2A3350),

    success: Color(0xFF55C58A),
    warning: Color(0xFFE4B65A),
    error: Color(0xFFE06C75),
    info: Color(0xFF69A8E8),
  );

  static const light = AppColors(
    background: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF1F3F6),
    surfaceActive: Color(0xFFE8EBF0),

    border: Color(0xFFD9DDE5),
    borderStrong: Color(0xFFBEC4CF),

    text: Color(0xFF1B1D22),
    textMuted: Color(0xFF626873),
    textSubtle: Color(0xFF8A909A),

    accent: Color(0xFF4969D8),
    accentMuted: Color(0xFFE4E9FF),

    success: Color(0xFF248A58),
    warning: Color(0xFF9A6A00),
    error: Color(0xFFC23B45),
    info: Color(0xFF3174B8),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceActive,
    Color? border,
    Color? borderStrong,
    Color? text,
    Color? textMuted,
    Color? textSubtle,
    Color? accent,
    Color? accentMuted,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceActive: surfaceActive ?? this.surfaceActive,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      textSubtle: textSubtle ?? this.textSubtle,
      accent: accent ?? this.accent,
      accentMuted: accentMuted ?? this.accentMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  AppColors lerp(
    covariant AppColors? other,
    double t,
  ) {
    if (other == null) return this;

    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated:
          Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceActive:
          Color.lerp(surfaceActive, other.surfaceActive, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong:
          Color.lerp(borderStrong, other.borderStrong, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textSubtle: Color.lerp(textSubtle, other.textSubtle, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentMuted:
          Color.lerp(accentMuted, other.accentMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
```

---

# 2. `app_spacing.dart`

Keep spacing predictable.

```dart
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}
```

---

# 3. `app_radii.dart`

```dart
abstract final class AppRadii {
  static const double sm = 4;
  static const double md = 6;
  static const double lg = 8;
  static const double xl = 12;
}
```

For the IDE, keep these restrained.

We don't want every component looking like a rounded mobile card.

---

# 4. `app_motion.dart`

```dart
abstract final class AppMotion {
  static const fast = Duration(milliseconds: 100);
  static const normal = Duration(milliseconds: 160);
  static const slow = Duration(milliseconds: 240);
}
```

And standard curves:

```dart
import 'package:flutter/animation.dart';

abstract final class AppCurves {
  static const standard = Curves.easeOutCubic;
  static const emphasized = Curves.easeInOutCubic;
}
```

---

# 5. `app_typography.dart`

```dart
import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const title = TextStyle(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w600,
  );

  static const section = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w600,
  );

  static const body = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
  );

  static const caption = TextStyle(
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w400,
  );

  static const code = TextStyle(
    fontSize: 13,
    height: 20 / 13,
    fontFamily: 'JetBrains Mono',
  );
}
```

If JetBrains Mono is not yet bundled, replace it with the actual monospace font already used by the project.

---

# 6. `app_theme.dart`

Now combine the system.

```dart
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_motion.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    final colors = AppColors.dark;

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,

      scaffoldBackgroundColor:
          colors.background,

      extensions: [
        colors,
      ],

      colorScheme: ColorScheme.dark(
        surface: colors.surface,
        primary: colors.accent,
        error: colors.error,
      ),

      textTheme: const TextTheme(
        titleMedium: AppTypography.title,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.caption,
      ),

      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),

      tooltipTheme: TooltipThemeData(
        waitDuration: AppMotion.fast,
        showDuration: const Duration(seconds: 4),
      ),

      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(8),
        radius: const Radius.circular(4),
      ),
    );
  }

  static ThemeData light() {
    final colors = AppColors.light;

    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,

      scaffoldBackgroundColor:
          colors.background,

      extensions: [
        colors,
      ],

      colorScheme: ColorScheme.light(
        surface: colors.surface,
        primary: colors.accent,
        error: colors.error,
      ),

      textTheme: const TextTheme(
        titleMedium: AppTypography.title,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.caption,
      ),

      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static AppColors colorsOf(
    BuildContext context,
  ) {
    return Theme.of(context)
        .extension<AppColors>()!;
  }
}
```

---

# 7. `app_surface.dart`

Now create the first reusable visual primitive.

```dart
import 'package:flutter/material.dart';

import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme.dart';

class AppSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool elevated;

  const AppSurface({
    super.key,
    required this.child,
    this.padding,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: elevated
            ? colors.surfaceElevated
            : colors.surface,
        border: Border.all(
          color: colors.border,
        ),
        borderRadius: BorderRadius.circular(
          AppRadii.md,
        ),
      ),
      child: Padding(
        padding: padding ??
            const EdgeInsets.all(
              AppSpacing.md,
            ),
        child: child,
      ),
    );
  }
}
```

---

# 8. Root application

Now wire it into the actual app.

```dart
class AljabrApp extends StatelessWidget {
  const AljabrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aljabr',

      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,

      home: const AppShell(),
    );
  }
}
```

---

# 9. `AppShell`

The shell should now become extremely simple.

```dart
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: const WorkspaceLayout(),
    );
  }
}
```

Notice what we **don't** do here:

```text
❌ business logic
❌ Agent logic
❌ editor logic
❌ command handling
❌ file operations
```

The shell is composition.

---

# 10. First WorkspaceLayout

For the next checkpoint, don't implement the complete resizable system yet.

Establish the structural hierarchy:

```dart
class WorkspaceLayout extends StatelessWidget {
  const WorkspaceLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        ActivityBar(),

        Sidebar(),

        Expanded(
          child: WorkspaceCenter(),
        ),

        AgentPanel(),
      ],
    );
  }
}
```

The center then becomes:

```dart
class WorkspaceCenter extends StatelessWidget {
  const WorkspaceCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        EditorTabs(),

        Expanded(
          child: EditorArea(),
        ),

        BottomPanel(),
      ],
    );
  }
}
```

This gives us the canonical shell.

---

# 11. Add the first visual boundary

```dart
class PanelDivider extends StatelessWidget {
  const PanelDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return ColoredBox(
      color: colors.border,
      child: const SizedBox(
        width: 1,
      ),
    );
  }
}
```

Then:

```dart
Row(
  children: const [
    ActivityBar(),
    PanelDivider(),
    Sidebar(),
    PanelDivider(),
    Expanded(
      child: WorkspaceCenter(),
    ),
    PanelDivider(),
    AgentPanel(),
  ],
)
```

Now we have consistent boundaries.

---

# 12. One important refinement

Do **not** add borders to every child.

Use hierarchy:

```text
Application
│
├── Activity Bar
│
├── Sidebar
│
├── Main Workspace
│   ├── Editor
│   └── Bottom Panel
│
└── Agent
```

The major regions get boundaries.

Internal components should generally rely on:

```text
spacing
background difference
hover
selection
```

instead of more borders.

---

# 13. Add a real surface hierarchy

The visual hierarchy should now be:

```text
BACKGROUND
#101114

     ↓

SURFACE
#17181C

     ↓

ELEVATED
#1D1F24

     ↓

ACTIVE
#252831
```

That gives us depth without shadows everywhere.

---

# 14. Active state

For example, an active sidebar item:

```dart
class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppCurves.standard,
      decoration: BoxDecoration(
        color: selected
            ? colors.surfaceActive
            : Colors.transparent,
        borderRadius: BorderRadius.circular(
          AppRadii.sm,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: selected
                ? colors.text
                : colors.textMuted,
          ),
          const SizedBox(
            width: AppSpacing.sm,
          ),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body.copyWith(
                color: selected
                    ? colors.text
                    : colors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

This is the type of component we want to replicate everywhere.

---

# 15. Result

After this pass, the visual system becomes:

```text
                 AppTheme
                    │
        ┌───────────┼───────────┐
        ↓           ↓           ↓
      Colors      Spacing     Motion
        │           │           │
        └───────────┼───────────┘
                    ↓
              App Components
                    │
                    ↓
                AppShell
                    │
         ┌──────────┼──────────┐
         ↓          ↓          ↓
     Activity     Workspace   Agent
       Bar           │
                     ├── Editor
                     ├── Tabs
                     └── Bottom
```

That is the correct foundation.

---

# 16. Checkpoint after this step

We should now have:

```text
✅ Central color system
✅ Dark/light theme foundation
✅ Typography system
✅ Spacing system
✅ Radius system
✅ Motion system
✅ Surface primitive
✅ Panel divider
✅ App shell
✅ Workspace hierarchy
✅ Semantic active states
```

And importantly:

```text
❌ No feature-specific business logic inside theme
❌ No duplicated raw colors
❌ No random spacing
❌ No random animation durations
❌ No random border colors
```

---

## Next implementation

**Phase A.2 should be `WorkspaceController + resizable panels + persisted layout`.**

That is where the static shell above becomes the actual IDE workspace:

```text
Activity Bar
      │
      ├── Sidebar ← drag resize →
      │
      ├── Editor ← drag split →
      │
      ├── Bottom Panel ← drag resize →
      │
      └── Agent ← drag resize →
```

Then we persist the user's layout so the workspace comes back exactly as they left it.


# Next — Phase A.2: Workspace Controller + Resizable Panels

Now we turn the shell into a **real IDE workspace**.

The key architectural rule:

> The widgets render layout. `WorkspaceController` owns layout state.

That prevents the UI from becoming a collection of independent `setState()` calls.

---

## 1. Add the workspace layer

```text id="0q7h8s"
lib/
└── workspace/
    ├── controller/
    │   └── workspace_controller.dart
    │
    ├── model/
    │   └── workspace_layout.dart
    │
    ├── persistence/
    │   └── workspace_layout_store.dart
    │
    └── widgets/
        ├── workspace_layout.dart
        ├── resizable_panel.dart
        ├── activity_bar.dart
        ├── sidebar.dart
        ├── editor_area.dart
        ├── bottom_panel.dart
        └── agent_panel.dart
```

---

# 2. Layout model

Don't store arbitrary widget state.

Define the actual workspace state:

```dart id="j6tq3c"
class WorkspaceLayout {
  final double sidebarWidth;
  final double agentWidth;
  final double bottomPanelHeight;

  final bool sidebarVisible;
  final bool agentVisible;
  final bool bottomPanelVisible;

  const WorkspaceLayout({
    this.sidebarWidth = 280,
    this.agentWidth = 360,
    this.bottomPanelHeight = 240,
    this.sidebarVisible = true,
    this.agentVisible = true,
    this.bottomPanelVisible = true,
  });

  WorkspaceLayout copyWith({
    double? sidebarWidth,
    double? agentWidth,
    double? bottomPanelHeight,
    bool? sidebarVisible,
    bool? agentVisible,
    bool? bottomPanelVisible,
  }) {
    return WorkspaceLayout(
      sidebarWidth:
          sidebarWidth ?? this.sidebarWidth,
      agentWidth:
          agentWidth ?? this.agentWidth,
      bottomPanelHeight:
          bottomPanelHeight ??
              this.bottomPanelHeight,
      sidebarVisible:
          sidebarVisible ?? this.sidebarVisible,
      agentVisible:
          agentVisible ?? this.agentVisible,
      bottomPanelVisible:
          bottomPanelVisible ??
              this.bottomPanelVisible,
    );
  }
}
```

---

# 3. Why this matters

Now every layout change becomes:

```text id="p3u4ds"
User drags sidebar
       ↓
WorkspaceController
       ↓
WorkspaceLayout
       ↓
UI rebuild
       ↓
Persist
```

Instead of:

```text id="d6q5ab"
Sidebar somehow changes itself
Agent somehow knows about it
Editor has another width
Persistence has a third width
```

One source of truth.

---

# 4. Controller

```dart id="h7j5b0"
import 'package:flutter/foundation.dart';

import '../model/workspace_layout.dart';

class WorkspaceController
    extends ChangeNotifier {

  WorkspaceLayout _layout =
      const WorkspaceLayout();

  WorkspaceLayout get layout => _layout;

  void setSidebarWidth(double width) {
    final clamped = width.clamp(
      220.0,
      480.0,
    );

    _layout = _layout.copyWith(
      sidebarWidth: clamped,
    );

    notifyListeners();
  }

  void setAgentWidth(double width) {
    final clamped = width.clamp(
      280.0,
      600.0,
    );

    _layout = _layout.copyWith(
      agentWidth: clamped,
    );

    notifyListeners();
  }

  void setBottomPanelHeight(double height) {
    final clamped = height.clamp(
      120.0,
      500.0,
    );

    _layout = _layout.copyWith(
      bottomPanelHeight: clamped,
    );

    notifyListeners();
  }

  void toggleSidebar() {
    _layout = _layout.copyWith(
      sidebarVisible:
          !_layout.sidebarVisible,
    );

    notifyListeners();
  }

  void toggleAgent() {
    _layout = _layout.copyWith(
      agentVisible:
          !_layout.agentVisible,
    );

    notifyListeners();
  }

  void toggleBottomPanel() {
    _layout = _layout.copyWith(
      bottomPanelVisible:
          !_layout.bottomPanelVisible,
    );

    notifyListeners();
  }
}
```

---

# 5. Don't let panels own their widths

Avoid this:

```dart id="h3r4vp"
class Sidebar extends State<Sidebar> {
  double width = 280;
}
```

That creates competing sources of truth.

Instead:

```dart id="5e9c4n"
Sidebar(
  width: controller.layout.sidebarWidth,
)
```

The controller owns the number.

---

# 6. Generic resize handle

Create one reusable component.

```dart id="cq4o0d"
class ResizeHandle extends StatelessWidget {
  final Axis axis;
  final ValueChanged<double> onDelta;

  const ResizeHandle({
    super.key,
    required this.axis,
    required this.onDelta,
  });

  @override
  Widget build(BuildContext context) {
    final cursor = axis == Axis.horizontal
        ? SystemMouseCursors.resizeLeftRight
        : SystemMouseCursors.resizeUpDown;

    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          final delta = axis == Axis.horizontal
              ? details.delta.dx
              : details.delta.dy;

          onDelta(delta);
        },
        child: SizedBox(
          width: axis == Axis.horizontal
              ? 4
              : double.infinity,
          height: axis == Axis.vertical
              ? 4
              : double.infinity,
        ),
      ),
    );
  }
}
```

---

# 7. Important UX detail

The visible divider can be:

```text id="ynw3p0"
1px
```

but the actual drag target should be:

```text id="k3z4d5"
4–8px
```

This gives the user a small but forgiving hit area.

---

# 8. Sidebar resizing

```dart id="e5z7ki"
Row(
  children: [
    SizedBox(
      width: controller.layout.sidebarWidth,
      child: const Sidebar(),
    ),

    ResizeHandle(
      axis: Axis.horizontal,
      onDelta: (delta) {
        controller.setSidebarWidth(
          controller.layout.sidebarWidth + delta,
        );
      },
    ),

    const Expanded(
      child: WorkspaceCenter(),
    ),
  ],
)
```

---

# 9. Agent resizing

Same principle:

```dart id="f6a5l9"
Row(
  children: [
    Expanded(
      child: WorkspaceCenter(),
    ),

    if (controller.layout.agentVisible) ...[
      ResizeHandle(
        axis: Axis.horizontal,
        onDelta: (delta) {
          controller.setAgentWidth(
            controller.layout.agentWidth - delta,
          );
        },
      ),

      SizedBox(
        width: controller.layout.agentWidth,
        child: const AgentPanel(),
      ),
    ],
  ],
)
```

Notice the reversed delta.

Dragging the separator right means the Agent becomes smaller.

---

# 10. Bottom panel

```dart id="6smv0a"
Column(
  children: [
    Expanded(
      child: EditorArea(),
    ),

    if (controller.layout.bottomPanelVisible) ...[
      ResizeHandle(
        axis: Axis.vertical,
        onDelta: (delta) {
          controller.setBottomPanelHeight(
            controller.layout.bottomPanelHeight -
                delta,
          );
        },
      ),

      SizedBox(
        height:
            controller.layout.bottomPanelHeight,
        child: const BottomPanel(),
      ),
    ],
  ],
)
```

---

# 11. Workspace provider

If we're using `ChangeNotifier`, expose it above the workspace.

```dart id="2f7v7q"
class WorkspaceScope
    extends InheritedNotifier<WorkspaceController> {

  const WorkspaceScope({
    super.key,
    required WorkspaceController controller,
    required super.child,
  }) : super(notifier: controller);

  static WorkspaceController of(
    BuildContext context,
  ) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<
            WorkspaceScope>();

    assert(scope != null);

    return scope!.notifier!;
  }
}
```

Then:

```dart id="5cn0e1"
WorkspaceScope(
  controller: workspaceController,
  child: const WorkspaceLayout(),
)
```

---

# 12. Workspace layout

Now the actual layout becomes:

```dart id="n4i3v9"
class WorkspaceLayout extends StatelessWidget {
  const WorkspaceLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
        WorkspaceScope.of(context);

    final layout = controller.layout;

    return Row(
      children: [
        const ActivityBar(),

        if (layout.sidebarVisible) ...[
          const PanelDivider(),

          SizedBox(
            width: layout.sidebarWidth,
            child: const Sidebar(),
          ),

          ResizeHandle(
            axis: Axis.horizontal,
            onDelta: controller.setSidebarWidth,
          ),
        ],

        Expanded(
          child: WorkspaceCenter(
            controller: controller,
          ),
        ),

        if (layout.agentVisible) ...[
          ResizeHandle(
            axis: Axis.horizontal,
            onDelta: (delta) {
              controller.setAgentWidth(
                layout.agentWidth - delta,
              );
            },
          ),

          const PanelDivider(),

          SizedBox(
            width: layout.agentWidth,
            child: const AgentPanel(),
          ),
        ],
      ],
    );
  }
}
```

---

# 13. Center workspace

```dart id="m40n9f"
class WorkspaceCenter extends StatelessWidget {
  final WorkspaceController controller;

  const WorkspaceCenter({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final layout = controller.layout;

    return Column(
      children: [
        const EditorTabs(),

        Expanded(
          child: const EditorArea(),
        ),

        if (layout.bottomPanelVisible) ...[
          ResizeHandle(
            axis: Axis.vertical,
            onDelta: (delta) {
              controller.setBottomPanelHeight(
                layout.bottomPanelHeight - delta,
              );
            },
          ),

          SizedBox(
            height:
                layout.bottomPanelHeight,
            child: const BottomPanel(),
          ),
        ],
      ],
    );
  }
}
```

---

# 14. Add resize feedback

This is a subtle but important polish point.

During resize:

```text id="v8y9x3"
sidebar
   │
   │ ← dragging
   │
   │
```

The divider should become visually active.

Add:

```dart id="u1byh4"
class ResizeHandle extends StatefulWidget {
  ...
}
```

Then track hover/drag state.

```dart id="ps7n0n"
bool _active = false;
```

and:

```dart id="2gk5g6"
MouseRegion(
  onEnter: (_) {
    setState(() => _active = true);
  },
  onExit: (_) {
    setState(() => _active = false);
  },
  child: ...
)
```

Use:

```dart id="8w5d9x"
color: _active
    ? colors.accent
    : colors.border
```

Keep the active indicator subtle.

---

# 15. Prevent accidental negative sizes

Never directly trust pointer deltas.

Always clamp:

```dart id="1g3f6r"
width.clamp(
  minWidth,
  maxWidth,
)
```

This is why the controller owns the dimensions.

---

# 16. Persistence

Now add:

```dart id="p7f8ws"
abstract interface class WorkspaceLayoutStore {
  Future<WorkspaceLayout?> load();

  Future<void> save(
    WorkspaceLayout layout,
  );
}
```

This gives us an abstraction over whatever persistence layer the application uses.

---

# 17. Don't couple persistence to UI

Bad:

```dart id="9x7b3e"
onPanUpdate:
  saveToDisk(...)
```

That would potentially write on every mouse event.

Instead:

```text id="m5xw5n"
drag
 ↓
controller updates
 ↓
UI updates immediately
 ↓
debounced persistence
```

---

# 18. Debounced save

```dart id="d4r3x8"
Timer? _saveTimer;

void scheduleSave() {
  _saveTimer?.cancel();

  _saveTimer = Timer(
    const Duration(milliseconds: 400),
    () {
      store.save(_layout);
    },
  );
}
```

Then call it after layout changes.

This prevents dozens of writes during a single drag.

---

# 19. Controller with persistence

The important section becomes:

```dart id="v4g8j2"
void setSidebarWidth(double width) {
  final clamped = width.clamp(
    220.0,
    480.0,
  );

  _layout = _layout.copyWith(
    sidebarWidth: clamped,
  );

  notifyListeners();
  scheduleSave();
}
```

Same for:

```text id="n8g0h2"
Agent width
Bottom height
Visibility
```

---

# 20. Restore layout

At application startup:

```dart id="2fd2c8"
Future<void> restore() async {
  final saved = await store.load();

  if (saved == null) {
    return;
  }

  _layout = saved;

  notifyListeners();
}
```

Then:

```dart id="5y9z1g"
await workspaceController.restore();
```

before presenting the fully interactive workspace.

---

# 21. Better startup behavior

Don't make the whole app wait unnecessarily.

Use:

```text id="5i0qfw"
Default layout
      ↓
render immediately
      ↓
load persisted layout
      ↓
replace with saved layout
```

If loading is extremely fast, users won't notice.

If persistence becomes remote or expensive, the UI still starts quickly.

---

# 22. Layout presets

Now we can add one very useful feature almost for free:

```dart id="z7s2v4"
enum WorkspacePreset {
  coding,
  review,
  debugging,
  agent,
}
```

Example:

```dart id="l7fd5x"
WorkspaceLayout preset(
  WorkspacePreset preset,
) {
  switch (preset) {
    case WorkspacePreset.coding:
      return const WorkspaceLayout(
        sidebarWidth: 280,
        agentVisible: false,
        bottomPanelVisible: false,
      );

    case WorkspacePreset.review:
      return const WorkspaceLayout(
        sidebarWidth: 240,
        agentVisible: false,
        bottomPanelVisible: true,
        bottomPanelHeight: 300,
      );

    case WorkspacePreset.debugging:
      return const WorkspaceLayout(
        sidebarWidth: 260,
        agentVisible: false,
        bottomPanelVisible: true,
        bottomPanelHeight: 360,
      );

    case WorkspacePreset.agent:
      return const WorkspaceLayout(
        sidebarWidth: 240,
        agentVisible: true,
        agentWidth: 420,
        bottomPanelVisible: false,
      );
  }
}
```

---

# 23. But don't destroy personalization

Presets should be:

```text id="c7e5u5"
Apply preset
```

not:

```text id="z5qk9f"
forced mode
```

The user can then resize panels normally.

---

# 24. Keyboard commands

Now our previous command architecture connects directly to layout.

```dart id="v4x0zn"
registry.register(
  AppCommand(
    id: CommandId.toggleSidebar,
    title: 'Toggle Sidebar',
    category: 'View',

    execute: (_) async {
      workspaceController.toggleSidebar();

      return const CommandResult.success();
    },
  ),
);
```

Same for:

```text id="6r2h0f"
Toggle Agent
Toggle Bottom Panel
Focus Editor
Focus Agent
Focus Terminal
```

---

# 25. This is where the architecture starts paying off

The same action can now come from:

```text id="f5z5uw"
Keyboard
   ↓
Ctrl+Shift+B

Command Palette
   ↓
"Toggle Sidebar"

Toolbar
   ↓
Sidebar icon

Menu
   ↓
View → Sidebar

Agent
   ↓
"Open the sidebar"
```

All execute:

```text id="j5v8pp"
CommandId.toggleSidebar
```

One implementation.

---

# 26. Resize keyboard controls

For accessibility and precision, add keyboard resizing.

When the resize handle has focus:

```text id="d8f5a8"
← / →
```

changes width.

For vertical:

```text id="6g9g3f"
↑ / ↓
```

changes height.

Example:

```dart id="4xj6zv"
void resizeByKeyboard(double delta) {
  controller.setSidebarWidth(
    controller.layout.sidebarWidth + delta,
  );
}
```

---

# 27. Double-click divider

A nice desktop convention:

```text id="j7x5n2"
double-click divider
        ↓
restore default width
```

For example:

```dart id="2r8k5e"
onDoubleTap: () {
  controller.setSidebarWidth(280);
}
```

This is a small interaction with significant usability value.

---

# 28. Collapse behavior

When the sidebar is hidden:

```text id="u7g7bp"
[Activity Bar] [Editor.......................]
```

Don't set width to zero and lose the state.

Keep:

```text id="xj7q9f"
sidebarWidth = 340
sidebarVisible = false
```

Then reopening restores the user's 340px width.

Same for Agent.

---

# 29. Responsive constraint

Eventually, the available editor width should be protected.

Don't allow:

```text id="y6f8vq"
Sidebar 450
Agent 600
Editor 80
```

Instead calculate:

```dart id="0n0a0r"
const minEditorWidth = 400.0;
```

and dynamically constrain side panels.

Conceptually:

```text id="u5j1r2"
available width
       -
sidebar
       -
agent
       ≥
minimum editor
```

This should be the next refinement after the first resize implementation.

---

# 30. Checkpoint

After this phase:

```text id="d9qg5f"
                    WorkspaceController
                           │
                     WorkspaceLayout
                           │
          ┌────────────────┼────────────────┐
          ↓                ↓                ↓
       Sidebar           Editor            Agent
          ↕                ↕                 ↕
       resize           resize            resize
          │                │                 │
          └────────────────┼─────────────────┘
                           ↓
                       Persistence
```

We now have:

```text id="5x6b9g"
✅ Centralized layout state
✅ Resizable sidebar
✅ Resizable Agent
✅ Resizable bottom panel
✅ Collapse/expand
✅ Resize constraints
✅ Mouse cursor feedback
✅ Layout persistence abstraction
✅ Debounced saving
✅ Layout restoration
✅ Layout presets
✅ Keyboard integration
```

---

# Next: Phase B — Command System

Now that the workspace itself is stateful, the next logical step is to make **every important action a first-class command**.

We'll implement the actual:

```text id="6b1y7q"
CommandId
    ↓
AppCommand
    ↓
CommandRegistry
    ↓
CommandBus
    ↓
KeyBinding
    ↓
Command Palette
    ↓
Context Menu
    ↓
Toolbar
```

and then migrate the existing UI actions onto it.

That is the point where Aljabr stops having "buttons that do things" and starts having a **coherent interaction system**.


# Phase B — Command System

Now we connect the UI to the architecture we established.

The goal is:

```text
Keyboard
Command Palette
Toolbar
Menu
Context Menu
Agent
       │
       ▼
  CommandRegistry
       │
       ▼
    CommandBus
       │
       ▼
   Application Action
```

No UI component should contain the actual application operation.

---

## 1. Create the command structure

```text
lib/
└── commands/
    ├── command_id.dart
    ├── app_command.dart
    ├── command_context.dart
    ├── command_result.dart
    ├── command_registry.dart
    ├── command_bus.dart
    └── commands/
        ├── view_commands.dart
        ├── editor_commands.dart
        ├── agent_commands.dart
        └── workspace_commands.dart
```

---

# 2. `command_id.dart`

Keep IDs strongly typed.

```dart
enum CommandId {
  // View
  toggleSidebar,
  toggleAgent,
  toggleBottomPanel,

  // Workspace
  focusEditor,
  focusAgent,
  focusSidebar,
  focusBottomPanel,

  // Editor
  saveFile,
  closeEditor,
  closeOtherEditors,
  closeAllEditors,

  // Navigation
  goToFile,
  goToSymbol,
  findInFiles,
  findReferences,
  goToDefinition,

  // Agent
  askAgent,
  explainSelection,
  fixSelection,
  reviewChanges,

  // Changes
  acceptChange,
  rejectChange,
  acceptAllChanges,
  rejectAllChanges,

  // Verification
  runTests,
  runCurrentTest,

  // History
  undo,
  redo,

  // Application
  openCommandPalette,
}
```

The important thing here is that **the ID is the API**.

The button doesn't care how the command works.

---

# 3. `command_context.dart`

Commands often need information about the current workspace.

```dart
class CommandContext {
  final String? filePath;
  final String? selectedText;
  final String? symbol;
  final bool editorHasFocus;
  final bool agentHasFocus;

  const CommandContext({
    this.filePath,
    this.selectedText,
    this.symbol,
    this.editorHasFocus = false,
    this.agentHasFocus = false,
  });
}
```

Later this can grow into:

```text
CommandContext
├── workspace
├── editor
├── selection
├── git
├── agent
├── diagnostics
└── tests
```

But don't overbuild it yet.

---

# 4. `command_result.dart`

Every command should return a predictable result.

```dart
enum CommandResultStatus {
  success,
  cancelled,
  unavailable,
  failure,
}

class CommandResult {
  final CommandResultStatus status;
  final String? message;

  const CommandResult({
    required this.status,
    this.message,
  });

  const CommandResult.success([
    String? message,
  ]) : this(
          status: CommandResultStatus.success,
          message: message,
        );

  const CommandResult.cancelled([
    String? message,
  ]) : this(
          status: CommandResultStatus.cancelled,
          message: message,
        );

  const CommandResult.unavailable([
    String? message,
  ]) : this(
          status: CommandResultStatus.unavailable,
          message: message,
        );

  const CommandResult.failure([
    String? message,
  ]) : this(
          status: CommandResultStatus.failure,
          message: message,
        );

  bool get isSuccess =>
      status == CommandResultStatus.success;
}
```

---

# 5. `app_command.dart`

```dart
typedef CommandExecutor = Future<CommandResult> Function(
  CommandContext context,
);

class AppCommand {
  final CommandId id;
  final String title;
  final String category;
  final String? description;
  final CommandExecutor execute;

  final bool Function(CommandContext context)? enabled;
  final bool Function(CommandContext context)? visible;

  const AppCommand({
    required this.id,
    required this.title,
    required this.category,
    required this.execute,
    this.description,
    this.enabled,
    this.visible,
  });

  bool isEnabled(CommandContext context) {
    return enabled?.call(context) ?? true;
  }

  bool isVisible(CommandContext context) {
    return visible?.call(context) ?? true;
  }
}
```

Now commands have metadata.

That becomes extremely useful for the Command Palette.

---

# 6. Registry

```dart
class CommandRegistry {
  final Map<CommandId, AppCommand> _commands = {};

  void register(AppCommand command) {
    if (_commands.containsKey(command.id)) {
      throw StateError(
        'Command already registered: ${command.id}',
      );
    }

    _commands[command.id] = command;
  }

  AppCommand? get(CommandId id) {
    return _commands[id];
  }

  List<AppCommand> get all {
    return List.unmodifiable(
      _commands.values,
    );
  }
}
```

---

# 7. Command bus

The registry knows **what exists**.

The bus knows **how to execute it**.

```dart
class CommandBus {
  final CommandRegistry registry;

  CommandBus(this.registry);

  Future<CommandResult> execute(
    CommandId id, {
    CommandContext context =
        const CommandContext(),
  }) async {
    final command = registry.get(id);

    if (command == null) {
      return const CommandResult.failure(
        'Command not found.',
      );
    }

    if (!command.isVisible(context)) {
      return const CommandResult.unavailable(
        'Command is unavailable.',
      );
    }

    if (!command.isEnabled(context)) {
      return const CommandResult.unavailable(
        'Command is disabled.',
      );
    }

    try {
      return await command.execute(context);
    } catch (error) {
      return CommandResult.failure(
        error.toString(),
      );
    }
  }
}
```

---

# 8. Register workspace commands

Now connect the controller we built in the previous step.

```dart
void registerWorkspaceCommands({
  required CommandRegistry registry,
  required WorkspaceController workspace,
}) {
  registry.register(
    AppCommand(
      id: CommandId.toggleSidebar,
      title: 'Toggle Sidebar',
      category: 'View',
      description: 'Show or hide the workspace sidebar.',
      execute: (_) async {
        workspace.toggleSidebar();

        return const CommandResult.success();
      },
    ),
  );

  registry.register(
    AppCommand(
      id: CommandId.toggleAgent,
      title: 'Toggle Agent',
      category: 'View',
      description: 'Show or hide the Agent panel.',
      execute: (_) async {
        workspace.toggleAgent();

        return const CommandResult.success();
      },
    ),
  );

  registry.register(
    AppCommand(
      id: CommandId.toggleBottomPanel,
      title: 'Toggle Bottom Panel',
      category: 'View',
      description: 'Show or hide the bottom panel.',
      execute: (_) async {
        workspace.toggleBottomPanel();

        return const CommandResult.success();
      },
    ),
  );
}
```

---

# 9. Now the UI becomes extremely clean

Instead of:

```dart
onPressed: () {
  workspace.toggleSidebar();
}
```

we use:

```dart
onPressed: () {
  commandBus.execute(
    CommandId.toggleSidebar,
  );
}
```

That is a major architectural improvement.

---

# 10. Toolbar

```dart
IconButton(
  tooltip: 'Toggle Sidebar',
  onPressed: () {
    commandBus.execute(
      CommandId.toggleSidebar,
    );
  },
  icon: const Icon(
    Icons.view_sidebar_outlined,
  ),
)
```

---

# 11. Context menu

Exactly the same command:

```dart
PopupMenuItem(
  child: const Text('Toggle Sidebar'),
  onTap: () {
    commandBus.execute(
      CommandId.toggleSidebar,
    );
  },
)
```

---

# 12. Agent

This is where it gets interesting.

The Agent can also invoke the same system:

```dart
await commandBus.execute(
  CommandId.toggleAgent,
);
```

So natural language and UI controls eventually converge on the same application primitives.

---

# 13. Keyboard bindings

Now create:

```text
lib/
└── commands/
    └── keybindings/
        ├── key_binding.dart
        └── key_binding_registry.dart
```

```dart
class KeyBinding {
  final CommandId command;
  final LogicalKeyboardKey key;

  final bool control;
  final bool shift;
  final bool alt;
  final bool meta;

  const KeyBinding({
    required this.command,
    required this.key,
    this.control = false,
    this.shift = false,
    this.alt = false,
    this.meta = false,
  });
}
```

---

# 14. Context-aware bindings

Add context:

```dart
enum KeyContext {
  global,
  editor,
  agent,
  terminal,
  commandPalette,
  diff,
}
```

Then:

```dart
class KeyBinding {
  final CommandId command;
  final LogicalKeyboardKey key;
  final KeyContext context;

  final bool control;
  final bool shift;
  final bool alt;
  final bool meta;

  const KeyBinding({
    required this.command,
    required this.key,
    required this.context,
    this.control = false,
    this.shift = false,
    this.alt = false,
    this.meta = false,
  });
}
```

---

# 15. Default bindings

```dart
final defaultKeyBindings = [
  KeyBinding(
    command: CommandId.openCommandPalette,
    key: LogicalKeyboardKey.keyP,
    control: true,
    shift: true,
    context: KeyContext.global,
  ),

  KeyBinding(
    command: CommandId.toggleSidebar,
    key: LogicalKeyboardKey.keyB,
    control: true,
    shift: true,
    context: KeyContext.global,
  ),

  KeyBinding(
    command: CommandId.saveFile,
    key: LogicalKeyboardKey.keyS,
    control: true,
    context: KeyContext.editor,
  ),

  KeyBinding(
    command: CommandId.undo,
    key: LogicalKeyboardKey.keyZ,
    control: true,
    context: KeyContext.editor,
  ),

  KeyBinding(
    command: CommandId.redo,
    key: LogicalKeyboardKey.keyY,
    control: true,
    context: KeyContext.editor,
  ),
];
```

For macOS, the binding resolver should translate the platform modifier appropriately rather than hardcoding Ctrl behavior everywhere.

---

# 16. Command Palette

Now we can build the first major UX surface on top of the registry.

```text
┌──────────────────────────────────────────────┐
│ > Search commands...                         │
├──────────────────────────────────────────────┤
│ View                                         │
│   Toggle Sidebar                    Ctrl⇧B   │
│   Toggle Agent                              │
│   Toggle Bottom Panel                       │
│                                              │
│ Editor                                       │
│   Save File                          Ctrl+S  │
│   Go to Definition                          │
│                                              │
│ Agent                                        │
│   Explain Selection                         │
│   Review Changes                             │
└──────────────────────────────────────────────┘
```

The key is that **we don't manually construct this list**.

The registry supplies it.

---

# 17. Palette filtering

```dart
List<AppCommand> filterCommands(
  List<AppCommand> commands,
  String query,
) {
  final normalized =
      query.trim().toLowerCase();

  if (normalized.isEmpty) {
    return commands;
  }

  return commands.where((command) {
    final haystack = [
      command.title,
      command.category,
      command.description ?? '',
    ].join(' ').toLowerCase();

    return haystack.contains(normalized);
  }).toList();
}
```

Later we'll replace this with fuzzy matching.

---

# 18. Fuzzy matching

The UX should support:

```text
"tog sid"
```

and find:

```text
Toggle Sidebar
```

Likewise:

```text
"rev cha"
```

→

```text
Review Changes
```

This is much more useful than simple substring matching.

---

# 19. Command Palette widget

```dart
class CommandPalette extends StatefulWidget {
  const CommandPalette({
    super.key,
  });

  @override
  State<CommandPalette> createState() =>
      _CommandPaletteState();
}

class _CommandPaletteState
    extends State<CommandPalette> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final commandRegistry =
        CommandScope.of(context).registry;

    final commands = filterCommands(
      commandRegistry.all,
      controller.text,
    );

    return Material(
      child: SizedBox(
        width: 640,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search commands...',
                border: InputBorder.none,
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),

            const Divider(),

            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: commands.length,
                itemBuilder: (context, index) {
                  final command = commands[index];

                  return ListTile(
                    title: Text(command.title),
                    subtitle:
                        Text(command.category),
                    onTap: () {
                      CommandScope.of(context)
                          .bus
                          .execute(command.id);

                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

This is the initial implementation. We'll polish it later.

---

# 20. Command scope

We need to make the registry accessible without passing it through every widget.

```dart
class CommandScope extends InheritedWidget {
  final CommandRegistry registry;
  final CommandBus bus;

  const CommandScope({
    super.key,
    required this.registry,
    required this.bus,
    required super.child,
  });

  static CommandScope of(
    BuildContext context,
  ) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<
            CommandScope>();

    assert(scope != null);

    return scope!;
  }

  @override
  bool updateShouldNotify(
    CommandScope oldWidget,
  ) {
    return registry != oldWidget.registry ||
        bus != oldWidget.bus;
  }
}
```

---

# 21. Application composition

Now our root starts looking like this:

```dart
class AljabrApp extends StatelessWidget {
  final WorkspaceController workspace;
  final CommandRegistry commands;
  final CommandBus commandBus;

  const AljabrApp({
    super.key,
    required this.workspace,
    required this.commands,
    required this.commandBus,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: WorkspaceScope(
        controller: workspace,
        child: CommandScope(
          registry: commands,
          bus: commandBus,
          child: const AppShell(),
        ),
      ),
    );
  }
}
```

---

# 22. Initialization

Create one composition function.

```dart
class AppServices {
  late final WorkspaceController workspace;
  late final CommandRegistry commands;
  late final CommandBus commandBus;

  void initialize() {
    workspace = WorkspaceController();

    commands = CommandRegistry();

    commandBus = CommandBus(
      commands,
    );

    registerWorkspaceCommands(
      registry: commands,
      workspace: workspace,
    );
  }
}
```

Then:

```dart
void main() {
  final services = AppServices();

  services.initialize();

  runApp(
    AljabrApp(
      workspace: services.workspace,
      commands: services.commands,
      commandBus: services.commandBus,
    ),
  );
}
```

This is the beginning of a proper composition root.

---

# 23. Why this is a big checkpoint

Previously:

```text
button → method
keyboard → different method
menu → another method
Agent → another method
```

Now:

```text
                 CommandId
                    │
       ┌────────────┼────────────┐
       ↓            ↓            ↓
    Keyboard     Toolbar      Palette
       │            │            │
       └────────────┼────────────┘
                    ↓
               CommandBus
                    ↓
              AppCommand
                    ↓
               Controller
```

That dramatically reduces UX inconsistency.

---

# 24. Command state

The next refinement is making commands understand state.

For example:

```text
Undo
```

should not appear enabled when there is nothing to undo.

So:

```dart
AppCommand(
  id: CommandId.undo,
  title: 'Undo',
  category: 'History',
  enabled: (_) => undoManager.canUndo,
  execute: (_) async {
    await undoManager.undo();

    return const CommandResult.success();
  },
)
```

Then **every UI automatically gets the correct state**.

---

# 25. This will become especially powerful for Agent

Consider:

```text
Accept Change
```

It should only be enabled when:

```text
ChangeSet exists
AND
selected change is pending
```

So:

```dart
enabled: (_) {
  return changeSet.hasPendingSelection;
},
```

The toolbar, menu, command palette, and keyboard all automatically agree.

---

# 26. Command execution feedback

The bus should eventually publish results.

Conceptually:

```text
CommandBus
    │
    ├── execute
    │
    └── result
          ↓
    NotificationService
```

For example:

```text
Ctrl+S
 ↓
Save File
 ↓
success
 ↓
"Saved"
```

or:

```text
Run Tests
 ↓
failure
 ↓
"3 tests failed"
```

We will wire that into the notification system next.

---

# 27. One thing to avoid

Do **not** make `CommandBus` a giant class containing every operation.

Avoid:

```dart
class CommandBus {
  void save() {}
  void runTests() {}
  void openFile() {}
  void fixAgent() {}
  void ...
}
```

The bus should remain a dispatcher.

The actual functionality belongs in:

```text
WorkspaceController
EditorController
AgentController
TestController
GitController
UndoManager
```

The command layer orchestrates them.

---

# 28. Current architecture

We now have:

```text
                         APP
                          │
             ┌────────────┴────────────┐
             ↓                         ↓
        Workspace                 Command System
             │                         │
     WorkspaceController          Registry
             │                         │
             ↓                       Bus
         Layout                       │
             │                        ↓
       ┌─────┼─────┐              Commands
       ↓     ↓     ↓                 │
    Sidebar Editor Agent             │
                                     │
             ┌───────────────────────┘
             ↓
       Application Services
             │
       ┌─────┼──────┐
       ↓     ↓      ↓
     Editor Agent  Tests
```

This is a strong foundation.

---

# 29. Next checkpoint

The next implementation should be **Phase B.2: Focus Manager + Keyboard Resolver**.

We'll make keyboard interaction actually production-grade:

```text
Physical Key
     ↓
Keyboard Resolver
     ↓
Current Focus Context
     ↓
Key Binding
     ↓
CommandId
     ↓
CommandBus
```

Then we can make:

```text
Ctrl+P
Ctrl+Shift+B
Ctrl+Shift+A
Ctrl+S
Ctrl+Z
F2
Esc
Enter
↑ ↓ ← →
```

behave consistently throughout the workspace.

After that, the **Command Palette becomes a polished first-class interaction surface**, rather than just a dialog containing a list of commands.



# Phase B.2 — Focus Manager + Keyboard Resolver

Now we make the command system **actually feel like a desktop engineering tool**.

The principle is:

```text
Physical keyboard event
        ↓
Keyboard Resolver
        ↓
Current Focus Context
        ↓
Key Binding
        ↓
CommandId
        ↓
CommandBus
        ↓
Application action
```

The important improvement is that **keyboard behavior is no longer scattered across widgets**.

---

## 1. Add the keyboard layer

```text
lib/
└── keyboard/
    ├── key_context.dart
    ├── key_binding.dart
    ├── key_binding_registry.dart
    ├── keyboard_resolver.dart
    └── focus_manager.dart
```

---

# 2. Key contexts

We already introduced these conceptually. Now make them real.

```dart
enum KeyContext {
  global,
  editor,
  agent,
  terminal,
  commandPalette,
  diff,
  input,
}
```

The hierarchy should work like:

```text
global
  ↓
editor
  ↓
input
```

A more specific context takes priority.

---

# 3. Key binding

```dart
import 'package:flutter/services.dart';

class KeyBinding {
  final CommandId command;
  final LogicalKeyboardKey key;
  final KeyContext context;

  final bool control;
  final bool shift;
  final bool alt;
  final bool meta;

  const KeyBinding({
    required this.command,
    required this.key,
    required this.context,
    this.control = false,
    this.shift = false,
    this.alt = false,
    this.meta = false,
  });

  bool matches(
    KeyEvent event,
    TargetPlatform platform,
  ) {
    if (event.logicalKey != key) {
      return false;
    }

    final isMac =
        platform == TargetPlatform.macOS;

    final primaryModifier = isMac
        ? event is KeyDownEvent &&
            HardwareKeyboard.instance
                .isMetaPressed
        : event is KeyDownEvent &&
            HardwareKeyboard.instance
                .isControlPressed;

    final shiftPressed =
        HardwareKeyboard.instance.isShiftPressed;

    final altPressed =
        HardwareKeyboard.instance.isAltPressed;

    if (control && !primaryModifier) {
      return false;
    }

    if (!control && primaryModifier) {
      return false;
    }

    if (shift != shiftPressed) {
      return false;
    }

    if (alt != altPressed) {
      return false;
    }

    return true;
  }
}
```

There is one refinement I'd make immediately: don't rely on the `control` property name forever. Conceptually this is a **primary modifier**, because on macOS that means Command.

Later:

```dart
enum Modifier {
  primary,
  control,
  shift,
  alt,
  meta,
}
```

will be cleaner.

---

# 4. Better modifier model

Let's implement that now rather than creating technical debt.

```dart
enum KeyModifier {
  primary,
  control,
  shift,
  alt,
  meta,
}
```

Then:

```dart
class KeyBinding {
  final CommandId command;
  final LogicalKeyboardKey key;
  final KeyContext context;
  final Set<KeyModifier> modifiers;

  const KeyBinding({
    required this.command,
    required this.key,
    required this.context,
    this.modifiers = const {},
  });
}
```

Example:

```dart
KeyBinding(
  command: CommandId.openCommandPalette,
  key: LogicalKeyboardKey.keyP,
  context: KeyContext.global,
  modifiers: {
    KeyModifier.primary,
    KeyModifier.shift,
  },
)
```

Much cleaner.

---

# 5. Binding registry

```dart
class KeyBindingRegistry {
  final List<KeyBinding> _bindings = [];

  void register(KeyBinding binding) {
    _bindings.add(binding);
  }

  List<KeyBinding> get all =>
      List.unmodifiable(_bindings);

  List<KeyBinding> forContext(
    KeyContext context,
  ) {
    return _bindings
        .where(
          (binding) =>
              binding.context == context,
        )
        .toList();
  }
}
```

---

# 6. Focus Manager

Now we need a single source of truth for focus context.

```dart
import 'package:flutter/foundation.dart';

class AppFocusManager extends ChangeNotifier {
  KeyContext _context = KeyContext.global;

  KeyContext get context => _context;

  void setContext(KeyContext context) {
    if (_context == context) {
      return;
    }

    _context = context;
    notifyListeners();
  }

  void reset() {
    setContext(KeyContext.global);
  }
}
```

---

# 7. Focus should be semantic

Don't do this:

```dart
focusManager.setContext(
  KeyContext.editor,
);
```

from every random editor child.

Instead, create a scope.

```dart
class KeyContextScope extends StatefulWidget {
  final KeyContext context;
  final Widget child;

  const KeyContextScope({
    super.key,
    required this.context,
    required this.child,
  });

  @override
  State<KeyContextScope> createState() =>
      _KeyContextScopeState();
}
```

---

# 8. Scope implementation

```dart
class _KeyContextScopeState
    extends State<KeyContextScope> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      AppFocusManager.of(context)
          .setContext(widget.context);
    });
  }

  @override
  void dispose() {
    AppFocusManager.of(context).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
```

However, there is a subtle problem here.

Nested scopes can overwrite one another.

So for production we should not make focus context a simple global setter.

---

# 9. Use a focus stack

This is much safer.

```dart
class AppFocusManager extends ChangeNotifier {
  final List<KeyContext> _stack = [
    KeyContext.global,
  ];

  KeyContext get context => _stack.last;

  void push(KeyContext context) {
    _stack.add(context);
    notifyListeners();
  }

  void pop(KeyContext context) {
    final index = _stack.lastIndexOf(context);

    if (index <= 0) {
      return;
    }

    _stack.removeAt(index);
    notifyListeners();
  }

  void reset() {
    _stack
      ..clear()
      ..add(KeyContext.global);

    notifyListeners();
  }
}
```

Now:

```text
Global
  ↓
Editor
  ↓
Input
```

and when the input disappears:

```text
Input
  ↑ pop
Editor
```

The editor context remains.

---

# 10. Keyboard resolver

Now the important piece.

```dart
class KeyboardResolver {
  final KeyBindingRegistry bindings;
  final AppFocusManager focusManager;
  final CommandBus commandBus;

  KeyboardResolver({
    required this.bindings,
    required this.focusManager,
    required this.commandBus,
  });

  Future<bool> resolve(
    KeyEvent event,
  ) async {
    if (event is! KeyDownEvent) {
      return false;
    }

    final context =
        focusManager.context;

    final binding =
        _findBinding(event, context);

    if (binding == null) {
      return false;
    }

    final result =
        await commandBus.execute(
      binding.command,
    );

    return result.isSuccess;
  }

  KeyBinding? _findBinding(
    KeyEvent event,
    KeyContext context,
  ) {
    final candidates =
        bindings.forContext(context);

    for (final binding in candidates) {
      if (_matches(binding, event)) {
        return binding;
      }
    }

    if (context != KeyContext.global) {
      for (final binding
          in bindings.forContext(
        KeyContext.global,
      )) {
        if (_matches(binding, event)) {
          return binding;
        }
      }
    }

    return null;
  }

  bool _matches(
    KeyBinding binding,
    KeyEvent event,
  ) {
    if (binding.key != event.logicalKey) {
      return false;
    }

    final keyboard =
        HardwareKeyboard.instance;

    return _modifierMatches(
      binding.modifiers,
      keyboard,
    );
  }

  bool _modifierMatches(
    Set<KeyModifier> modifiers,
    HardwareKeyboard keyboard,
  ) {
    final primary =
        keyboard.isMetaPressed ||
        keyboard.isControlPressed;

    if (modifiers.contains(KeyModifier.primary) !=
        primary) {
      return false;
    }

    if (modifiers.contains(KeyModifier.shift) !=
        keyboard.isShiftPressed) {
      return false;
    }

    if (modifiers.contains(KeyModifier.alt) !=
        keyboard.isAltPressed) {
      return false;
    }

    return true;
  }
}
```

The primary modifier detection should eventually be platform-specific rather than treating Ctrl and Cmd identically, but this establishes the architecture.

---

# 11. Connect it to Flutter

At the application root:

```dart
class KeyboardHandler extends StatelessWidget {
  final KeyboardResolver resolver;
  final Widget child;

  const KeyboardHandler({
    super.key,
    required this.resolver,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: resolver.resolve,
      child: child,
    );
  }
}
```

But there's another improvement.

We don't want to create a new `FocusNode` every rebuild.

---

# 12. Stateful keyboard host

```dart
class KeyboardHost extends StatefulWidget {
  final KeyboardResolver resolver;
  final Widget child;

  const KeyboardHost({
    super.key,
    required this.resolver,
    required this.child,
  });

  @override
  State<KeyboardHost> createState() =>
      _KeyboardHostState();
}

class _KeyboardHostState
    extends State<KeyboardHost> {

  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode(
      debugLabel: 'AljabrKeyboardHost',
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: widget.resolver.resolve,
      child: widget.child,
    );
  }
}
```

---

# 13. Important: don't steal text input

This is critical.

If the user is typing:

```text
hello world
```

we should **not** intercept those keys globally.

For example:

```text
Agent input
Editor
Search box
Command Palette
```

must be allowed to consume normal text input.

Therefore the resolver needs an input rule.

```dart
bool shouldBypassGlobalShortcuts(
  BuildContext context,
) {
  final focused =
      FocusManager.instance.primaryFocus;

  final node = focused?.context;

  if (node == null) {
    return false;
  }

  return node.findAncestorWidgetOfExactType<
      EditableText>() != null;
}
```

A more robust implementation can use focus metadata, but the principle is:

> **Text entry gets priority over global shortcuts.**

---

# 14. Shortcut priority

The resolution order should be:

```text
1. Modal
2. Command Palette
3. Text input
4. Diff/editor-specific context
5. Workspace context
6. Global commands
```

This is much more predictable.

---

# 15. Escape deserves special treatment

`Esc` is not just another command.

It should unwind the current interaction:

```text
Agent input
   ↓ Esc
clear selection / close completion

Command Palette
   ↓ Esc
close palette

Dialog
   ↓ Esc
close dialog

Temporary mode
   ↓ Esc
exit mode

Workspace
   ↓ Esc
clear focus
```

So:

```dart
CommandId.escape
```

can exist, but its dispatcher should understand interaction priority.

---

# 16. Default bindings

Now define the initial set.

```dart
void registerDefaultKeyBindings(
  KeyBindingRegistry registry,
) {
  registry.register(
    KeyBinding(
      command: CommandId.openCommandPalette,
      key: LogicalKeyboardKey.keyP,
      context: KeyContext.global,
      modifiers: {
        KeyModifier.primary,
        KeyModifier.shift,
      },
    ),
  );

  registry.register(
    KeyBinding(
      command: CommandId.toggleSidebar,
      key: LogicalKeyboardKey.keyB,
      context: KeyContext.global,
      modifiers: {
        KeyModifier.primary,
        KeyModifier.shift,
      },
    ),
  );

  registry.register(
    KeyBinding(
      command: CommandId.saveFile,
      key: LogicalKeyboardKey.keyS,
      context: KeyContext.editor,
      modifiers: {
        KeyModifier.primary,
      },
    ),
  );

  registry.register(
    KeyBinding(
      command: CommandId.undo,
      key: LogicalKeyboardKey.keyZ,
      context: KeyContext.editor,
      modifiers: {
        KeyModifier.primary,
      },
    ),
  );

  registry.register(
    KeyBinding(
      command: CommandId.redo,
      key: LogicalKeyboardKey.keyY,
      context: KeyContext.editor,
      modifiers: {
        KeyModifier.primary,
      },
    ),
  );
}
```

---

# 17. Add navigation commands

We should also establish the familiar developer workflow:

```dart
KeyBinding(
  command: CommandId.goToFile,
  key: LogicalKeyboardKey.keyP,
  context: KeyContext.editor,
  modifiers: {
    KeyModifier.primary,
  },
),
```

And:

```dart
KeyBinding(
  command: CommandId.goToSymbol,
  key: LogicalKeyboardKey.keyO,
  context: KeyContext.editor,
  modifiers: {
    KeyModifier.primary,
    KeyModifier.shift,
  },
),
```

The exact shortcuts can be configurable later.

---

# 18. Focus-aware Agent shortcuts

For example:

```dart
KeyBinding(
  command: CommandId.explainSelection,
  key: LogicalKeyboardKey.keyE,
  context: KeyContext.editor,
  modifiers: {
    KeyModifier.primary,
    KeyModifier.shift,
  },
),
```

Then:

```text
select code
    ↓
Ctrl+Shift+E
    ↓
Explain Selection
    ↓
Agent
```

That is much faster than:

```text
open Agent
type "explain this"
send
```

---

# 19. Focus indicators

Now we improve the GUI itself.

When a panel owns keyboard focus, it should have a subtle indicator.

```dart
class FocusSurface extends StatelessWidget {
  final bool focused;
  final Widget child;

  const FocusSurface({
    super.key,
    required this.focused,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        AppTheme.colorsOf(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: focused
              ? colors.accent
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
```

Don't use a bright glowing outline.

A one-pixel semantic accent is enough.

---

# 20. Focus ring animation

```dart
AnimatedContainer(
  duration: AppMotion.fast,
  curve: AppCurves.standard,
  decoration: BoxDecoration(
    border: Border.all(
      color: focused
          ? colors.accent
          : Colors.transparent,
    ),
  ),
  child: child,
)
```

This makes focus transitions feel intentional.

---

# 21. Focusable panel

Now create:

```dart
class FocusablePanel extends StatefulWidget {
  final KeyContext contextType;
  final Widget child;

  const FocusablePanel({
    super.key,
    required this.contextType,
    required this.child,
  });

  @override
  State<FocusablePanel> createState() =>
      _FocusablePanelState();
}
```

The panel can push its context when it gains focus.

---

# 22. Don't overuse focus borders

Only show focus state when keyboard interaction needs it.

For mouse-heavy areas:

```text
hover → subtle surface change
focus → accent outline
selected → active surface
```

These states should remain distinct.

---

# 23. Keyboard navigation in lists

The next UX rule:

```text
↑ ↓
```

should move selection without requiring a mouse.

Example:

```dart
int _selectedIndex = 0;

void moveSelection(int delta) {
  setState(() {
    _selectedIndex =
        (_selectedIndex + delta)
            .clamp(0, items.length - 1);
  });
}
```

Then:

```text
ArrowDown
    ↓
selection + 1

ArrowUp
    ↓
selection - 1

Enter
    ↓
activate
```

This becomes especially important for the Command Palette.

---

# 24. Command Palette keyboard behavior

The final interaction should feel like:

```text
Ctrl+Shift+P
        ↓
Palette opens
        ↓
focus search
        ↓
type
        ↓
↑ ↓
        ↓
Enter
        ↓
execute
        ↓
palette closes
        ↓
previous focus restored
```

That last part is important.

---

# 25. Focus restoration

Before opening a transient surface:

```dart
final previousFocus =
    FocusManager.instance.primaryFocus;
```

After closing:

```dart
previousFocus?.requestFocus();
```

Eventually we'll encapsulate this in:

```text
FocusRestorationManager
```

so dialogs, palette, search, and Agent overlays all behave consistently.

---

# 26. Current architecture

We now have:

```text
                         USER INPUT
                             │
               ┌─────────────┼─────────────┐
               ↓             ↓             ↓
             Mouse       Keyboard        Agent
               │             │             │
               │        Focus Context      │
               │             │             │
               └─────────────┼─────────────┘
                             ↓
                       CommandResolver
                             ↓
                       CommandRegistry
                             ↓
                         CommandBus
                             ↓
                    Application Services
```

That is the interaction architecture we want.

---

# 27. Checkpoint

At this point we've established:

```text
✅ Semantic keyboard contexts
✅ Focus manager
✅ Focus stack
✅ Key binding registry
✅ Keyboard resolver
✅ Platform-aware modifier architecture
✅ Global vs contextual shortcuts
✅ Text-input protection
✅ Focus visual states
✅ Keyboard list navigation
✅ Focus restoration strategy
✅ Command execution through keyboard
```

The next step should now be **Command Palette 2.0**.

Not merely a `TextField + ListView`, but a polished developer command surface with:

```text
fuzzy search
category grouping
recent commands
keyboard navigation
shortcut display
empty state
loading state
focus restoration
command availability
command preview
```

That will be our first place where the architecture and the UX polish come together visibly.


# Phase B.3 — Command Palette 2.0

Now we turn the command palette into a **core navigation surface**, not just a searchable menu.

Target UX:

```text
        Ctrl + Shift + P
                ↓
┌──────────────────────────────────────────────┐
│ ⌕  Search commands...                    Esc │
├──────────────────────────────────────────────┤
│ RECENT                                       │
│   Toggle Sidebar                    Ctrl⇧B   │
│   Save File                         Ctrl+S   │
│                                              │
│ VIEW                                         │
│ › Toggle Agent                               │
│   Toggle Bottom Panel                        │
│                                              │
│ EDITOR                                       │
│   Go to Definition                           │
│   Find in Files                      Ctrl⇧F │
├──────────────────────────────────────────────┤
│ ↑↓ Navigate     ↵ Run     Esc Close          │
└──────────────────────────────────────────────┘
```

The implementation should be built around the command architecture we already created.

---

## 1. Add palette state

Create:

```text
lib/
└── commands/
    └── palette/
        ├── command_palette.dart
        ├── command_palette_controller.dart
        ├── command_palette_item.dart
        └── command_palette_search.dart
```

Controller:

```dart
class CommandPaletteController
    extends ChangeNotifier {

  String _query = '';
  int _selectedIndex = 0;

  String get query => _query;
  int get selectedIndex => _selectedIndex;

  void setQuery(String value) {
    _query = value;
    _selectedIndex = 0;
    notifyListeners();
  }

  void moveSelection(
    int delta,
    int itemCount,
  ) {
    if (itemCount == 0) {
      _selectedIndex = 0;
      return;
    }

    _selectedIndex =
        (_selectedIndex + delta) % itemCount;

    if (_selectedIndex < 0) {
      _selectedIndex += itemCount;
    }

    notifyListeners();
  }

  void reset() {
    _query = '';
    _selectedIndex = 0;
    notifyListeners();
  }
}
```

---

# 2. Don't put filtering inside the widget

The widget should not contain search logic.

Create:

```dart
class CommandPaletteSearch {
  List<AppCommand> search({
    required List<AppCommand> commands,
    required String query,
    required CommandContext context,
  }) {
    final visible = commands
        .where(
          (command) =>
              command.isVisible(context) &&
              command.isEnabled(context),
        )
        .toList();

    if (query.trim().isEmpty) {
      return visible;
    }

    return visible
        .where(
          (command) =>
              _matches(command, query),
        )
        .toList();
  }

  bool _matches(
    AppCommand command,
    String query,
  ) {
    final q = query.toLowerCase();

    final text = [
      command.title,
      command.category,
      command.description ?? '',
    ].join(' ').toLowerCase();

    return text.contains(q);
  }
}
```

This is intentionally simple first.

We will upgrade the matching algorithm next.

---

# 3. Add fuzzy scoring

A command palette should understand:

```text
tog sid
```

as:

```text
Toggle Sidebar
```

rather than requiring:

```text
toggle sidebar
```

Use a small scoring function.

```dart
int fuzzyScore(
  String query,
  String target,
) {
  query = query.toLowerCase();
  target = target.toLowerCase();

  if (query.isEmpty) {
    return 0;
  }

  if (target == query) {
    return 1000;
  }

  if (target.startsWith(query)) {
    return 800;
  }

  if (target.contains(query)) {
    return 600;
  }

  int score = 0;
  int targetIndex = 0;

  for (final character in query.characters) {
    final index =
        target.indexOf(character, targetIndex);

    if (index == -1) {
      return -1;
    }

    score += 10;

    if (index == targetIndex) {
      score += 5;
    }

    targetIndex = index + 1;
  }

  return score;
}
```

Then:

```dart
List<AppCommand> search(
  List<AppCommand> commands,
  String query,
  CommandContext context,
) {
  final results = <({AppCommand command, int score})>[];

  for (final command in commands) {
    if (!command.isVisible(context) ||
        !command.isEnabled(context)) {
      continue;
    }

    final score = fuzzyScore(
      query,
      command.title,
    );

    if (score >= 0) {
      results.add(
        (
          command: command,
          score: score,
        ),
      );
    }
  }

  results.sort(
    (a, b) => b.score.compareTo(a.score),
  );

  return results
      .map((item) => item.command)
      .toList();
}
```

This immediately makes the palette feel much better.

---

# 4. Search multiple fields

Don't search only titles.

Score:

```text
title
category
description
command ID
```

For example:

```text
"def"
```

could discover:

```text
Go to Definition
```

even if the title doesn't begin with `def`.

---

# 5. Recent commands

Now add memory.

```dart
class RecentCommandStore {
  final List<CommandId> _recent = [];

  List<CommandId> get commands =>
      List.unmodifiable(_recent);

  void record(CommandId id) {
    _recent.remove(id);
    _recent.insert(0, id);

    if (_recent.length > 8) {
      _recent.removeLast();
    }
  }

  void clear() {
    _recent.clear();
  }
}
```

The UX benefit is significant.

If the user repeatedly does:

```text
Review Changes
```

they shouldn't have to search for it every time.

---

# 6. Record only successful commands

Do this in the `CommandBus`.

```dart
final result = await command.execute(context);

if (result.isSuccess) {
  recentCommands.record(id);
}

return result;
```

Do not record:

```text
cancelled
unavailable
failed
```

commands as recent actions.

---

# 7. Recent section

When the search query is empty:

```dart
List<AppCommand> buildResults(...) {
  if (query.isEmpty) {
    return [
      ...recentCommands,
      ...normalCommands,
    ];
  }

  return search(...);
}
```

But don't duplicate recent commands.

Use:

```dart
final seen = <CommandId>{};

final results = <AppCommand>[];

for (final command in recent) {
  if (seen.add(command.id)) {
    results.add(command);
  }
}

for (final command in normal) {
  if (seen.add(command.id)) {
    results.add(command);
  }
}
```

---

# 8. Group by category

Instead of:

```text
Toggle Sidebar
Toggle Agent
Save File
Go to Definition
Review Changes
Run Tests
```

show:

```text
VIEW
  Toggle Sidebar
  Toggle Agent

EDITOR
  Save File
  Go to Definition

AGENT
  Review Changes

TEST
  Run Tests
```

Create:

```dart
Map<String, List<AppCommand>> groupCommands(
  List<AppCommand> commands,
) {
  final groups =
      <String, List<AppCommand>>{};

  for (final command in commands) {
    groups
        .putIfAbsent(
          command.category,
          () => [],
        )
        .add(command);
  }

  return groups;
}
```

---

# 9. Palette item

```dart
class CommandPaletteItem extends StatelessWidget {
  final AppCommand command;
  final bool selected;
  final VoidCallback onTap;

  const CommandPaletteItem({
    super.key,
    required this.command,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        AppTheme.colorsOf(context);

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        height: 44,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colors.surfaceSelected
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                command.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            Text(
              command.category,
              style: TextStyle(
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

# 10. Show keyboard shortcuts

This is a major polish improvement.

The user should see:

```text
Save File                     Ctrl+S
Toggle Sidebar               Ctrl+Shift+B
```

Don't hardcode that string inside the item.

Create:

```dart
class KeyBindingRegistry {
  ...

  KeyBinding? primaryBinding(
    CommandId command,
  ) {
    for (final binding in _bindings) {
      if (binding.command == command) {
        return binding;
      }
    }

    return null;
  }
}
```

Then render:

```dart
ShortcutLabel(
  binding: bindings.primaryBinding(
    command.id,
  ),
)
```

---

# 11. Shortcut label

```dart
class ShortcutLabel extends StatelessWidget {
  final KeyBinding? binding;

  const ShortcutLabel({
    super.key,
    required this.binding,
  });

  @override
  Widget build(BuildContext context) {
    if (binding == null) {
      return const SizedBox.shrink();
    }

    return Text(
      formatShortcut(binding!),
    );
  }
}
```

Formatting:

```dart
String formatShortcut(
  KeyBinding binding,
) {
  final parts = <String>[];

  if (binding.modifiers
      .contains(KeyModifier.primary)) {
    parts.add('⌘');
  }

  if (binding.modifiers
      .contains(KeyModifier.shift)) {
    parts.add('⇧');
  }

  if (binding.modifiers
      .contains(KeyModifier.alt)) {
    parts.add('⌥');
  }

  parts.add(
    binding.key.keyLabel,
  );

  return parts.join();
}
```

The formatter should be platform-aware.

On Windows/Linux:

```text
Ctrl + Shift + P
```

On macOS:

```text
⌘ ⇧ P
```

---

# 12. Full palette layout

Now assemble it.

```dart
class CommandPalette extends StatefulWidget {
  const CommandPalette({
    super.key,
  });

  @override
  State<CommandPalette> createState() =>
      _CommandPaletteState();
}
```

State:

```dart
class _CommandPaletteState
    extends State<CommandPalette> {

  late final TextEditingController
      _searchController;

  late final FocusNode _searchFocus;

  late final CommandPaletteController
      _controller;

  @override
  void initState() {
    super.initState();

    _searchController =
        TextEditingController();

    _searchFocus = FocusNode();

    _controller =
        CommandPaletteController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _controller.dispose();
    super.dispose();
  }
}
```

---

# 13. Keyboard handling

The palette should own:

```text
Arrow Up
Arrow Down
Enter
Escape
```

```dart
KeyEventResult handleKey(
  KeyEvent event,
) {
  if (event is! KeyDownEvent) {
    return KeyEventResult.ignored;
  }

  if (event.logicalKey ==
      LogicalKeyboardKey.arrowDown) {
    _controller.moveSelection(
      1,
      results.length,
    );

    return KeyEventResult.handled;
  }

  if (event.logicalKey ==
      LogicalKeyboardKey.arrowUp) {
    _controller.moveSelection(
      -1,
      results.length,
    );

    return KeyEventResult.handled;
  }

  if (event.logicalKey ==
      LogicalKeyboardKey.enter) {
    executeSelected();

    return KeyEventResult.handled;
  }

  if (event.logicalKey ==
      LogicalKeyboardKey.escape) {
    close();

    return KeyEventResult.handled;
  }

  return KeyEventResult.ignored;
}
```

---

# 14. Execute selected command

```dart
Future<void> executeSelected() async {
  if (results.isEmpty) {
    return;
  }

  final command =
      results[_controller.selectedIndex];

  final result =
      await CommandScope.of(context)
          .bus
          .execute(command.id);

  if (!mounted) {
    return;
  }

  if (result.isSuccess) {
    close();
  }
}
```

---

# 15. Empty state

Never show a blank rectangle.

If nothing matches:

```text
┌──────────────────────────────────────────────┐
│ ⌕  xyz                                       │
├──────────────────────────────────────────────┤
│                                              │
│             No commands found               │
│                                              │
│       Try another search term               │
│                                              │
└──────────────────────────────────────────────┘
```

Implementation:

```dart
if (results.isEmpty)
  const EmptyCommandState()
```

---

# 16. Loading state

Some commands may eventually come from plugins or dynamic providers.

Therefore support:

```dart
CommandPaletteState.loading
CommandPaletteState.ready
CommandPaletteState.empty
CommandPaletteState.error
```

Don't assume all commands are always synchronously available.

---

# 17. Preview panel

This is a later-stage enhancement, but worth designing for.

When a command is selected:

```text
┌──────────────────────────────┬─────────────────┐
│ Commands                     │                 │
│                              │ Toggle Sidebar  │
│ › Toggle Sidebar             │                 │
│   Toggle Agent               │ Show/hide the   │
│   Save File                  │ workspace       │
│                              │ sidebar.        │
└──────────────────────────────┴─────────────────┘
```

Don't implement every preview immediately.

But structure the item model so it can support:

```dart
String? description;
Widget? preview;
```

---

# 18. Palette animation

Opening:

```text
opacity: 0 → 1
scale: 0.98 → 1
```

Closing:

```text
opacity: 1 → 0
scale: 1 → 0.98
```

Keep it around:

```dart
const Duration(milliseconds: 120)
```

Do not use a large zoom animation.

Developer tools benefit from speed.

---

# 19. Backdrop

Use a very subtle backdrop:

```dart
ModalBarrier(
  color: Colors.black.withValues(
    alpha: 0.25,
  ),
)
```

The workspace should remain visually present.

The palette should feel like a layer **over** the workspace, not a new page.

---

# 20. Width and positioning

Don't hardcode:

```dart
width: 700
```

for every screen.

Use:

```dart
final width = min(
  MediaQuery.sizeOf(context).width - 48,
  720,
);
```

Then:

```dart
ConstrainedBox(
  constraints: const BoxConstraints(
    maxWidth: 720,
    minWidth: 420,
  ),
)
```

On a smaller window it naturally contracts.

---

# 21. Add an invocation command

Now register:

```dart
registry.register(
  AppCommand(
    id: CommandId.openCommandPalette,
    title: 'Command Palette',
    category: 'Navigation',
    description:
        'Search and execute commands.',
    execute: (_) async {
      commandPaletteService.open();

      return const CommandResult.success();
    },
  ),
);
```

This means the palette opens through its **own command**.

So:

```text
Ctrl+Shift+P
```

isn't special-cased.

It simply invokes:

```text
CommandId.openCommandPalette
```

---

# 22. Command Palette service

Create:

```dart
class CommandPaletteService {
  final GlobalKey<NavigatorState> navigatorKey;

  CommandPaletteService(
    this.navigatorKey,
  );

  void open() {
    showDialog(
      context:
          navigatorKey.currentContext!,
      barrierDismissible: true,
      builder: (_) {
        return const CommandPalette();
      },
    );
  }
}
```

Later, we can replace the dialog with an overlay service.

For now this is clean enough.

---

# 23. Better: restore focus

Before opening:

```dart
class CommandPaletteService {
  FocusNode? _previousFocus;

  void open() {
    _previousFocus =
        FocusManager.instance.primaryFocus;

    ...
  }
}
```

After closing:

```dart
void restoreFocus() {
  _previousFocus?.requestFocus();
  _previousFocus = null;
}
```

This gives us:

```text
Editor
 ↓
Ctrl+Shift+P
 ↓
Palette
 ↓
Esc
 ↓
Editor focus restored
```

That tiny detail makes the application feel substantially more polished.

---

# 24. Command availability

The palette must not show commands that cannot currently execute.

For example:

```dart
AppCommand(
  id: CommandId.undo,
  title: 'Undo',
  category: 'History',
  enabled: (_) => undoManager.canUndo,
  execute: (_) async {
    await undoManager.undo();

    return const CommandResult.success();
  },
)
```

The palette can optionally hide unavailable commands:

```text
showDisabledCommands = false
```

or show them dimmed:

```text
Undo
Redo
```

with disabled styling.

I recommend **showing them dimmed** for common commands because it teaches users what exists.

---

# 25. Disabled visual state

```dart
AnimatedOpacity(
  duration: AppMotion.fast,
  opacity: enabled ? 1 : 0.45,
  child: child,
)
```

Don't make disabled commands completely invisible.

---

# 26. Command ranking

Final ranking should become:

```text
1. Exact title match
2. Prefix title match
3. Fuzzy title match
4. Category match
5. Description match
6. Recent usage
```

For example, searching:

```text
"test"
```

should prioritize:

```text
Run Tests
Run Current Test
```

over a command whose description merely contains "test".

---

# 27. Add usage weighting

We can improve the score:

```dart
int finalScore({
  required int fuzzy,
  required int recentIndex,
}) {
  var score = fuzzy;

  if (recentIndex >= 0) {
    score +=
        100 - (recentIndex * 10);
  }

  return score;
}
```

This makes frequently used commands naturally rise toward the top.

---

# 28. The palette is now a UX hub

We have transformed:

```text
Command Palette
= searchable list
```

into:

```text
Command Palette
├── command registry
├── fuzzy search
├── context awareness
├── availability
├── recent usage
├── keyboard navigation
├── shortcut discovery
├── focus restoration
├── responsive sizing
├── animation
└── command execution
```

That is the right foundation.

---

# 29. Current interaction architecture

```text
                         USER
                          │
        ┌─────────────────┼─────────────────┐
        ↓                 ↓                 ↓
      Mouse            Keyboard           Agent
        │                 │                 │
        │            Focus Manager          │
        │                 │                 │
        └─────────────────┼─────────────────┘
                          ↓
                   Command Resolver
                          ↓
                  ┌───────┴───────┐
                  ↓               ↓
             Key Binding     Command Palette
                  │               │
                  └───────┬───────┘
                          ↓
                    Command Bus
                          ↓
                    App Commands
                          ↓
                Application Services
```

---

# 30. Checkpoint B complete

At this point the UX foundation has:

```text
✅ Central workspace state
✅ Resizable panels
✅ Persistent layout
✅ Workspace presets
✅ Command registry
✅ Command bus
✅ Command metadata
✅ Context-aware commands
✅ Keyboard contexts
✅ Focus manager
✅ Key binding registry
✅ Keyboard resolver
✅ Command Palette
✅ Fuzzy search
✅ Recent commands
✅ Shortcut display
✅ Keyboard navigation
✅ Focus restoration
✅ Command availability
```

## Next: Phase C — Editor Experience

Now we should move from **application chrome** into the actual working surface.

The next implementation should establish:

```text
Editor Workspace
├── Tab system
├── Dirty state
├── Active editor
├── Split editor
├── Breadcrumbs
├── File navigation
├── Search
├── Selection state
├── Editor actions
├── Inline diagnostics
└── Agent ↔ editor integration
```

The most important first piece is **the editor/tab state model**, because everything else—save, close, dirty indicators, split views, Agent context, breadcrumbs—depends on it.



# Phase C.1 — Editor & Tab State

Now we move into the actual working surface.

The goal is to make the editor behave like a serious IDE rather than a collection of tabs and text fields.

The architecture should become:

```text
                    EditorController
                           │
                    EditorWorkspace
                           │
              ┌────────────┼────────────┐
              ↓            ↓            ↓
           Tab Bar       Editor       Breadcrumb
              │            │
              ↓            ↓
         EditorState    DocumentState
                           │
                  ┌────────┼────────┐
                  ↓        ↓        ↓
                Dirty    Selection Diagnostics
```

The key rule:

> **Tabs describe open documents. Documents own editing state.**

---

## 1. New editor structure

```text
lib/
└── editor/
    ├── model/
    │   ├── editor_document.dart
    │   ├── editor_tab.dart
    │   ├── editor_group.dart
    │   └── editor_selection.dart
    │
    ├── controller/
    │   ├── editor_controller.dart
    │   └── editor_group_controller.dart
    │
    ├── widgets/
    │   ├── editor_workspace.dart
    │   ├── editor_tab_bar.dart
    │   ├── editor_tab.dart
    │   ├── editor_surface.dart
    │   ├── editor_breadcrumbs.dart
    │   └── editor_empty_state.dart
    │
    └── services/
        ├── document_service.dart
        └── editor_persistence.dart
```

---

# 2. Document model

Start with the document itself.

```dart
class EditorDocument {
  final String id;
  final String path;

  String content;

  final String savedContent;

  const EditorDocument({
    required this.id,
    required this.path,
    required this.content,
    required this.savedContent,
  });

  bool get isDirty =>
      content != savedContent;

  EditorDocument copyWith({
    String? content,
    String? savedContent,
  }) {
    return EditorDocument(
      id: id,
      path: path,
      content: content ?? this.content,
      savedContent:
          savedContent ?? this.savedContent,
    );
  }
}
```

One correction here for the actual implementation: `savedContent` should not remain immutable if `save()` updates it, so make the model fully immutable instead:

```dart
class EditorDocument {
  final String id;
  final String path;
  final String content;
  final String savedContent;

  const EditorDocument({
    required this.id,
    required this.path,
    required this.content,
    required this.savedContent,
  });

  bool get isDirty =>
      content != savedContent;

  EditorDocument copyWith({
    String? content,
    String? savedContent,
  }) {
    return EditorDocument(
      id: id,
      path: path,
      content: content ?? this.content,
      savedContent:
          savedContent ?? this.savedContent,
    );
  }
}
```

That gives us predictable state transitions.

---

# 3. Tab model

A tab should not duplicate the document.

```dart
class EditorTab {
  final String documentId;

  const EditorTab({
    required this.documentId,
  });
}
```

That's intentionally tiny.

The tab answers:

> Which document is this tab showing?

The document answers:

> What is the actual content/state?

---

# 4. Why separate them?

This becomes important when we eventually have:

```text
document A
   │
   ├── Tab in group 1
   │
   └── Tab in group 2
```

Both views can reference the same document state.

You don't want:

```text
Tab A content
Tab B content
```

to become two competing copies.

---

# 5. Editor group

Now support split editors from the beginning.

```dart
class EditorGroup {
  final String id;
  final List<EditorTab> tabs;
  final String? activeDocumentId;

  const EditorGroup({
    required this.id,
    this.tabs = const [],
    this.activeDocumentId,
  });

  EditorGroup copyWith({
    List<EditorTab>? tabs,
    String? activeDocumentId,
  }) {
    return EditorGroup(
      id: id,
      tabs: tabs ?? this.tabs,
      activeDocumentId:
          activeDocumentId ?? this.activeDocumentId,
    );
  }
}
```

Eventually:

```text
┌──────────────────────┬──────────────────────┐
│ group A              │ group B              │
│                      │                      │
│ main.dart            │ test.dart            │
│                      │                      │
│                      │                      │
└──────────────────────┴──────────────────────┘
```

We don't need to implement splitting yet.

But the state model should not prevent it.

---

# 6. Editor controller

Now the main controller.

```dart
class EditorController extends ChangeNotifier {
  final Map<String, EditorDocument> _documents = {};

  final List<EditorGroup> _groups = [];

  String _activeGroupId;

  EditorController({
    String? initialGroupId,
  }) : _activeGroupId =
      initialGroupId ?? 'group-1';

  List<EditorGroup> get groups =>
      List.unmodifiable(_groups);

  EditorGroup? get activeGroup {
    for (final group in _groups) {
      if (group.id == _activeGroupId) {
        return group;
      }
    }

    return null;
  }

  EditorDocument? document(
    String id,
  ) {
    return _documents[id];
  }
}
```

---

# 7. Initialize a default group

```dart
void initialize() {
  if (_groups.isNotEmpty) {
    return;
  }

  _groups.add(
    const EditorGroup(
      id: 'group-1',
    ),
  );

  notifyListeners();
}
```

---

# 8. Open a document

This is the first important operation.

```dart
void openDocument(
  EditorDocument document,
) {
  _documents[document.id] =
      document;

  final group = activeGroup;

  if (group == null) {
    return;
  }

  final alreadyOpen =
      group.tabs.any(
    (tab) =>
        tab.documentId == document.id,
  );

  if (alreadyOpen) {
    activateDocument(document.id);
    return;
  }

  final updatedTabs = [
    ...group.tabs,
    EditorTab(
      documentId: document.id,
    ),
  ];

  _replaceGroup(
    group.copyWith(
      tabs: updatedTabs,
      activeDocumentId: document.id,
    ),
  );

  notifyListeners();
}
```

---

# 9. Activate a document

```dart
void activateDocument(
  String documentId,
) {
  final group = activeGroup;

  if (group == null) {
    return;
  }

  final exists = group.tabs.any(
    (tab) =>
        tab.documentId == documentId,
  );

  if (!exists) {
    return;
  }

  _replaceGroup(
    group.copyWith(
      activeDocumentId: documentId,
    ),
  );

  notifyListeners();
}
```

---

# 10. Private group replacement

```dart
void _replaceGroup(
  EditorGroup updated,
) {
  final index = _groups.indexWhere(
    (group) => group.id == updated.id,
  );

  if (index == -1) {
    return;
  }

  _groups[index] = updated;
}
```

---

# 11. Dirty state

When the editor changes:

```dart
void updateDocument(
  String documentId,
  String content,
) {
  final document =
      _documents[documentId];

  if (document == null) {
    return;
  }

  _documents[documentId] =
      document.copyWith(
    content: content,
  );

  notifyListeners();
}
```

Now:

```dart
final document =
    controller.document(id);

if (document?.isDirty == true) {
  // show dirty indicator
}
```

---

# 12. The tab should visually communicate dirty state

Instead of:

```text
main.dart
```

show:

```text
● main.dart
```

or:

```text
main.dart •
```

The exact visual treatment should be subtle.

Example:

```dart
Widget buildDirtyIndicator(
  BuildContext context,
  bool dirty,
) {
  if (!dirty) {
    return const SizedBox.shrink();
  }

  return Container(
    width: 6,
    height: 6,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
    ),
  );
}
```

---

# 13. Don't use red for dirty state

Dirty doesn't mean error.

Use:

```text
dirty       → neutral accent
warning     → warning color
error       → error color
success     → success color
```

This keeps the semantic system clean.

---

# 14. Save document

```dart
Future<CommandResult> saveDocument(
  String documentId,
) async {
  final document =
      _documents[documentId];

  if (document == null) {
    return const CommandResult.unavailable(
      'Document is not open.',
    );
  }

  if (!document.isDirty) {
    return const CommandResult.success(
      'Already saved.',
    );
  }

  await documentService.write(
    document.path,
    document.content,
  );

  _documents[documentId] =
      document.copyWith(
    savedContent: document.content,
  );

  notifyListeners();

  return const CommandResult.success(
    'Saved.',
  );
}
```

---

# 15. Connect Save to the command system

Now:

```dart
registry.register(
  AppCommand(
    id: CommandId.saveFile,
    title: 'Save File',
    category: 'Editor',
    enabled: (context) =>
        context.filePath != null,
    execute: (context) async {
      final path = context.filePath;

      if (path == null) {
        return const CommandResult.unavailable();
      }

      return editorController
          .saveDocument(path);
    },
  ),
);
```

But this reveals something important.

We don't want to identify documents by path everywhere.

Use the document ID as the internal identity.

---

# 16. Improve `CommandContext`

Add:

```dart
class CommandContext {
  final String? documentId;
  final String? filePath;
  final String? selectedText;
  final String? symbol;

  final bool editorHasFocus;
  final bool agentHasFocus;

  const CommandContext({
    this.documentId,
    this.filePath,
    this.selectedText,
    this.symbol,
    this.editorHasFocus = false,
    this.agentHasFocus = false,
  });
}
```

Then:

```dart
execute: (context) async {
  final documentId =
      context.documentId;

  if (documentId == null) {
    return const CommandResult.unavailable();
  }

  return editorController
      .saveDocument(documentId);
},
```

Much cleaner.

---

# 17. Active editor context

Create:

```dart
CommandContext getCommandContext() {
  final group =
      editorController.activeGroup;

  final documentId =
      group?.activeDocumentId;

  final document =
      documentId == null
          ? null
          : editorController.document(
              documentId,
            );

  return CommandContext(
    documentId: documentId,
    filePath: document?.path,
    editorHasFocus: true,
  );
}
```

Then the command bus can eventually obtain context automatically.

---

# 18. Tab bar

Now the UI:

```dart
class EditorTabBar extends StatelessWidget {
  const EditorTabBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final editor =
        EditorScope.of(context);

    final group =
        editor.activeGroup;

    if (group == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
      child: Row(
        children: [
          for (final tab in group.tabs)
            EditorTabWidget(
              tab: tab,
              active:
                  tab.documentId ==
                      group.activeDocumentId,
            ),
        ],
      ),
    );
  }
}
```

---

# 19. Tab widget

```dart
class EditorTabWidget
    extends StatelessWidget {
  final EditorTab tab;
  final bool active;

  const EditorTabWidget({
    super.key,
    required this.tab,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final editor =
        EditorScope.of(context);

    final document =
        editor.document(
      tab.documentId,
    );

    if (document == null) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () {
        editor.activateDocument(
          document.id,
        );
      },
      child: Container(
        constraints:
            const BoxConstraints(
          minWidth: 120,
          maxWidth: 220,
        ),
        height: 40,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _fileName(document.path),
                overflow:
                    TextOverflow.ellipsis,
              ),
            ),

            if (document.isDirty)
              const DirtyIndicator(),

            const SizedBox(width: 8),

            const CloseButton(),
          ],
        ),
      ),
    );
  }

  String _fileName(String path) {
    return path.split('/').last;
  }
}
```

---

# 20. Active tab styling

The active tab should have three cues:

```text
active
├── stronger text
├── active background
└── bottom accent
```

Not:

```text
giant glowing rectangle
```

For example:

```dart
AnimatedContainer(
  duration: AppMotion.fast,
  decoration: BoxDecoration(
    color: active
        ? colors.surfaceRaised
        : Colors.transparent,
    border: Border(
      bottom: BorderSide(
        color: active
            ? colors.accent
            : Colors.transparent,
        width: 2,
      ),
    ),
  ),
)
```

---

# 21. Close tab properly

Closing a tab is more complicated than it looks.

If clean:

```text
close immediately
```

If dirty:

```text
┌───────────────────────────────────┐
│ Save changes?                     │
│                                   │
│ main.dart has unsaved changes.   │
│                                   │
│ Cancel     Don't Save       Save  │
└───────────────────────────────────┘
```

Never silently throw away work.

---

# 22. Close operation

```dart
Future<CommandResult> closeDocument(
  String documentId,
) async {
  final document =
      _documents[documentId];

  if (document == null) {
    return const CommandResult.unavailable();
  }

  if (document.isDirty) {
    final decision =
        await closeConfirmationService
            .confirm(document);

    if (decision ==
        CloseDecision.cancel) {
      return const CommandResult.cancelled();
    }

    if (decision ==
        CloseDecision.save) {
      final result =
          await saveDocument(documentId);

      if (!result.isSuccess) {
        return result;
      }
    }
  }

  _closeDocumentImmediately(
    documentId,
  );

  return const CommandResult.success();
}
```

---

# 23. Actual tab removal

```dart
void _closeDocumentImmediately(
  String documentId,
) {
  for (final group in _groups) {
    final index = group.tabs.indexWhere(
      (tab) =>
          tab.documentId == documentId,
    );

    if (index == -1) {
      continue;
    }

    final tabs = [
      ...group.tabs,
    ]..removeAt(index);

    String? activeId =
        group.activeDocumentId;

    if (activeId == documentId) {
      if (tabs.isEmpty) {
        activeId = null;
      } else if (index < tabs.length) {
        activeId =
            tabs[index].documentId;
      } else {
        activeId =
            tabs.last.documentId;
      }
    }

    _replaceGroup(
      group.copyWith(
        tabs: tabs,
        activeDocumentId: activeId,
      ),
    );
  }

  _documents.remove(documentId);

  notifyListeners();
}
```

This gives sensible focus after closing:

```text
A | B | C
      ↑ active

close B

A | C
    ↑ active
```

---

# 24. Middle-click close

For desktop UX:

```text
middle-click tab
       ↓
close tab
```

Also support:

```text
Ctrl/Cmd + W
```

through:

```dart
CommandId.closeEditor
```

Same command, same behavior.

---

# 25. Double-click tab

A useful convention:

```text
double-click tab
        ↓
pin tab
```

But don't add this until pinned tabs exist.

Otherwise we're adding behavior without a meaningful state model.

---

# 26. Pinned tabs

We can prepare for them:

```dart
class EditorTab {
  final String documentId;
  final bool pinned;

  const EditorTab({
    required this.documentId,
    this.pinned = false,
  });
}
```

Pinned tabs:

```text
[main.dart] [README] | api.dart | test.dart
   pinned   pinned
```

But again, implementation can come later.

---

# 27. Empty editor state

When no document is open:

```text
┌──────────────────────────────────────────┐
│                                          │
│                  Aljabr                  │
│                                          │
│       Open a file to start working       │
│                                          │
│       Ctrl+P   Command Palette           │
│       Ctrl+O   Open File                 │
│                                          │
└──────────────────────────────────────────┘
```

This is much better than an empty gray editor.

---

# 28. Breadcrumbs

The breadcrumb should derive from the active document.

For:

```text
lib/features/editor/controller/editor_controller.dart
```

show:

```text
lib / features / editor / controller /
editor_controller.dart
```

Implementation:

```dart
class EditorBreadcrumbs
    extends StatelessWidget {
  const EditorBreadcrumbs({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final editor =
        EditorScope.of(context);

    final group =
        editor.activeGroup;

    final id =
        group?.activeDocumentId;

    if (id == null) {
      return const SizedBox.shrink();
    }

    final document =
        editor.document(id);

    if (document == null) {
      return const SizedBox.shrink();
    }

    final parts =
        document.path.split('/');

    return Row(
      children: [
        for (int i = 0;
            i < parts.length;
            i++) ...[
          if (i > 0)
            const Text(' / '),

          Text(parts[i]),
        ],
      ],
    );
  }
}
```

Later, symbols become part of this:

```text
lib / editor / controller /
EditorController / saveDocument
```

---

# 29. Editor surface

The editor itself should receive a document model rather than directly accessing global application state.

```dart
class EditorSurface extends StatelessWidget {
  final EditorDocument document;

  const EditorSurface({
    super.key,
    required this.document,
  });

  @override
  Widget build(BuildContext context) {
    return CodeEditor(
      initialText: document.content,
      onChanged: (content) {
        EditorScope.of(context)
            .updateDocument(
              document.id,
              content,
            );
      },
    );
  }
}
```

The exact `CodeEditor` implementation depends on the editor engine already chosen in the project.

The important part is the boundary.

---

# 30. Avoid recreating the editor

A subtle performance issue:

Don't do this every rebuild:

```dart
CodeEditor(
  initialText: document.content,
)
```

because `initialText` may cause the editor's internal state to reset.

The editor needs its own controller:

```dart
class EditorDocumentController {
  final String documentId;

  late final TextEditingController
      textController;

  EditorDocumentController({
    required this.documentId,
    required String content,
  }) {
    textController =
        TextEditingController(
      text: content,
    );
  }

  void dispose() {
    textController.dispose();
  }
}
```

Then the document model remains the source of persisted state while the editor controller manages the live editing surface.

---

# 31. This gives us two levels of state

This distinction is important:

```text
Application state
    │
    └── EditorDocument
          ├── content
          ├── savedContent
          └── dirty

View state
    │
    └── EditorDocumentController
          ├── cursor
          ├── selection
          ├── scroll
          └── composition
```

Do **not** put cursor position into your global document model unless there is a strong reason.

---

# 32. Selection model

We'll need it for Agent integration.

```dart
class EditorSelection {
  final int start;
  final int end;

  const EditorSelection({
    required this.start,
    required this.end,
  });

  bool get isEmpty =>
      start == end;

  int get length =>
      end - start;
}
```

Then eventually:

```text
selected code
     ↓
CommandContext.selectedText
     ↓
Agent
```

---

# 33. Editor commands

Register the first commands:

```dart
registry.register(
  AppCommand(
    id: CommandId.closeEditor,
    title: 'Close Editor',
    category: 'Editor',
    execute: (context) async {
      final id = context.documentId;

      if (id == null) {
        return const CommandResult.unavailable();
      }

      return editorController
          .closeDocument(id);
    },
  ),
);
```

And:

```dart
registry.register(
  AppCommand(
    id: CommandId.saveFile,
    title: 'Save File',
    category: 'Editor',
    enabled: (context) {
      final id = context.documentId;

      if (id == null) {
        return false;
      }

      return editorController
          .document(id)
          ?.isDirty ??
          false;
    },
    execute: (context) async {
      final id = context.documentId;

      if (id == null) {
        return const CommandResult.unavailable();
      }

      return editorController
          .saveDocument(id);
    },
  ),
);
```

Now the Command Palette automatically knows whether Save is relevant.

---

# 34. Dirty state now propagates everywhere

The same state can drive:

```text
Tab
  ↓
●

Window title
  ↓
main.dart •

Command Palette
  ↓
Save File enabled

Close
  ↓
confirmation

Status bar
  ↓
Unsaved changes
```

One document state.

No duplicated booleans.

---

# 35. Editor workspace composition

Now the central area becomes:

```dart
class EditorWorkspace
    extends StatelessWidget {
  const EditorWorkspace({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final editor =
        EditorScope.of(context);

    final group =
        editor.activeGroup;

    return Column(
      children: [
        const EditorTabBar(),

        const EditorBreadcrumbs(),

        Expanded(
          child: _buildEditor(
            context,
            group,
            editor,
          ),
        ),
      ],
    );
  }
}
```

Then:

```dart
Widget _buildEditor(
  BuildContext context,
  EditorGroup? group,
  EditorController editor,
) {
  final id = group?.activeDocumentId;

  if (id == null) {
    return const EditorEmptyState();
  }

  final document =
      editor.document(id);

  if (document == null) {
    return const EditorEmptyState();
  }

  return EditorSurface(
    document: document,
  );
}
```

---

# 36. Resulting UX

We now have a real editor workflow:

```text
Open file
   ↓
Document registered
   ↓
Tab created
   ↓
Tab becomes active
   ↓
Editor loads content
   ↓
User edits
   ↓
Document becomes dirty
   ↓
Tab shows ●
   ↓
Ctrl+S
   ↓
Document saved
   ↓
● disappears
```

And:

```text
Ctrl+W
   ↓
Close command
   ↓
Clean?
 ┌─┴─┐
yes  no
 ↓    ↓
close confirmation
      ↓
 Save / Don't Save / Cancel
```

That is the correct behavioral foundation.

---

# 37. Checkpoint C.1

We now have:

```text
✅ Document model
✅ Tab model
✅ Editor group model
✅ Central editor controller
✅ Open document
✅ Activate document
✅ Dirty state
✅ Save state
✅ Close confirmation architecture
✅ Smart active-tab selection after close
✅ Tab UI
✅ Dirty indicator
✅ Empty editor state
✅ Breadcrumb foundation
✅ Selection model
✅ Editor command integration
✅ Split-editor-ready architecture
```

### Next: Phase C.2 — Editor Navigation & Search

We'll implement the features that make the editor **fast to navigate**:

```text
Ctrl+P
    → File search

Ctrl+Shift+F
    → Workspace search

Ctrl+G
    → Go to line

Ctrl+Shift+O
    → Symbol search

F12
    → Go to definition

Shift+F12
    → Find references

Breadcrumb click
    → folder/symbol navigation

Recent files
    → MRU navigation
```

And importantly, these will all plug into the **same Command Palette + Command Bus + Focus system** rather than becoming separate one-off UI implementations.



# Phase C.2 — Editor Navigation & Search

Now we make the editor **fast to navigate**.

The UX principle is:

> Anything that can be found should be reachable without taking your hands off the keyboard.

We will build this on top of the command architecture from C.1.

---

## 1. Navigation architecture

Add:

```text
lib/
└── navigation/
    ├── file_search_service.dart
    ├── workspace_search_service.dart
    ├── symbol_search_service.dart
    ├── navigation_controller.dart
    └── navigation_result.dart
```

And:

```text
Editor
  │
  ├── File Search
  ├── Workspace Search
  ├── Symbol Search
  ├── Go To Line
  ├── Go To Definition
  └── Find References
             │
             ↓
       NavigationController
             │
             ↓
        EditorController
```

---

# 2. Navigation result

Create a common result type.

```dart
sealed class NavigationResult {
  const NavigationResult();
}

class FileResult extends NavigationResult {
  final String path;

  const FileResult({
    required this.path,
  });
}

class SymbolResult extends NavigationResult {
  final String path;
  final String name;
  final int line;
  final int column;

  const SymbolResult({
    required this.path,
    required this.name,
    required this.line,
    required this.column,
  });
}

class LocationResult extends NavigationResult {
  final String path;
  final int line;
  final int column;

  const LocationResult({
    required this.path,
    required this.line,
    required this.column,
  });
}
```

This lets all navigation surfaces eventually converge on:

```text
NavigationResult
        ↓
open location
```

---

# 3. File search service

Start simple.

```dart
class FileSearchService {
  final FileIndex index;

  FileSearchService({
    required this.index,
  });

  List<String> search(String query) {
    final files = index.files;

    if (query.trim().isEmpty) {
      return files;
    }

    final scored = <({String path, int score})>[];

    for (final path in files) {
      final score = fuzzyScore(
        query,
        path,
      );

      if (score >= 0) {
        scored.add(
          (
            path: path,
            score: score,
          ),
        );
      }
    }

    scored.sort(
      (a, b) => b.score.compareTo(a.score),
    );

    return scored
        .map((item) => item.path)
        .toList();
  }
}
```

Reuse the fuzzy matcher from the Command Palette.

Do **not** create another fuzzy search implementation.

---

# 4. File index

We need a lightweight abstraction:

```dart
abstract interface class FileIndex {
  List<String> get files;

  Future<void> refresh();
}
```

Then later we can implement:

```text
LocalFileIndex
GitFileIndex
ProjectFileIndex
RemoteFileIndex
```

without changing the search UI.

---

# 5. File picker command

Register:

```dart
registry.register(
  AppCommand(
    id: CommandId.goToFile,
    title: 'Go to File',
    category: 'Navigation',
    description:
        'Search and open a file.',
    execute: (context) async {
      navigationController
          .openFileSearch();

      return const CommandResult.success();
    },
  ),
);
```

Shortcut:

```dart
KeyBinding(
  command: CommandId.goToFile,
  key: LogicalKeyboardKey.keyP,
  context: KeyContext.editor,
  modifiers: {
    KeyModifier.primary,
  },
)
```

So:

```text
Ctrl/Cmd + P
        ↓
Go to File
        ↓
File search
```

---

# 6. Don't create another modal implementation

The File Search UI should use the same surface engine as the Command Palette.

Instead of:

```text
CommandPalette
FileSearchDialog
SymbolSearchDialog
WorkspaceSearchDialog
```

build:

```text
SearchSurface
    │
    ├── CommandProvider
    ├── FileProvider
    ├── SymbolProvider
    └── WorkspaceSearchProvider
```

This is a major architectural improvement.

---

# 7. Generic search surface

```dart
abstract interface class SearchProvider<T> {
  String get placeholder;

  Future<List<SearchItem<T>>> search(
    String query,
  );
}
```

Search item:

```dart
class SearchItem<T> {
  final T value;
  final String title;
  final String? subtitle;
  final String? trailing;

  const SearchItem({
    required this.value,
    required this.title,
    this.subtitle,
    this.trailing,
  });
}
```

Now file search can return:

```dart
SearchItem<String>(
  value: path,
  title: fileName,
  subtitle: directory,
)
```

---

# 8. Search surface controller

```dart
class SearchSurfaceController<T>
    extends ChangeNotifier {

  String _query = '';

  int _selectedIndex = 0;

  List<SearchItem<T>> _results = [];

  String get query => _query;

  int get selectedIndex =>
      _selectedIndex;

  List<SearchItem<T>> get results =>
      List.unmodifiable(_results);

  void setResults(
    List<SearchItem<T>> results,
  ) {
    _results = results;
    _selectedIndex = 0;
    notifyListeners();
  }

  void moveSelection(int delta) {
    if (_results.isEmpty) {
      return;
    }

    _selectedIndex =
        (_selectedIndex + delta) %
            _results.length;

    if (_selectedIndex < 0) {
      _selectedIndex =
          _results.length - 1;
    }

    notifyListeners();
  }
}
```

---

# 9. Go to File UX

The result should look like:

```text
┌──────────────────────────────────────────────┐
│ ⌕  Search files...                       Esc │
├──────────────────────────────────────────────┤
│ › editor_controller.dart                    │
│   lib/editor/controller/editor_controller…  │
│                                              │
│   editor_workspace.dart                      │
│   lib/editor/widgets/editor_workspace.dart   │
│                                              │
│   editor_tab.dart                             │
│   lib/editor/model/editor_tab.dart           │
├──────────────────────────────────────────────┤
│ ↑↓ Navigate        ↵ Open        Esc Close   │
└──────────────────────────────────────────────┘
```

The **directory is critical**.

Showing only:

```text
editor.dart
editor.dart
editor.dart
```

creates ambiguity.

---

# 10. Highlight matching characters

Instead of:

```text
editor_controller.dart
```

render:

```text
editor_controller.dart
^^^^
```

with matching characters emphasized.

Create:

```dart
List<TextSpan> highlightMatch(
  String text,
  String query,
) {
  final spans = <TextSpan>[];

  final lowerText =
      text.toLowerCase();

  final lowerQuery =
      query.toLowerCase();

  int cursor = 0;

  for (final character
      in lowerQuery.characters) {

    final index =
        lowerText.indexOf(
      character,
      cursor,
    );

    if (index == -1) {
      break;
    }

    if (index > cursor) {
      spans.add(
        TextSpan(
          text: text.substring(
            cursor,
            index,
          ),
        ),
      );
    }

    spans.add(
      TextSpan(
        text: text[index],
        style: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    cursor = index + 1;
  }

  if (cursor < text.length) {
    spans.add(
      TextSpan(
        text: text.substring(cursor),
      ),
    );
  }

  return spans;
}
```

This dramatically improves scanability.

---

# 11. Recent files

The file picker should know what the user opened recently.

```dart
class RecentFileStore {
  final List<String> _files = [];

  List<String> get files =>
      List.unmodifiable(_files);

  void record(String path) {
    _files.remove(path);
    _files.insert(0, path);

    if (_files.length > 20) {
      _files.removeLast();
    }
  }
}
```

When opening a file:

```dart
recentFiles.record(path);
```

Now empty search can show:

```text
RECENT

editor_controller.dart
editor_workspace.dart
command_palette.dart
```

---

# 12. MRU navigation

Add:

```text
Ctrl + Tab
```

This should not simply mean "next tab".

Instead:

```text
A → B → C

Ctrl+Tab
    ↓
B
```

and repeated:

```text
Ctrl+Tab
    ↓
A
```

based on **most recently used** ordering.

Track it:

```dart
class EditorMru {
  final List<String> _documents = [];

  void activate(String documentId) {
    _documents.remove(documentId);
    _documents.insert(0, documentId);
  }

  List<String> get documents =>
      List.unmodifiable(_documents);
}
```

This feels much more natural in a large workspace.

---

# 13. Go to line

Add:

```dart
CommandId.goToLine
```

Shortcut:

```dart
KeyBinding(
  command: CommandId.goToLine,
  key: LogicalKeyboardKey.keyG,
  context: KeyContext.editor,
  modifiers: {
    KeyModifier.primary,
  },
)
```

UX:

```text
Ctrl + G
      ↓
┌───────────────────────────────┐
│ Go to line                    │
│ 184                           │
└───────────────────────────────┘
```

Press Enter:

```text
cursor → line 184
```

---

# 14. Parse line input safely

```dart
int? parseLine(String input) {
  final value =
      int.tryParse(input.trim());

  if (value == null) {
    return null;
  }

  if (value < 1) {
    return null;
  }

  return value;
}
```

Then:

```dart
final line = parseLine(query);

if (line == null) {
  return SearchValidation.invalid(
    'Enter a valid line number.',
  );
}
```

---

# 15. Support line + column

Developer tools should also accept:

```text
184:12
```

Parser:

```dart
class EditorLocation {
  final int line;
  final int column;

  const EditorLocation({
    required this.line,
    required this.column,
  });
}

EditorLocation? parseLocation(
  String input,
) {
  final parts =
      input.trim().split(':');

  final line =
      int.tryParse(parts.first);

  if (line == null || line < 1) {
    return null;
  }

  final column =
      parts.length > 1
          ? int.tryParse(parts[1])
          : 1;

  if (column == null || column < 1) {
    return null;
  }

  return EditorLocation(
    line: line,
    column: column,
  );
}
```

Now:

```text
Ctrl+G
184:12
Enter
```

lands exactly there.

---

# 16. Symbol search

Next:

```text
Ctrl + Shift + O
```

should produce:

```text
SYMBOLS

EditorController
  lib/editor/controller/editor_controller.dart

openDocument
  editor_controller.dart:42

saveDocument
  editor_controller.dart:91

closeDocument
  editor_controller.dart:118
```

---

# 17. Symbol model

```dart
enum SymbolKind {
  class_,
  method,
  function,
  property,
  field,
  variable,
  enum_,
  interface,
}

class EditorSymbol {
  final String name;
  final SymbolKind kind;
  final String path;
  final int line;
  final int column;

  const EditorSymbol({
    required this.name,
    required this.kind,
    required this.path,
    required this.line,
    required this.column,
  });
}
```

---

# 18. Symbol provider

Don't make the UI parse source code.

```dart
abstract interface class SymbolProvider {
  Future<List<EditorSymbol>> symbols(
    String path,
  );
}
```

Potential implementations:

```text
DartSymbolProvider
TypeScriptSymbolProvider
PythonSymbolProvider
LspSymbolProvider
```

The navigation layer doesn't care.

---

# 19. Symbol search provider

```dart
class SymbolSearchProvider
    implements SearchProvider<EditorSymbol> {

  final SymbolProvider symbols;
  final String currentPath;

  SymbolSearchProvider({
    required this.symbols,
    required this.currentPath,
  });

  @override
  String get placeholder =>
      'Search symbols...';

  @override
  Future<List<SearchItem<EditorSymbol>>>
      search(String query) async {

    final items =
        await symbols.symbols(
      currentPath,
    );

    final results = <SearchItem<EditorSymbol>>[];

    for (final symbol in items) {
      final score = fuzzyScore(
        query,
        symbol.name,
      );

      if (score < 0) {
        continue;
      }

      results.add(
        SearchItem(
          value: symbol,
          title: symbol.name,
          subtitle:
              '${symbol.kind.name} · '
              'line ${symbol.line}',
        ),
      );
    }

    return results;
  }
}
```

---

# 20. Go to definition

This should be a command:

```dart
registry.register(
  AppCommand(
    id: CommandId.goToDefinition,
    title: 'Go to Definition',
    category: 'Navigation',
    enabled: (context) =>
        context.editorHasFocus,
    execute: (context) async {
      final location =
          await definitionService
              .findDefinition(
        context,
      );

      if (location == null) {
        return const CommandResult.failure(
          'Definition not found.',
        );
      }

      await navigationController
          .openLocation(location);

      return const CommandResult.success();
    },
  ),
);
```

The UI doesn't need to know whether the definition comes from:

```text
LSP
index
AST
language server
```

---

# 21. F12

Bind:

```dart
KeyBinding(
  command: CommandId.goToDefinition,
  key: LogicalKeyboardKey.f12,
  context: KeyContext.editor,
)
```

Now:

```text
F12
 ↓
definitionService
 ↓
LocationResult
 ↓
navigationController
 ↓
open document
 ↓
move cursor
```

---

# 22. Find references

Add:

```dart
CommandId.findReferences
```

Shortcut:

```text
Shift + F12
```

Result:

```text
REFERENCES

editor_controller.dart:42
  EditorController

workspace.dart:18
  EditorController

app.dart:61
  EditorController
```

This is where a proper result list becomes useful.

---

# 23. Navigation controller

Centralize all opening.

```dart
class NavigationController {
  final EditorController editor;

  NavigationController({
    required this.editor,
  });

  Future<void> openFile(
    String path,
  ) async {
    final document =
        await documentService.open(path);

    editor.openDocument(document);
  }

  Future<void> openLocation(
    LocationResult location,
  ) async {
    await openFile(location.path);

    editor.moveCursor(
      location.path,
      line: location.line,
      column: location.column,
    );
  }
}
```

Now every feature uses:

```text
openFile()
openLocation()
```

instead of manipulating tabs directly.

---

# 24. Breadcrumbs become interactive

Instead of plain text:

```text
lib / editor / controller / editor.dart
```

each segment becomes clickable.

```dart
InkWell(
  onTap: () {
    navigationController
        .openDirectory(path);
  },
  child: Text(segment),
)
```

Hover:

```text
cursor → pointer
surface → subtle highlight
```

---

# 25. Breadcrumb keyboard support

A focused breadcrumb should support:

```text
← →
Enter
Esc
```

But don't over-engineer this yet.

The important part is that it uses the same focus architecture.

---

# 26. Workspace search

Now the bigger search:

```text
Ctrl + Shift + F
```

UI:

```text
┌──────────────────────────────────────────────┐
│ ⌕  Search in workspace...                   │
├──────────────────────────────────────────────┤
│ 18 results                                   │
│                                              │
│ editor_controller.dart                      │
│  42  EditorController                        │
│      class EditorController ...              │
│                                              │
│ workspace.dart                               │
│  81  editorController                        │
│      final editorController = ...            │
└──────────────────────────────────────────────┘
```

---

# 27. Search result model

```dart
class WorkspaceSearchResult {
  final String path;
  final int line;
  final int column;
  final String preview;

  const WorkspaceSearchResult({
    required this.path,
    required this.line,
    required this.column,
    required this.preview,
  });
}
```

---

# 28. Search service abstraction

```dart
abstract interface class WorkspaceSearchService {
  Stream<WorkspaceSearchResult> search(
    String query,
  );
}
```

Why a stream?

Because large projects may return results progressively.

UX:

```text
search
 ↓
first results immediately
 ↓
more results arrive
 ↓
count updates
```

rather than:

```text
search
 ↓
freeze
 ↓
wait
 ↓
everything appears
```

---

# 29. Cancellation

This is important.

If the user types:

```text
edi
```

then:

```text
edit
```

then:

```text
editor
```

we should cancel previous searches.

Use a generation ID:

```dart
int _searchGeneration = 0;

Future<void> search(String query) async {
  final generation =
      ++_searchGeneration;

  final results =
      await service.search(query);

  if (generation != _searchGeneration) {
    return;
  }

  updateResults(results);
}
```

This prevents stale results from replacing newer results.

---

# 30. Debounce

Don't search on every keystroke immediately.

```dart
Timer? _debounce;

void onQueryChanged(String query) {
  _debounce?.cancel();

  _debounce = Timer(
    const Duration(milliseconds: 120),
    () {
      search(query);
    },
  );
}
```

120 ms is enough to feel instant while reducing unnecessary work.

---

# 31. Search UX states

Every search surface needs:

```text
idle
loading
results
empty
error
```

Example:

```text
LOADING

Searching workspace...
```

Empty:

```text
No results found

Try a different search term.
```

Error:

```text
Search failed

Retry
```

Never leave the user with an unexplained blank area.

---

# 32. Unified navigation commands

At this point register:

```text
Ctrl/Cmd + P
    → Go to File

Ctrl/Cmd + Shift + P
    → Command Palette

Ctrl/Cmd + Shift + F
    → Search Workspace

Ctrl/Cmd + Shift + O
    → Go to Symbol

Ctrl/Cmd + G
    → Go to Line

F12
    → Go to Definition

Shift + F12
    → Find References
```

All go through:

```text
CommandRegistry
       ↓
CommandBus
       ↓
NavigationController
```

---

# 33. One more important shortcut: quick switcher

Add:

```text
Ctrl + Tab
```

The UI:

```text
┌────────────────────────────────────┐
│ Recently Opened                    │
│                                    │
│ › editor.dart                      │
│   workspace.dart                   │
│   command_palette.dart             │
│   app.dart                         │
│                                    │
│ ↑↓ Navigate    Release Ctrl Select │
└────────────────────────────────────┘
```

This is different from File Search.

File search asks:

> Which file do you want?

Quick switch asks:

> Which open file were you just using?

Keep those mental models separate.

---

# 34. Resulting navigation architecture

```text
                       NAVIGATION
                           │
          ┌────────────────┼────────────────┐
          ↓                ↓                ↓
      Open File       Open Symbol       Search
          │                │                │
          ↓                ↓                ↓
     File Index       Symbol Index     Workspace Index
          │                │                │
          └────────────────┼────────────────┘
                           ↓
                  NavigationController
                           ↓
                    EditorController
                           ↓
                     Editor Surface
```

---

# 35. The UX payoff

The editor workflow is now:

```text
User sees something
      ↓
Ctrl/Cmd + P
      ↓
find file
      ↓
Enter
      ↓
file opens
      ↓
Ctrl/Cmd + Shift + O
      ↓
find symbol
      ↓
Enter
      ↓
cursor jumps
```

Or:

```text
F12
 ↓
definition
 ↓
file opens
 ↓
cursor moves
```

Or:

```text
Ctrl+Shift+F
 ↓
workspace search
 ↓
results stream in
 ↓
Enter
 ↓
exact location opens
```

This is the point where the editor begins to feel **fast**, not merely polished.

---

# Checkpoint C.2

We now have:

```text
✅ Go to File
✅ Fuzzy file search
✅ Recent files
✅ MRU editor switching
✅ Go to Line
✅ Line + column parsing
✅ Symbol search architecture
✅ Go to Definition
✅ Find References
✅ Workspace search architecture
✅ Search cancellation
✅ Search debounce
✅ Search loading/empty/error states
✅ Interactive breadcrumbs
✅ Unified NavigationController
✅ Unified command integration
```

## Next: Phase C.3 — Editor Intelligence + Agent Integration

This is where the GUI starts becoming differentiated.

We'll connect:

```text
Editor Selection
      │
      ├── Explain
      ├── Refactor
      ├── Fix
      ├── Generate
      └── Review
             │
             ↓
          Agent
             │
             ↓
       Proposed Change
             │
      ┌──────┴──────┐
      ↓             ↓
    Accept         Reject
      │
      ↓
Editor Document
      │
      ↓
Dirty State
```

The important UX rule will be **never let an Agent action silently mutate the editor**. Agent changes should become explicit, reviewable proposals first.


