#!/usr/bin/env python3
"""
Flutter final audit — fix remaining:
1. EdgeInsets.all(14) → EdgeInsets.all(AppSpacing.s3 + 2) — 28 instances
2. EdgeInsets.all(10) → EdgeInsets.all(AppSpacing.s2 + 2)
3. EdgeInsets.all(6) → EdgeInsets.all(AppSpacing.s1)
4. EdgeInsets.fromLTRB patterns with hardcoded values
"""
import re
import os

SKIP_FILES = {
    'app_theme.dart', 'app_spacing.dart', 'app_colors.dart',
    'app_gradients.dart', 'app_shadows.dart', 'app_animations.dart',
    'app_radius.dart', 'flutter_final_audit.py',
}

REPLACEMENTS = [
    # EdgeInsets.all with values not covered before
    (r'EdgeInsets\.all\(14\)', 'EdgeInsets.all(AppSpacing.s3 + 2)'),
    (r'EdgeInsets\.all\(10\)', 'EdgeInsets.all(AppSpacing.s2 + 2)'),
    (r'EdgeInsets\.all\(6\)',  'EdgeInsets.all(AppSpacing.s1 + 2)'),
    (r'EdgeInsets\.all\(18\)', 'EdgeInsets.all(AppSpacing.s4 + 2)'),

    # EdgeInsets.symmetric with h+v combinations not covered before
    (r'EdgeInsets\.symmetric\(horizontal:\s*14,\s*vertical:\s*8\)',
     'EdgeInsets.symmetric(horizontal: AppSpacing.s3 + 2, vertical: AppSpacing.s2)'),
    (r'EdgeInsets\.symmetric\(horizontal:\s*10,\s*vertical:\s*4\)',
     'EdgeInsets.symmetric(horizontal: AppSpacing.s2 + 2, vertical: AppSpacing.s1)'),
    (r'EdgeInsets\.symmetric\(horizontal:\s*14,\s*vertical:\s*4\)',
     'EdgeInsets.symmetric(horizontal: AppSpacing.s3 + 2, vertical: AppSpacing.s1)'),
    (r'EdgeInsets\.symmetric\(horizontal:\s*10,\s*vertical:\s*6\)',
     'EdgeInsets.symmetric(horizontal: AppSpacing.s2 + 2, vertical: AppSpacing.s1)'),
    (r'EdgeInsets\.symmetric\(horizontal:\s*10,\s*vertical:\s*8\)',
     'EdgeInsets.symmetric(horizontal: AppSpacing.s2 + 2, vertical: AppSpacing.s2)'),
    (r'EdgeInsets\.symmetric\(horizontal:\s*14\)',
     'EdgeInsets.symmetric(horizontal: AppSpacing.s3 + 2)'),
    (r'EdgeInsets\.symmetric\(horizontal:\s*10\)',
     'EdgeInsets.symmetric(horizontal: AppSpacing.s2 + 2)'),
    (r'EdgeInsets\.symmetric\(horizontal:\s*6\)',
     'EdgeInsets.symmetric(horizontal: AppSpacing.s1 + 2)'),

    # EdgeInsets.only with 14
    ('bottom: AppSpacing.s3 + 2', 'bottom: AppSpacing.s3 + 2'),  # already done
    ('bottom: 14', 'bottom: AppSpacing.s3 + 2'),
    ('top: 14', 'top: AppSpacing.s3 + 2'),
    ('left: 14', 'left: AppSpacing.s3 + 2'),
    ('right: 14', 'right: AppSpacing.s3 + 2'),
    ('bottom: 10', 'bottom: AppSpacing.s2 + 2'),
    ('top: 10', 'top: AppSpacing.s2 + 2'),
    ('left: 10', 'left: AppSpacing.s2 + 2'),
    ('right: 10', 'right: AppSpacing.s2 + 2'),
    ('bottom: 6', 'bottom: AppSpacing.s1 + 2'),
    ('top: 6', 'top: AppSpacing.s1 + 2'),
    ('left: 6', 'left: AppSpacing.s1 + 2'),
    ('right: 6', 'right: AppSpacing.s1 + 2'),

    # SizedBox remaining values
    (r'SizedBox\(height:\s*14\)', 'SizedBox(height: AppSpacing.s3 + 2)'),
    (r'SizedBox\(height:\s*10\)', 'SizedBox(height: AppSpacing.s2 + 2)'),
    (r'SizedBox\(height:\s*18\)', 'SizedBox(height: AppSpacing.s4 + 2)'),
    (r'SizedBox\(height:\s*22\)', 'SizedBox(height: AppSpacing.s5 + 2)'),
    (r'SizedBox\(height:\s*28\)', 'SizedBox(height: AppSpacing.s7)'),
    (r'SizedBox\(width:\s*14\)', 'SizedBox(width: AppSpacing.s3 + 2)'),
    (r'SizedBox\(width:\s*10\)', 'SizedBox(width: AppSpacing.s2 + 2)'),
    (r'SizedBox\(width:\s*18\)', 'SizedBox(width: AppSpacing.s4 + 2)'),
    (r'SizedBox\(width:\s*22\)', 'SizedBox(width: AppSpacing.s5 + 2)'),
    (r'SizedBox\(width:\s*6\)',  'SizedBox(width: AppSpacing.s1 + 2)'),
]

changed = 0
for root, dirs, files in os.walk('lib'):
    dirs[:] = [d for d in dirs if d not in ['.dart_tool', 'build']]
    for fname in files:
        if fname in SKIP_FILES or not fname.endswith('.dart'):
            continue
        path = os.path.join(root, fname)
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
        orig = content

        for pattern, replacement in REPLACEMENTS:
            if '\\(' in pattern:  # regex pattern
                content = re.sub(pattern, replacement, content)
            else:
                content = content.replace(pattern, replacement)

        if content != orig:
            with open(path, 'w', encoding='utf-8') as f:
                f.write(content)
            changed += 1

print(f'Fixed {changed} Flutter files')

# Report remaining
remaining_ei = 0
remaining_sb = 0
for root, dirs, files in os.walk('lib'):
    dirs[:] = [d for d in dirs if d not in ['.dart_tool', 'build']]
    for fname in files:
        if not fname.endswith('.dart') or fname in SKIP_FILES:
            continue
        path = os.path.join(root, fname)
        with open(path, 'r', encoding='utf-8') as f:
            c = f.read()
        import re as re2
        ei = len(re2.findall(r'EdgeInsets\.[a-z]+\([0-9]', c))
        sb = len(re2.findall(r'SizedBox\((?:height|width):\s*[0-9]', c))
        if ei > 0: remaining_ei += ei
        if sb > 0: remaining_sb += sb

print(f'Remaining EdgeInsets hardcoded: {remaining_ei}')
print(f'Remaining SizedBox hardcoded: {remaining_sb}')
