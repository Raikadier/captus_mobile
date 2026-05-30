#!/usr/bin/env python3
"""
Design System v2 migration script for captus_mobile.
Applies mechanical transformations to Flutter screens.
"""
import re
import os
import sys

# ── Typography mapping: GoogleFonts.inter → TextTheme ──────────────────────
# Rules ordered from most specific to least specific.
FONT_RULES = [
    # displaySmall: 30/w700 — used for large titles (22-30px bold)
    (r"GoogleFonts\.inter\(\s*fontSize:\s*2[2-9](?:\.\d+)?,\s*fontWeight:\s*FontWeight\.[wb]\d+\s*\)", "tt.displaySmall"),
    (r"GoogleFonts\.inter\(\s*fontWeight:\s*FontWeight\.[wb]\d+,\s*fontSize:\s*2[2-9](?:\.\d+)?\s*\)", "tt.displaySmall"),
    # headlineLarge: 20/w700
    (r"GoogleFonts\.inter\(\s*fontSize:\s*20(?:\.\d+)?,\s*fontWeight:\s*FontWeight\.w?700\s*\)", "tt.headlineLarge"),
    (r"GoogleFonts\.inter\(\s*fontWeight:\s*FontWeight\.w?700,\s*fontSize:\s*20(?:\.\d+)?\s*\)", "tt.headlineLarge"),
    (r"GoogleFonts\.inter\(\s*fontSize:\s*20(?:\.\d+)?,\s*fontWeight:\s*FontWeight\.bold\s*\)", "tt.headlineLarge"),
    # headlineMedium: 18/w600
    (r"GoogleFonts\.inter\(\s*fontSize:\s*18(?:\.\d+)?,\s*fontWeight:\s*FontWeight\.w?[67]\d+\s*\)", "tt.headlineMedium"),
    (r"GoogleFonts\.inter\(\s*fontWeight:\s*FontWeight\.w?[67]\d+,\s*fontSize:\s*18(?:\.\d+)?\s*\)", "tt.headlineMedium"),
    # headlineSmall: 16/w600
    (r"GoogleFonts\.inter\(\s*fontSize:\s*16(?:\.\d+)?,\s*fontWeight:\s*FontWeight\.w?[67]\d+\s*\)", "tt.headlineSmall"),
    (r"GoogleFonts\.inter\(\s*fontWeight:\s*FontWeight\.w?[67]\d+,\s*fontSize:\s*16(?:\.\d+)?\s*\)", "tt.headlineSmall"),
    (r"GoogleFonts\.inter\(\s*fontSize:\s*16(?:\.\d+)?,\s*fontWeight:\s*FontWeight\.bold\s*\)", "tt.headlineSmall"),
    # titleMedium: 14/w500-600
    (r"GoogleFonts\.inter\(\s*fontSize:\s*14(?:\.\d+)?,\s*fontWeight:\s*FontWeight\.w?[56]\d+\s*\)", "tt.titleMedium"),
    (r"GoogleFonts\.inter\(\s*fontWeight:\s*FontWeight\.w?[56]\d+,\s*fontSize:\s*14(?:\.\d+)?\s*\)", "tt.titleMedium"),
    # titleSmall: 13/w500
    (r"GoogleFonts\.inter\(\s*fontSize:\s*13(?:\.\d+)?,\s*fontWeight:\s*FontWeight\.w?[56]\d+\s*\)", "tt.titleSmall"),
    # bodyLarge: 15-16/w400
    (r"GoogleFonts\.inter\(\s*fontSize:\s*1[56](?:\.\d+)?,\s*fontWeight:\s*FontWeight\.w?400\s*\)", "tt.bodyLarge"),
    (r"GoogleFonts\.inter\(\s*fontSize:\s*1[56](?:\.\d+)?,\s*(?:height:\s*[\d.]+,\s*)?\)", "tt.bodyLarge"),
    # bodyMedium: 14/w400
    (r"GoogleFonts\.inter\(\s*fontSize:\s*14(?:\.\d+)?\s*\)", "tt.bodyMedium"),
    (r"GoogleFonts\.inter\(\s*fontSize:\s*14(?:\.\d+)?,\s*fontWeight:\s*FontWeight\.w?400\s*\)", "tt.bodyMedium"),
    # bodySmall: 12-13/w400 with textSecondary
    (r"GoogleFonts\.inter\(\s*fontSize:\s*1[23](?:\.\d+)?,\s*color:\s*AppColors\.textSecondary\s*\)", "tt.bodySmall"),
    (r"GoogleFonts\.inter\(\s*color:\s*AppColors\.textSecondary,\s*fontSize:\s*1[23](?:\.\d+)?\s*\)", "tt.bodySmall"),
    # bodySmall: 12/w400
    (r"GoogleFonts\.inter\(\s*fontSize:\s*12(?:\.\d+)?\s*\)", "tt.bodySmall"),
    (r"GoogleFonts\.inter\(\s*fontSize:\s*12(?:\.\d+)?,\s*fontWeight:\s*FontWeight\.w?400\s*\)", "tt.bodySmall"),
    # labelLarge: 12/w500-600
    (r"GoogleFonts\.inter\(\s*fontSize:\s*12(?:\.\d+)?,\s*fontWeight:\s*FontWeight\.w?[56]\d+\s*\)", "tt.labelLarge"),
    (r"GoogleFonts\.inter\(\s*fontWeight:\s*FontWeight\.w?[56]\d+,\s*fontSize:\s*12(?:\.\d+)?\s*\)", "tt.labelLarge"),
    # labelMedium: 11
    (r"GoogleFonts\.inter\(\s*fontSize:\s*11(?:\.\d+)?.*?\)", "tt.labelMedium"),
    # labelSmall: 10
    (r"GoogleFonts\.inter\(\s*fontSize:\s*10(?:\.\d+)?.*?\)", "tt.labelSmall"),
    # titleSmall: 13/any
    (r"GoogleFonts\.inter\(\s*fontSize:\s*13(?:\.\d+)?\s*\)", "tt.titleSmall"),
    # Generic fallback: bodyMedium
    (r"GoogleFonts\.inter\(\s*\)", "tt.bodyMedium"),
]

# Colored variants: GoogleFonts.inter(fontSize: X, color: Y) → tt.Z.copyWith(color: Y)
COLOR_RULES = [
    # With explicit color specified (non-textSecondary)
    (r"GoogleFonts\.inter\(\s*fontSize:\s*2[2-9](?:\.\d+)?(?:,\s*fontWeight:\s*FontWeight\.\w+)?,\s*color:\s*(AppColors\.\w+)\s*\)",
     r"tt.displaySmall!.copyWith(color: \1)"),
    (r"GoogleFonts\.inter\(\s*fontSize:\s*20(?:\.\d+)?(?:,\s*fontWeight:\s*FontWeight\.\w+)?,\s*color:\s*(AppColors\.\w+)\s*\)",
     r"tt.headlineLarge!.copyWith(color: \1)"),
    (r"GoogleFonts\.inter\(\s*fontSize:\s*18(?:\.\d+)?(?:,\s*fontWeight:\s*FontWeight\.\w+)?,\s*color:\s*(AppColors\.\w+)\s*\)",
     r"tt.headlineMedium!.copyWith(color: \1)"),
    (r"GoogleFonts\.inter\(\s*fontSize:\s*16(?:\.\d+)?(?:,\s*fontWeight:\s*FontWeight\.\w+)?,\s*color:\s*(AppColors\.\w+)\s*\)",
     r"tt.headlineSmall!.copyWith(color: \1)"),
    (r"GoogleFonts\.inter\(\s*fontSize:\s*14(?:\.\d+)?(?:,\s*fontWeight:\s*FontWeight\.\w+)?,\s*color:\s*(AppColors\.\w+)\s*\)",
     r"tt.bodyMedium!.copyWith(color: \1)"),
    (r"GoogleFonts\.inter\(\s*fontSize:\s*13(?:\.\d+)?(?:,\s*fontWeight:\s*FontWeight\.\w+)?,\s*color:\s*(AppColors\.\w+)\s*\)",
     r"tt.bodySmall!.copyWith(color: \1)"),
    (r"GoogleFonts\.inter\(\s*fontSize:\s*12(?:\.\d+)?(?:,\s*fontWeight:\s*FontWeight\.\w+)?,\s*color:\s*(AppColors\.\w+)\s*\)",
     r"tt.labelLarge!.copyWith(color: \1)"),
    (r"GoogleFonts\.inter\(\s*fontSize:\s*11(?:\.\d+)?(?:,\s*fontWeight:\s*FontWeight\.\w+)?,\s*color:\s*(AppColors\.\w+)\s*\)",
     r"tt.labelMedium!.copyWith(color: \1)"),
    # color first, size second
    (r"GoogleFonts\.inter\(\s*color:\s*(AppColors\.\w+),\s*fontSize:\s*2[2-9](?:\.\d+)?(?:,\s*fontWeight:\s*FontWeight\.\w+)?\s*\)",
     r"tt.displaySmall!.copyWith(color: \1)"),
    (r"GoogleFonts\.inter\(\s*color:\s*(AppColors\.\w+),\s*fontSize:\s*18(?:\.\d+)?(?:,\s*fontWeight:\s*FontWeight\.\w+)?\s*\)",
     r"tt.headlineMedium!.copyWith(color: \1)"),
    (r"GoogleFonts\.inter\(\s*color:\s*(AppColors\.\w+),\s*fontSize:\s*16(?:\.\d+)?(?:,\s*fontWeight:\s*FontWeight\.\w+)?\s*\)",
     r"tt.headlineSmall!.copyWith(color: \1)"),
    (r"GoogleFonts\.inter\(\s*color:\s*(AppColors\.\w+),\s*fontSize:\s*14(?:\.\d+)?(?:,\s*fontWeight:\s*FontWeight\.\w+)?\s*\)",
     r"tt.bodyMedium!.copyWith(color: \1)"),
    (r"GoogleFonts\.inter\(\s*color:\s*(AppColors\.\w+),\s*fontSize:\s*1[23](?:\.\d+)?(?:,\s*fontWeight:\s*FontWeight\.\w+)?\s*\)",
     r"tt.bodySmall!.copyWith(color: \1)"),
    (r"GoogleFonts\.inter\(\s*color:\s*(AppColors\.\w+)\s*\)",
     r"tt.bodyMedium!.copyWith(color: \1)"),
    # Just color=textSecondary → bodySmall (already secondary by default)
    (r"GoogleFonts\.inter\(\s*color:\s*AppColors\.textSecondary\s*\)", "tt.bodySmall"),
    # Just color=textPrimary → bodyMedium
    (r"GoogleFonts\.inter\(\s*color:\s*AppColors\.textPrimary\s*\)", "tt.bodyMedium"),
]


def has_tt_variable(content):
    """Check if build method already has 'final tt = Theme.of(context).textTheme'"""
    return 'final tt = Theme.of(context).textTheme' in content


def add_tt_to_builds(content):
    """Add 'final tt = Theme.of(context).textTheme;' to all build methods that need it."""
    if 'GoogleFonts.' not in content:
        return content
    # Only add if not already present AND the file uses tt.
    if has_tt_variable(content):
        return content

    # Add after first 'Widget build(BuildContext context)' or 'Widget build(BuildContext context, WidgetRef ref)'
    pattern = r'(Widget build\(BuildContext context(?:,\s*WidgetRef\s+\w+)?\)\s*\{)'
    replacement = r'\1\n    final tt = Theme.of(context).textTheme;'
    new_content = re.sub(pattern, replacement, content, count=1)

    # If there are multiple build methods in the file, add to each
    if content.count('Widget build(BuildContext context') > 1:
        # Replace all remaining occurrences too (for inline widget classes)
        new_content = re.sub(pattern, replacement, new_content)

    return new_content


def remove_google_fonts_import(content):
    return re.sub(r"import 'package:google_fonts/google_fonts\.dart';\n", '', content)


def add_spacing_import(content, rel_path):
    """Add AppSpacing import if GoogleFonts was present and AppSpacing not imported."""
    if 'app_spacing.dart' in content:
        return content

    # Calculate relative path depth
    depth = rel_path.count('/') - 1  # -1 for lib/
    if 'lib/features/' in rel_path:
        # features/X/screens/*.dart → ../../..
        dirs_up = '../../../'
    elif 'lib/shared/' in rel_path:
        dirs_up = '../../'
    elif 'lib/core/' in rel_path:
        dirs_up = '../../'
    else:
        dirs_up = '../../../'

    import_line = f"import '{dirs_up}core/constants/app_spacing.dart';\n"

    # Insert after the last import line
    lines = content.split('\n')
    last_import_idx = -1
    for i, line in enumerate(lines):
        if line.startswith('import '):
            last_import_idx = i

    if last_import_idx >= 0:
        lines.insert(last_import_idx + 1, import_line.rstrip())
        return '\n'.join(lines)

    return content


def clean_appbar_overrides(content):
    """Remove backgroundColor: AppColors.surface, elevation: 0 from AppBar."""
    # Match common AppBar background/elevation override patterns
    patterns = [
        (r',?\s*backgroundColor:\s*AppColors\.surface,\s*\n\s*elevation:\s*0,', ''),
        (r',?\s*elevation:\s*0,\s*\n\s*backgroundColor:\s*AppColors\.surface,', ''),
        (r'\n\s*backgroundColor:\s*AppColors\.surface,\s*\n\s*elevation:\s*0,', ''),
        (r'\n\s*elevation:\s*0,\s*\n\s*backgroundColor:\s*AppColors\.surface,', ''),
        # Inside SliverAppBar too
        (r',\s*backgroundColor:\s*AppColors\.surface,\s*\n(\s*elevation:\s*0,)', r',\n\1'),
    ]
    for pat, rep in patterns:
        content = re.sub(pat, rep, content)
    return content


def clean_elevated_button_style(content):
    """Remove ElevatedButton.styleFrom that just duplicates the theme."""
    # Match and remove style: ElevatedButton.styleFrom(...) with only theme-default properties
    pattern = r'''style:\s*ElevatedButton\.styleFrom\(\s*
            backgroundColor:\s*AppColors\.primary,\s*
            foregroundColor:\s*AppColors\.textOnPrimary,\s*
            minimumSize:\s*const\s*Size\.fromHeight\([^)]+\),\s*
            shape:\s*RoundedRectangleBorder\([^)]+\),\s*
            elevation:\s*0,\s*
          \),'''
    content = re.sub(pattern, '', content, flags=re.VERBOSE)

    # Also match variant with minimumSize as Size(double.infinity, N)
    pattern2 = r'''style:\s*ElevatedButton\.styleFrom\(\s*
            backgroundColor:\s*AppColors\.primary,\s*
            foregroundColor:\s*AppColors\.textOnPrimary,\s*
            minimumSize:\s*const\s*Size\(double\.infinity,\s*\d+\),\s*
            shape:\s*RoundedRectangleBorder\([^)]+\),\s*
            elevation:\s*0,\s*
          \),'''
    content = re.sub(pattern2, '', content, flags=re.VERBOSE)
    return content


def clean_input_decoration_overrides(content):
    """Remove inline InputDecoration overrides that the theme already handles."""
    remove_props = [
        r'\s*labelStyle:\s*GoogleFonts\.inter\([^)]+\),',
        r'\s*hintStyle:\s*GoogleFonts\.inter\([^)]+\),',
        r'\s*helperStyle:\s*GoogleFonts\.inter\([^)]+\),',
        r'\s*errorStyle:\s*GoogleFonts\.inter\([^)]+\),',
        r'\s*filled:\s*true,',
        r'\s*fillColor:\s*AppColors\.surface,',
        r'\s*contentPadding:\s*const\s*EdgeInsets\.symmetric\([^)]+\),',
        r'\s*border:\s*OutlineInputBorder\([^)]+\),',
        r'\s*enabledBorder:\s*OutlineInputBorder\([^)]+\),',
        r'\s*focusedBorder:\s*OutlineInputBorder\([^)]+\),',
        r'\s*errorBorder:\s*OutlineInputBorder\([^)]+\),',
        r'\s*focusedErrorBorder:\s*OutlineInputBorder\([^)]+\),',
        r'\s*disabledBorder:\s*OutlineInputBorder\([^)]+\),',
    ]
    for pat in remove_props:
        content = re.sub(pat, '', content)
    return content


def replace_spacing(content):
    """Replace raw EdgeInsets with AppSpacing tokens."""
    replacements = [
        # SizedBox heights
        (r'SizedBox\(height:\s*40\)', 'SizedBox(height: AppSpacing.s10)'),
        (r'SizedBox\(height:\s*32\)', 'SizedBox(height: AppSpacing.s8)'),
        (r'SizedBox\(height:\s*24\)', 'SizedBox(height: AppSpacing.s6)'),
        (r'SizedBox\(height:\s*20\)', 'SizedBox(height: AppSpacing.s5)'),
        (r'SizedBox\(height:\s*16\)', 'SizedBox(height: AppSpacing.s4)'),
        (r'SizedBox\(height:\s*12\)', 'SizedBox(height: AppSpacing.s3)'),
        (r'SizedBox\(height:\s*8\)',  'SizedBox(height: AppSpacing.s2)'),
        (r'SizedBox\(height:\s*4\)',  'SizedBox(height: AppSpacing.s1)'),
        # SizedBox widths
        (r'SizedBox\(width:\s*32\)', 'SizedBox(width: AppSpacing.s8)'),
        (r'SizedBox\(width:\s*24\)', 'SizedBox(width: AppSpacing.s6)'),
        (r'SizedBox\(width:\s*16\)', 'SizedBox(width: AppSpacing.s4)'),
        (r'SizedBox\(width:\s*12\)', 'SizedBox(width: AppSpacing.s3)'),
        (r'SizedBox\(width:\s*8\)',  'SizedBox(width: AppSpacing.s2)'),
        (r'SizedBox\(width:\s*4\)',  'SizedBox(width: AppSpacing.s1)'),
        # EdgeInsets.all
        (r'EdgeInsets\.all\(20\)', 'EdgeInsets.all(AppSpacing.s5)'),
        (r'EdgeInsets\.all\(16\)', 'EdgeInsets.all(AppSpacing.s4)'),
        (r'EdgeInsets\.all\(12\)', 'EdgeInsets.all(AppSpacing.s3)'),
        (r'EdgeInsets\.all\(8\)',  'EdgeInsets.all(AppSpacing.s2)'),
        # EdgeInsets.symmetric horizontal
        (r'EdgeInsets\.symmetric\(horizontal:\s*20(?:\.0)?\)', 'EdgeInsets.symmetric(horizontal: AppSpacing.s5)'),
        (r'EdgeInsets\.symmetric\(horizontal:\s*16(?:\.0)?\)', 'EdgeInsets.symmetric(horizontal: AppSpacing.s4)'),
        (r'EdgeInsets\.symmetric\(horizontal:\s*12(?:\.0)?\)', 'EdgeInsets.symmetric(horizontal: AppSpacing.s3)'),
        # EdgeInsets.symmetric vertical
        (r'EdgeInsets\.symmetric\(vertical:\s*16(?:\.0)?\)', 'EdgeInsets.symmetric(vertical: AppSpacing.s4)'),
        (r'EdgeInsets\.symmetric\(vertical:\s*12(?:\.0)?\)', 'EdgeInsets.symmetric(vertical: AppSpacing.s3)'),
        (r'EdgeInsets\.symmetric\(vertical:\s*8(?:\.0)?\)',  'EdgeInsets.symmetric(vertical: AppSpacing.s2)'),
    ]
    for pat, rep in replacements:
        content = re.sub(pat, rep, content)
    return content


def replace_google_fonts(content):
    """Replace GoogleFonts.inter(...) with textTheme equivalents."""
    # First apply color rules (more specific)
    for pattern, replacement in COLOR_RULES:
        content = re.sub(pattern, replacement, content)

    # Then apply size-only rules
    for pattern, replacement in FONT_RULES:
        content = re.sub(pattern, replacement, content)

    return content


def replace_floating_action_button(content):
    """Replace FloatingActionButton with CaptusFab where it uses AppColors.primary."""
    # FAB with add icon
    fab_pattern = r'''FloatingActionButton\(\s*
        onPressed:\s*([^,]+),\s*
        (?:tooltip:\s*'([^']*)',\s*)?
        backgroundColor:\s*AppColors\.primary,\s*
        child:\s*const\s*Icon\(Icons\.add(?:_rounded)?,\s*color:\s*AppColors\.textOnPrimary\),\s*
      \)'''
    def fab_replacement(m):
        on_pressed = m.group(1).strip()
        tooltip = m.group(2) or 'Agregar'
        return f"CaptusFab(\n        onPressed: {on_pressed},\n        icon: Icons.add_rounded,\n        tooltip: '{tooltip}',\n      )"
    content = re.sub(fab_pattern, fab_replacement, content, flags=re.VERBOSE)

    # Check if CaptusFab import is needed
    if 'CaptusFab(' in content and "captus_fab.dart'" not in content:
        # Add import after last import
        lines = content.split('\n')
        last_import = max(i for i, l in enumerate(lines) if l.startswith('import '))
        # Determine correct relative path
        if "lib/features/" in content[:200] or True:
            fab_import = "import '../../../shared/widgets/captus_fab.dart';"
        lines.insert(last_import + 1, fab_import)
        content = '\n'.join(lines)

    return content


def migrate_file(filepath):
    """Migrate a single Dart file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        original = f.read()

    if 'GoogleFonts.' not in original and 'FloatingActionButton(' not in original:
        return False  # Nothing to do

    content = original
    rel_path = filepath.replace('\\', '/')

    # Remove google fonts import
    had_google_fonts = "import 'package:google_fonts/google_fonts.dart';" in content
    content = remove_google_fonts_import(content)

    # Add spacing import if needed
    if had_google_fonts:
        content = add_spacing_import(content, rel_path)

    # Add tt variable to build methods
    content = add_tt_to_builds(content)

    # Clean up AppBar overrides
    content = clean_appbar_overrides(content)

    # Clean up ElevatedButton overrides
    content = clean_elevated_button_style(content)

    # Clean up InputDecoration overrides
    content = clean_input_decoration_overrides(content)

    # Replace spacing
    content = replace_spacing(content)

    # Replace GoogleFonts
    content = replace_google_fonts(content)

    # Replace FloatingActionButton
    content = replace_floating_action_button(content)

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False


def main():
    base_dir = sys.argv[1] if len(sys.argv) > 1 else 'lib'

    changed = []
    skipped = []

    for root, dirs, files in os.walk(base_dir):
        # Skip already-migrated auth and tasks features
        rel_root = root.replace('\\', '/')
        if any(skip in rel_root for skip in ['/auth/', '/tasks/', '/home/']):
            continue

        for fname in files:
            if not fname.endswith('.dart'):
                continue
            filepath = os.path.join(root, fname)
            try:
                if migrate_file(filepath):
                    changed.append(filepath)
                    print(f"  OK {filepath}")
                else:
                    skipped.append(filepath)
            except Exception as e:
                print(f"  ERR ERROR {filepath}: {e}")

    print(f"\nChanged: {len(changed)} files")
    print(f"Skipped: {len(skipped)} files (no changes needed)")


if __name__ == '__main__':
    main()
