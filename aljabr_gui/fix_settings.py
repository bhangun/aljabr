import re

with open('lib/features/settings/screens/settings_dialog.dart', 'r') as f:
    code = f.read()

# 1. Convert _AppearanceSection and others to ConsumerWidget
sections = ['_AppearanceSection', '_AiProviderSection', '_LocalLlmSection', '_AgentSecuritySection', 
            '_BrowserSection', '_NotificationsSection', '_PrivacySection', '_AdvancedSection']

for sec in sections:
    # Convert StatefulWidget -> ConsumerStatefulWidget
    code = re.sub(rf'class {sec} extends StatefulWidget', f'class {sec} extends ConsumerStatefulWidget', code)
    code = re.sub(rf'State<{sec}> createState\(\) => {sec}State\(\);', f'ConsumerState<{sec}> createState() => {sec}State();', code)
    code = re.sub(rf'class {sec}State extends State<{sec}>', f'class {sec}State extends ConsumerState<{sec}>', code)
    
    # Convert StatelessWidget -> ConsumerWidget
    code = re.sub(rf'class {sec} extends StatelessWidget', f'class {sec} extends ConsumerWidget', code)

# 2. Inject final settings = ref.watch(settingsProvider) into build methods
def replace_build(match):
    before = match.group(1)
    args = match.group(2)
    # If it doesn't already have WidgetRef ref, add it
    if 'WidgetRef' not in args:
        if 'BuildContext context' in args:
            args = args.replace('BuildContext context', 'BuildContext context, WidgetRef ref')
    return f"{before}build({args}) {{\n    final settings = ref.watch(settingsProvider);\n    final notifier = ref.read(settingsProvider.notifier);"

# Note: this might match all build methods, let's just do it for classes that have been converted.
code = re.sub(r'(Widget\s+)build\(([^)]+)\)\s*\{', replace_build, code)

with open('lib/features/settings/screens/settings_dialog.dart', 'w') as f:
    f.write(code)
print("done")
