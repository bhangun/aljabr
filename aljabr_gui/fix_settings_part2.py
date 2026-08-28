import re

with open('lib/features/settings/screens/settings_dialog.dart', 'r') as f:
    code = f.read()

# Fix ConsumerWidget build signatures (e.g. class _AppearanceSection extends ConsumerWidget)
# We need to find classes extending ConsumerWidget and update their build method.
consumer_widgets = re.findall(r'class\s+(\w+)\s+extends\s+ConsumerWidget', code)

for cw in consumer_widgets:
    # Find the build method for this class specifically.
    # It's tricky with regex, so let's just replace all "Widget build(BuildContext context)"
    # inside ConsumerWidgets by doing a generic replace of the signature for the specific classes if possible.
    pass

# Actually, the simplest fix is:
# 1. Any class extending ConsumerWidget MUST have `Widget build(BuildContext context, WidgetRef ref)`
code = re.sub(r'class (\w+) extends ConsumerWidget \{\n\s+@override\n\s+Widget build\(BuildContext context\)',
              r'class \1 extends ConsumerWidget {\n  @override\n  Widget build(BuildContext context, WidgetRef ref)', code)

# But wait, there are also classes that don't extend ConsumerWidget (they extend StatelessWidget or State).
# They have `final settings = ref.watch...` which causes undefined `ref`.
# We can just remove `final settings = ref.watch...` and `final notifier = ...` if `ref` is not in the signature
# AND the class doesn't extend ConsumerState.
# Wait, ConsumerState HAS `ref` as a property! So `ref` IS defined in ConsumerState. 
# Why did `_LocalLlmSectionState` fail with `invalid_override`? 
# Ah, `_LocalLlmSectionState` extends `ConsumerState`. Its build method should be `Widget build(BuildContext context)`.
# But wait, `flutter analyze` said:
# `error • '_LocalLlmSectionState.build' ('Widget Function(BuildContext, WidgetRef)') isn't a valid override of 'State.build' ('Widget Function(BuildContext)')`
# Oh! Because my `sed` command missed it if it wasn't exactly matching.
# Let's just fix the whole file systematically.

import re

lines = code.split('\n')
out = []
in_consumer_widget = False

for i, line in enumerate(lines):
    if 'extends ConsumerWidget' in line:
        in_consumer_widget = True
    elif 'extends StatelessWidget' in line or 'extends State<' in line:
        in_consumer_widget = False

    if 'Widget build(BuildContext context)' in line and in_consumer_widget:
        line = line.replace('Widget build(BuildContext context)', 'Widget build(BuildContext context, WidgetRef ref)')
    
    if 'Widget build(BuildContext context, WidgetRef ref)' in line and not in_consumer_widget:
        line = line.replace('Widget build(BuildContext context, WidgetRef ref)', 'Widget build(BuildContext context)')

    out.append(line)

code = '\n'.join(out)

# Now remove `ref.watch` and `ref.read` from places that don't have `ref`.
# `ref` is available in ConsumerWidget (via arg) and ConsumerState (via property).
# It is NOT available in StatelessWidget or State.
out2 = []
in_valid_ref_context = False
for line in code.split('\n'):
    if 'extends ConsumerWidget' in line or 'extends ConsumerState<' in line or 'extends ConsumerStatefulWidget' in line:
        in_valid_ref_context = True
    elif 'extends StatelessWidget' in line or 'extends State<' in line or 'extends StatefulWidget' in line:
        in_valid_ref_context = False

    if ('ref.watch' in line or 'ref.read' in line) and not in_valid_ref_context:
        continue # skip injecting these lines
    out2.append(line)

with open('lib/features/settings/screens/settings_dialog.dart', 'w') as f:
    f.write('\n'.join(out2))

print("done")
