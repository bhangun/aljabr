import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/sidebar/sidebar_widget.dart';
import '../widgets/chat/chat_panel.dart';
import '../widgets/editor/editor_panel_shell.dart';

/// Composes the three modular columns from the reference screenshot:
/// sidebar | chat panel | code editor panel. Falls back to a tabbed
/// layout on narrow (mobile) widths so the same widgets are reusable there.
class IdeHomeScreen extends StatelessWidget {
  const IdeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          if (isWide) {
            return const Row(
              children: [
                SidebarWidget(),
                VerticalDivider(width: 1),
                Expanded(flex: 5, child: ChatPanel()),
                VerticalDivider(width: 1),
                Expanded(flex: 4, child: EditorPanelShell()),
              ],
            );
          }
          return const _NarrowLayout();
        },
      ),
    );
  }
}

class _NarrowLayout extends StatefulWidget {
  const _NarrowLayout();

  @override
  State<_NarrowLayout> createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<_NarrowLayout> {
  int _tab = 1; // default to chat, like the reference screenshot

  @override
  Widget build(BuildContext context) {
    const pages = [SidebarWidget(), ChatPanel(), EditorPanelShell()];
    return Column(
      children: [
        Expanded(child: pages[_tab]),
        NavigationBar(
          selectedIndex: _tab,
          backgroundColor: AppTheme.panel,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.menu), label: 'Chats'),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Chat',
            ),
            NavigationDestination(icon: Icon(Icons.code), label: 'Editor'),
          ],
        ),
      ],
    );
  }
}
