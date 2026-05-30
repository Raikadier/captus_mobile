#!/usr/bin/env python3
"""
Spacing deep migration — replace remaining EdgeInsets and SizedBox
hardcoded values with AppSpacing tokens.
"""
import re
import os

SKIP_FILES = {
    'app_theme.dart', 'app_radius.dart', 'app_animations.dart',
    'app_colors.dart', 'app_spacing.dart', 'app_shadows.dart',
    'app_gradients.dart', 'deep_migration.py', 'migrate_design_system.py',
    'spacing_migration.py',
}

# EdgeInsets.only patterns
ONLY_MAP = {
    'bottom: 4': 'bottom: AppSpacing.s1',
    'bottom: 8': 'bottom: AppSpacing.s2',
    'bottom: 12': 'bottom: AppSpacing.s3',
    'bottom: 16': 'bottom: AppSpacing.s4',
    'bottom: 20': 'bottom: AppSpacing.s5',
    'bottom: 24': 'bottom: AppSpacing.s6',
    'bottom: 32': 'bottom: AppSpacing.s8',
    'bottom: 40': 'bottom: AppSpacing.s10',
    'bottom: 48': 'bottom: AppSpacing.s12',
    'top: 4': 'top: AppSpacing.s1',
    'top: 8': 'top: AppSpacing.s2',
    'top: 12': 'top: AppSpacing.s3',
    'top: 16': 'top: AppSpacing.s4',
    'top: 20': 'top: AppSpacing.s5',
    'top: 24': 'top: AppSpacing.s6',
    'top: 32': 'top: AppSpacing.s8',
    'left: 4': 'left: AppSpacing.s1',
    'left: 8': 'left: AppSpacing.s2',
    'left: 12': 'left: AppSpacing.s3',
    'left: 16': 'left: AppSpacing.s4',
    'left: 20': 'left: AppSpacing.s5',
    'left: 24': 'left: AppSpacing.s6',
    'right: 4': 'right: AppSpacing.s1',
    'right: 8': 'right: AppSpacing.s2',
    'right: 12': 'right: AppSpacing.s3',
    'right: 16': 'right: AppSpacing.s4',
    'right: 20': 'right: AppSpacing.s5',
    'right: 24': 'right: AppSpacing.s6',
}


def replace_edgeinsets(content):
    changed = False

    # EdgeInsets.all(N) — all common sizes
    def repl_all(m):
        nonlocal changed
        n = m.group(1).rstrip('0').rstrip('.')
        mapping = {
            '4': 'AppSpacing.s1', '8': 'AppSpacing.s2',
            '12': 'AppSpacing.s3', '16': 'AppSpacing.s4',
            '20': 'AppSpacing.s5', '24': 'AppSpacing.s6',
            '32': 'AppSpacing.s8', '40': 'AppSpacing.s10',
            '48': 'AppSpacing.s12', '64': 'AppSpacing.s16',
        }
        if n in mapping:
            changed = True
            return f'EdgeInsets.all({mapping[n]})'
        return m.group(0)
    content = re.sub(r'EdgeInsets\.all\(([\d.]+)\)', repl_all, content)

    # EdgeInsets.symmetric(horizontal: N) — single param
    def repl_sym_h(m):
        nonlocal changed
        n = m.group(1).rstrip('0').rstrip('.')
        mapping = {
            '4': 'AppSpacing.s1', '8': 'AppSpacing.s2',
            '12': 'AppSpacing.s3', '14': 'AppSpacing.s3',
            '16': 'AppSpacing.s4', '20': 'AppSpacing.s5',
            '24': 'AppSpacing.s6', '32': 'AppSpacing.s8',
        }
        if n in mapping:
            changed = True
            return f'EdgeInsets.symmetric(horizontal: {mapping[n]})'
        return m.group(0)
    content = re.sub(
        r'EdgeInsets\.symmetric\(horizontal:\s*([\d.]+)\)',
        repl_sym_h, content)

    # EdgeInsets.symmetric(vertical: N)
    def repl_sym_v(m):
        nonlocal changed
        n = m.group(1).rstrip('0').rstrip('.')
        mapping = {
            '4': 'AppSpacing.s1', '6': 'AppSpacing.s1',
            '8': 'AppSpacing.s2', '10': 'AppSpacing.s2',
            '12': 'AppSpacing.s3', '16': 'AppSpacing.s4',
            '20': 'AppSpacing.s5', '24': 'AppSpacing.s6',
        }
        if n in mapping:
            changed = True
            return f'EdgeInsets.symmetric(vertical: {mapping[n]})'
        return m.group(0)
    content = re.sub(
        r'EdgeInsets\.symmetric\(vertical:\s*([\d.]+)\)',
        repl_sym_v, content)

    # EdgeInsets.symmetric(horizontal: H, vertical: V)
    def repl_sym_hv(m):
        nonlocal changed
        h = m.group(1).rstrip('0').rstrip('.')
        v = m.group(2).rstrip('0').rstrip('.')
        hmap = {
            '8': 'AppSpacing.s2', '12': 'AppSpacing.s3',
            '16': 'AppSpacing.s4', '20': 'AppSpacing.s5',
            '24': 'AppSpacing.s6', '32': 'AppSpacing.s8',
        }
        vmap = {
            '4': 'AppSpacing.s1', '6': 'AppSpacing.s1',
            '8': 'AppSpacing.s2', '10': 'AppSpacing.s2 + 2',
            '12': 'AppSpacing.s3', '14': 'AppSpacing.s3',
            '16': 'AppSpacing.s4',
        }
        if h in hmap and v in vmap:
            changed = True
            return f'EdgeInsets.symmetric(horizontal: {hmap[h]}, vertical: {vmap[v]})'
        return m.group(0)
    content = re.sub(
        r'EdgeInsets\.symmetric\(horizontal:\s*([\d.]+),\s*vertical:\s*([\d.]+)\)',
        repl_sym_hv, content)

    # EdgeInsets.symmetric(vertical: V, horizontal: H) — reversed
    def repl_sym_vh(m):
        nonlocal changed
        v = m.group(1).rstrip('0').rstrip('.')
        h = m.group(2).rstrip('0').rstrip('.')
        hmap = {
            '8': 'AppSpacing.s2', '12': 'AppSpacing.s3',
            '16': 'AppSpacing.s4', '20': 'AppSpacing.s5',
            '24': 'AppSpacing.s6',
        }
        vmap = {
            '4': 'AppSpacing.s1', '6': 'AppSpacing.s1',
            '8': 'AppSpacing.s2', '12': 'AppSpacing.s3',
            '14': 'AppSpacing.s3', '16': 'AppSpacing.s4',
        }
        if h in hmap and v in vmap:
            changed = True
            return f'EdgeInsets.symmetric(vertical: {vmap[v]}, horizontal: {hmap[h]})'
        return m.group(0)
    content = re.sub(
        r'EdgeInsets\.symmetric\(vertical:\s*([\d.]+),\s*horizontal:\s*([\d.]+)\)',
        repl_sym_vh, content)

    # EdgeInsets.only(...)
    for old, new in ONLY_MAP.items():
        if old in content:
            content = content.replace(old, new)
            changed = True

    # SizedBox remaining (smaller values missed before)
    def repl_sb_h(m):
        nonlocal changed
        n = m.group(1).rstrip('0').rstrip('.')
        mapping = {
            '2': 'AppSpacing.s1', '3': 'AppSpacing.s1',
            '4': 'AppSpacing.s1', '6': 'AppSpacing.s1',
            '48': 'AppSpacing.s12', '56': 'AppSpacing.s12',
            '64': 'AppSpacing.s16', '72': 'AppSpacing.s16',
            '80': 'AppSpacing.s20',
        }
        if n in mapping:
            changed = True
            return f'SizedBox(height: {mapping[n]})'
        return m.group(0)
    content = re.sub(r'SizedBox\(height:\s*([\d.]+)\)', repl_sb_h, content)

    def repl_sb_w(m):
        nonlocal changed
        n = m.group(1).rstrip('0').rstrip('.')
        mapping = {
            '2': 'AppSpacing.s1', '3': 'AppSpacing.s1',
            '4': 'AppSpacing.s1', '6': 'AppSpacing.s1',
            '48': 'AppSpacing.s12', '64': 'AppSpacing.s16',
        }
        if n in mapping:
            changed = True
            return f'SizedBox(width: {mapping[n]})'
        return m.group(0)
    content = re.sub(r'SizedBox\(width:\s*([\d.]+)\)', repl_sb_w, content)

    return content, changed


def process(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    new_content, changed = replace_edgeinsets(content)
    if changed and new_content != content:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True
    return False


def main():
    changed = 0
    for root, dirs, files in os.walk('lib'):
        dirs[:] = [d for d in dirs if d not in ['.dart_tool', 'build']]
        for fname in files:
            if fname in SKIP_FILES or not fname.endswith('.dart'):
                continue
            if process(os.path.join(root, fname)):
                changed += 1
    print(f'Spacing: changed {changed} files')


if __name__ == '__main__':
    main()
