#!/usr/bin/env python3
"""
Deep design system migration — Layers 6-10
Applies: AppRadius, AppDurations, AppAlpha to all Flutter files.
"""
import re
import os

# ── Border radius mapping ──────────────────────────────────────────────────
RADIUS_MAP = {
    '4': 'AppRadius.r1', '6': 'AppRadius.r2', '8': 'AppRadius.r3',
    '10': 'AppRadius.r4', '12': 'AppRadius.r5', '14': 'AppRadius.r6',
    '16': 'AppRadius.r7', '20': 'AppRadius.r8', '24': 'AppRadius.r9',
    '28': 'AppRadius.r10',
    '50': 'AppRadius.pill', '99': 'AppRadius.pill',
    '100': 'AppRadius.pill', '999': 'AppRadius.pill',
}

# ── Duration mapping ───────────────────────────────────────────────────────
DURATION_MAP = {
    '80': 'AppDurations.instant',
    '100': 'AppDurations.quick', '120': 'AppDurations.quick',
    '150': 'AppDurations.fast', '180': 'AppDurations.fast',
    '200': 'AppDurations.fast',
    '240': 'AppDurations.standard', '250': 'AppDurations.standard',
    '300': 'AppDurations.comfortable', '320': 'AppDurations.comfortable',
    '400': 'AppDurations.slow', '420': 'AppDurations.slow',
    '500': 'AppDurations.slow',
    '600': 'AppDurations.deliberate',
    '1200': 'AppDurations.deliberate',
}

# ── Alpha mapping ──────────────────────────────────────────────────────────
ALPHA_MAP = {
    '10': 'AppAlpha.a04', '13': 'AppAlpha.a05',
    '20': 'AppAlpha.a08',
    '25': 'AppAlpha.a10', '26': 'AppAlpha.a10',
    '30': 'AppAlpha.a12', '31': 'AppAlpha.a12',
    '38': 'AppAlpha.a15', '40': 'AppAlpha.a15',
    '50': 'AppAlpha.a20', '51': 'AppAlpha.a20',
    '60': 'AppAlpha.a24', '70': 'AppAlpha.a24',
    '76': 'AppAlpha.a30', '77': 'AppAlpha.a30',
    '100': 'AppAlpha.a40', '102': 'AppAlpha.a40',
    '128': 'AppAlpha.a50', '130': 'AppAlpha.a50',
    '153': 'AppAlpha.a60', '166': 'AppAlpha.a60',
    '178': 'AppAlpha.a70', '179': 'AppAlpha.a70',
    '191': 'AppAlpha.a70', '200': 'AppAlpha.a70',
    '204': 'AppAlpha.a80', '210': 'AppAlpha.a80',
    '230': 'AppAlpha.a90',
}

SKIP_FILES = {
    'app_theme.dart', 'app_radius.dart', 'app_animations.dart',
    'app_colors.dart', 'app_spacing.dart', 'app_shadows.dart',
    'app_gradients.dart', 'deep_migration.py', 'migrate_design_system.py',
}


def get_import_prefix(path):
    p = path.replace('\\', '/')
    if '/features/' in p or '/shared/' in p:
        depth = p.count('/') - p.index('lib/') // 1
        # features/X/screens/*.dart → ../../../
        parts = p.split('lib/', 1)[1].split('/')
        ups = len(parts) - 1
        return '../' * ups + 'core/constants/'
    if '/core/' in p:
        parts = p.split('lib/', 1)[1].split('/')
        ups = len(parts) - 1
        return '../' * ups + 'constants/'
    return '../../core/constants/'


def add_import_after(content, import_str, anchor_substr):
    if import_str in content:
        return content
    lines = content.split('\n')
    idx = -1
    for i, line in enumerate(lines):
        if anchor_substr in line and line.strip().startswith('import '):
            idx = i
    if idx < 0:
        # After last import
        for i, line in enumerate(lines):
            if line.strip().startswith('import '):
                idx = i
    if idx >= 0:
        lines.insert(idx + 1, import_str)
    return '\n'.join(lines)


def process_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    orig = content

    added_radius = False
    added_duration = False

    # 1. BorderRadius.circular(N)
    def repl_br(m):
        nonlocal added_radius
        n = m.group(1).rstrip('0').rstrip('.')
        if n in RADIUS_MAP:
            added_radius = True
            return f'BorderRadius.circular({RADIUS_MAP[n]})'
        return m.group(0)
    content = re.sub(r'BorderRadius\.circular\(([\d.]+)\)', repl_br, content)

    # 1b. Radius.circular(N) (inside BorderRadius.vertical/only)
    def repl_r(m):
        nonlocal added_radius
        n = m.group(1).rstrip('0').rstrip('.')
        if n in RADIUS_MAP:
            added_radius = True
            return f'Radius.circular({RADIUS_MAP[n]})'
        return m.group(0)
    content = re.sub(r'Radius\.circular\(([\d.]+)\)', repl_r, content)

    # 2. Duration(milliseconds: N)
    def repl_dur(m):
        nonlocal added_duration
        n = m.group(1)
        if n in DURATION_MAP:
            added_duration = True
            return DURATION_MAP[n]
        return m.group(0)
    content = re.sub(r'(?:const\s+)?Duration\(milliseconds:\s*(\d+)\)', repl_dur, content)

    # 3. .withAlpha(N) — AppAlpha is in app_colors.dart, always imported
    def repl_alpha(m):
        n = m.group(1)
        if n in ALPHA_MAP:
            return f'.withAlpha({ALPHA_MAP[n]})'
        return m.group(0)
    content = re.sub(r'\.withAlpha\((\d+)\)', repl_alpha, content)

    # Add imports
    prefix = get_import_prefix(path)
    if added_radius:
        content = add_import_after(
            content,
            f"import '{prefix}app_radius.dart';",
            'app_spacing'
        )
    if added_duration and 'app_animations.dart' not in content:
        content = add_import_after(
            content,
            f"import '{prefix}app_animations.dart';",
            'app_colors'
        )

    if content != orig:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False


def main():
    changed = []
    for root, dirs, files in os.walk('lib'):
        dirs[:] = [d for d in dirs if d not in ['.dart_tool', 'build']]
        for fname in files:
            if fname in SKIP_FILES or not fname.endswith('.dart'):
                continue
            full = os.path.join(root, fname)
            try:
                if process_file(full):
                    changed.append(full)
            except Exception as e:
                print(f'ERR {fname}: {e}')

    print(f'Changed: {len(changed)} files')
    return changed


if __name__ == '__main__':
    main()
