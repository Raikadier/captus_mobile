#!/usr/bin/env python3
"""
Replace GestureDetector(onTap: X, child: Y) with CaptusPressable(onTap: X, child: Y).
Only replaces simple onTap-only GestureDetectors; skips those with other handlers.
"""
import re
import os

SKIP_FILES = {
    'captus_pressable.dart', 'captus_fab.dart', 'task_card.dart',
    'gesture_migration.py',
}

PRESSABLE_IMPORT_PATTERNS = {
    'features': "import '../../../shared/widgets/captus_pressable.dart';",
    'shared': "import '../../shared/widgets/captus_pressable.dart';",
    'core': "import '../../shared/widgets/captus_pressable.dart';",
}


def get_pressable_import(path):
    p = path.replace('\\', '/')
    if '/features/' in p:
        return "import '../../../shared/widgets/captus_pressable.dart';"
    if '/shared/' in p:
        return "import '../../shared/widgets/captus_pressable.dart';"
    return "import '../../shared/widgets/captus_pressable.dart';"


def add_import(content, import_str):
    if 'captus_pressable.dart' in content:
        return content
    lines = content.split('\n')
    # After last import
    last = max((i for i, l in enumerate(lines) if l.strip().startswith('import ')), default=0)
    lines.insert(last + 1, import_str)
    return '\n'.join(lines)


def replace_gesture_detectors(content):
    """
    Replace GestureDetector(onTap: X, child: Y,) with CaptusPressable(onTap: X, child: Y,)
    Only when it ONLY has onTap (no onLongPress, onDoubleTap, behavior, etc.)
    """
    added_import = False

    # Simple single-line: GestureDetector(onTap: X, child: Y)
    # We look for GestureDetector blocks where the first named param is onTap
    # and there's no other gesture handler

    # Strategy: line-by-line, find GestureDetector( lines where the next content
    # only contains onTap and child (no other gesture callbacks)

    # Use a regex that matches GestureDetector followed by onTap as first/only handler
    # Pattern: GestureDetector(\n  onTap: ...\n  child: ... or GestureDetector(onTap: ..., child: ...

    def is_simple_gesture(block):
        """Return True if block only has onTap (no other gesture callbacks)."""
        other_gestures = [
            'onLongPress', 'onDoubleTap', 'onPanUpdate', 'onPanStart',
            'onPanEnd', 'onScaleUpdate', 'onTapDown', 'onTapUp', 'onTapCancel',
            'onSecondaryTap', 'behavior:', 'excludeFromSemantics',
            'onHorizontalDrag', 'onVerticalDrag', 'dragStartBehavior',
        ]
        return not any(g in block for g in other_gestures)

    # Replace GestureDetector( -> CaptusPressable( for simple onTap-only detectors
    # We'll do a careful search: find 'GestureDetector(' in the content,
    # then check if the enclosing block is onTap-only

    result = []
    i = 0
    text = content
    modified = False

    while i < len(text):
        idx = text.find('GestureDetector(', i)
        if idx == -1:
            result.append(text[i:])
            break

        result.append(text[i:idx])

        # Find the matching closing paren
        start = idx + len('GestureDetector(')
        depth = 1
        j = start
        while j < len(text) and depth > 0:
            if text[j] == '(':
                depth += 1
            elif text[j] == ')':
                depth -= 1
            j += 1

        block = text[idx:j]  # full GestureDetector(...) including closing )

        if is_simple_gesture(block):
            # Replace
            new_block = 'CaptusPressable(' + block[len('GestureDetector('):]
            result.append(new_block)
            added_import = True
            modified = True
        else:
            result.append(block)

        i = j

    return ''.join(result), modified, added_import


def process(path):
    fname = os.path.basename(path)
    if fname in SKIP_FILES:
        return False

    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'GestureDetector(' not in content:
        return False

    new_content, modified, needs_import = replace_gesture_detectors(content)

    if modified:
        if needs_import:
            new_content = add_import(new_content, get_pressable_import(path))
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True
    return False


def main():
    changed = 0
    for root, dirs, files in os.walk('lib'):
        dirs[:] = [d for d in dirs if d not in ['.dart_tool', 'build']]
        for fname in files:
            if not fname.endswith('.dart'):
                continue
            if process(os.path.join(root, fname)):
                changed += 1
    print(f'GestureDetector -> CaptusPressable: changed {changed} files')


if __name__ == '__main__':
    main()
