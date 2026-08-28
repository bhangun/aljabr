import sys

with open('lib/features/settings/screens/settings_dialog.dart', 'r') as f:
    content = f.read()

# Add import
if 'import \'skills_settings_view.dart\';' not in content:
    content = content.replace('import \'../../../theme/app_colors.dart\';', 'import \'../../../theme/app_colors.dart\';\nimport \'skills_settings_view.dart\';')

# Add enum
content = content.replace('agentSecurity,', 'agentSecurity,\n  skills,')

# Add to left rail
nav_item = """          _NavItem(
            icon: Icons.psychology_outlined,
            label: 'Skills',
            isSelected: _currentSection == _SettingsSection.skills,
            onTap: () =>
                setState(() => _currentSection = _SettingsSection.skills),
          ),
"""
content = content.replace('_NavItem(\n            icon: Icons.language,', nav_item + '          _NavItem(\n            icon: Icons.language,')

# Add to switch
switch_case = """      case _SettingsSection.skills:
        return const SkillsSettingsView();
"""
content = content.replace('case _SettingsSection.browser:', switch_case + '      case _SettingsSection.browser:')

with open('lib/features/settings/screens/settings_dialog.dart', 'w') as f:
    f.write(content)

