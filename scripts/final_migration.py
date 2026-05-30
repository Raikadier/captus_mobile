#!/usr/bin/env python3
"""
Final comprehensive migration - elevate all metrics to 100%.
Handles .0 decimals, remaining SizedBox, Duration, withAlpha.
"""
import re
import os

SKIP_FILES = {
    'app_theme.dart', 'app_radius.dart', 'app_animations.dart',
    'app_colors.dart', 'app_spacing.dart', 'app_shadows.dart',
    'app_gradients.dart', 'final_migration.py', 'deep_migration.py',
    'spacing_migration.py', 'gesture_migration.py', 'robust_gf_migration.py',
    'migrate_design_system.py',
}

# ── Complete BorderRadius mapping (including .0 decimals) ─────────────────
RADIUS_MAP = {
    '0': 'AppRadius.r0', '2': 'AppRadius.r1',
    '3': 'AppRadius.r1', '4': 'AppRadius.r1',
    '6': 'AppRadius.r2', '7': 'AppRadius.r2',
    '8': 'AppRadius.r3',
    '10': 'AppRadius.r4',
    '11': 'AppRadius.r4', '13': 'AppRadius.r4',
    '12': 'AppRadius.r5',
    '14': 'AppRadius.r6',
    '15': 'AppRadius.r6', '16': 'AppRadius.r7',
    '18': 'AppRadius.r7', '20': 'AppRadius.r8',
    '22': 'AppRadius.r8',
    '24': 'AppRadius.r9',
    '26': 'AppRadius.r9', '28': 'AppRadius.r10',
    '30': 'AppRadius.r10',
    '50': 'AppRadius.pill', '80': 'AppRadius.pill',
    '99': 'AppRadius.pill', '100': 'AppRadius.pill',
    '999': 'AppRadius.pill',
}

# ── Complete Duration mapping ──────────────────────────────────────────────
DURATION_MAP = {
    '40': 'AppDurations.instant',
    '80': 'AppDurations.instant',
    '100': 'AppDurations.quick', '120': 'AppDurations.quick',
    '150': 'AppDurations.fast', '180': 'AppDurations.fast',
    '200': 'AppDurations.fast',
    '220': 'AppDurations.standard',
    '240': 'AppDurations.standard', '250': 'AppDurations.standard',
    '260': 'AppDurations.standard',
    '300': 'AppDurations.comfortable', '320': 'AppDurations.comfortable',
    '350': 'AppDurations.comfortable',
    '400': 'AppDurations.slow', '420': 'AppDurations.slow',
    '500': 'AppDurations.slow',
    '600': 'AppDurations.deliberate',
    '800': 'AppDurations.medium',
    '900': 'AppDurations.medium',
    '1200': 'AppDurations.splash',
    '1800': 'AppDurations.splash',
}

# ── Complete Alpha mapping ─────────────────────────────────────────────────
ALPHA_MAP = {
    '8': 'AppAlpha.a04',   # 3% → 4% (closest)
    '10': 'AppAlpha.a04',
    '12': 'AppAlpha.a05',  # 5% (13/255)
    '13': 'AppAlpha.a05',
    '15': 'AppAlpha.a05',
    '18': 'AppAlpha.a08',  # 7% → 8%
    '20': 'AppAlpha.a08',
    '25': 'AppAlpha.a10',
    '26': 'AppAlpha.a10',
    '30': 'AppAlpha.a12',
    '31': 'AppAlpha.a12',
    '35': 'AppAlpha.a15',  # 14% → 15%
    '38': 'AppAlpha.a15',
    '40': 'AppAlpha.a15',
    '50': 'AppAlpha.a20',
    '51': 'AppAlpha.a20',
    '60': 'AppAlpha.a24',
    '61': 'AppAlpha.a24',
    '70': 'AppAlpha.a24',
    '76': 'AppAlpha.a30',
    '77': 'AppAlpha.a30',
    '80': 'AppAlpha.a30',  # 31% → 30% (closest)
    '89': 'AppAlpha.a35',
    '100': 'AppAlpha.a40',
    '102': 'AppAlpha.a40',
    '127': 'AppAlpha.a50',
    '128': 'AppAlpha.a50',
    '130': 'AppAlpha.a50',
    '153': 'AppAlpha.a60',
    '166': 'AppAlpha.a60',
    '178': 'AppAlpha.a70',
    '179': 'AppAlpha.a70',
    '180': 'AppAlpha.a70',
    '191': 'AppAlpha.a70',
    '200': 'AppAlpha.a70',
    '204': 'AppAlpha.a80',
    '210': 'AppAlpha.a80',
    '230': 'AppAlpha.a90',
    '240': 'AppAlpha.a94',
}

# ── Complete SizedBox mapping ──────────────────────────────────────────────
SIZEBOX_H = {
    '0': '0', '2': 'AppSpacing.s1', '3': 'AppSpacing.s1',
    '4': 'AppSpacing.s1', '5': 'AppSpacing.s1', '6': 'AppSpacing.s1',
    '8': 'AppSpacing.s2', '10': 'AppSpacing.s2 + 2',
    '12': 'AppSpacing.s3', '14': 'AppSpacing.s3',
    '16': 'AppSpacing.s4', '18': 'AppSpacing.s4',
    '20': 'AppSpacing.s5', '24': 'AppSpacing.s6',
    '28': 'AppSpacing.s7', '32': 'AppSpacing.s8',
    '40': 'AppSpacing.s10', '48': 'AppSpacing.s12',
    '56': 'AppSpacing.s14', '64': 'AppSpacing.s16',
    '80': 'AppSpacing.s20', '100': 'AppSpacing.s25',
}


def normalize_num(s):
    """'10.0' → '10', '8' → '8'"""
    try:
        return str(int(float(s)))
    except ValueError:
        return s


def process_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    orig = content
    changed_flags = set()

    # 1. BorderRadius.circular(N) and BorderRadius.circular(N.0)
    def repl_br(m):
        n = normalize_num(m.group(1))
        if n in RADIUS_MAP:
            changed_flags.add('radius')
            return f'BorderRadius.circular({RADIUS_MAP[n]})'
        return m.group(0)
    content = re.sub(r'BorderRadius\.circular\(([\d.]+)\)', repl_br, content)

    # 2. Radius.circular(N)
    def repl_r(m):
        n = normalize_num(m.group(1))
        if n in RADIUS_MAP:
            changed_flags.add('radius')
            return f'Radius.circular({RADIUS_MAP[n]})'
        return m.group(0)
    content = re.sub(r'Radius\.circular\(([\d.]+)\)', repl_r, content)

    # 3. Duration(milliseconds: N)
    def repl_dur(m):
        n = m.group(1)
        if n in DURATION_MAP:
            changed_flags.add('duration')
            return DURATION_MAP[n]
        return m.group(0)
    content = re.sub(
        r'(?:const\s+)?Duration\(milliseconds:\s*(\d+)\)',
        repl_dur, content)

    # 4. .withAlpha(N)
    def repl_alpha(m):
        n = m.group(1)
        if n in ALPHA_MAP:
            changed_flags.add('alpha')
            return f'.withAlpha({ALPHA_MAP[n]})'
        return m.group(0)
    content = re.sub(r'\.withAlpha\((\d+)\)', repl_alpha, content)

    # 5. SizedBox(height: N) — comprehensive
    def repl_sb_h(m):
        n = normalize_num(m.group(1))
        if n in SIZEBOX_H:
            val = SIZEBOX_H[n]
            if val == '0':
                return m.group(0)  # keep SizedBox(height: 0) as-is
            changed_flags.add('spacing')
            return f'SizedBox(height: {val})'
        return m.group(0)
    content = re.sub(r'SizedBox\(height:\s*([\d.]+)\)', repl_sb_h, content)

    # SizedBox(width: N)
    def repl_sb_w(m):
        n = normalize_num(m.group(1))
        if n in SIZEBOX_H:
            val = SIZEBOX_H[n]
            if val == '0':
                return m.group(0)
            changed_flags.add('spacing')
            return f'SizedBox(width: {val})'
        return m.group(0)
    content = re.sub(r'SizedBox\(width:\s*([\d.]+)\)', repl_sb_w, content)

    # 6. Add needed imports
    rel = path.replace('\\', '/')
    if 'features/' in rel:
        base = '../../../core/constants/'
    elif 'shared/' in rel:
        base = '../../core/constants/'
    elif 'core/router' in rel or 'core/services' in rel or 'core/providers' in rel:
        base = '../constants/'
    else:
        base = '../constants/'

    def add_import(c, name, anchor='app_colors'):
        imp = f"import '{base}{name}';"
        if name in c:
            return c
        lines = c.split('\n')
        idx = max(
            (i for i, l in enumerate(lines)
             if l.strip().startswith('import ') and anchor in l),
            default=-1)
        if idx < 0:
            idx = max((i for i, l in enumerate(lines)
                       if l.strip().startswith('import ')), default=0)
        lines.insert(idx + 1, imp)
        return '\n'.join(lines)

    if 'radius' in changed_flags and 'app_radius.dart' not in content:
        content = add_import(content, 'app_radius.dart', 'app_spacing')
    if 'duration' in changed_flags and 'app_animations.dart' not in content:
        content = add_import(content, 'app_animations.dart', 'app_colors')
    if 'spacing' in changed_flags and 'app_spacing.dart' not in content:
        content = add_import(content, 'app_spacing.dart', 'app_colors')

    if content != orig:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True, changed_flags
    return False, set()


def main():
    stats = {'radius': 0, 'duration': 0, 'alpha': 0, 'spacing': 0}
    total = 0
    for root, dirs, files in os.walk('lib'):
        dirs[:] = [d for d in dirs if d not in ['.dart_tool', 'build']]
        for fname in files:
            if fname in SKIP_FILES or not fname.endswith('.dart'):
                continue
            changed, flags = process_file(os.path.join(root, fname))
            if changed:
                total += 1
                for f in flags:
                    stats[f] = stats.get(f, 0) + 1
    print(f'Total changed: {total} files')
    for k, v in stats.items():
        print(f'  {k}: {v} files')


if __name__ == '__main__':
    main()
