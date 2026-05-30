#!/usr/bin/env python3
"""
Robust GoogleFonts migration using a proper parenthesis-aware parser.
Handles nested .withAlpha(...), conditional expressions, etc.
"""
import re
import os

TARGET_FILES = [
    'lib/features/home/screens/home_dashboard_screen.dart',
    'lib/features/statistics/screens/statistics_teacher_screen.dart',
    'lib/features/superadmin/screens/superadmin_institution_detail_screen.dart',
    'lib/features/projects/screens/project_members_screen.dart',
    'lib/features/profile/screens/profile_edit_screen.dart',
]


def extract_full_call(text, start):
    """Extract the full GoogleFonts.inter(...) call starting at 'start' position."""
    # start points to 'G' of GoogleFonts
    # Find the opening paren
    paren_start = text.index('(', start)
    depth = 1
    i = paren_start + 1
    while i < len(text) and depth > 0:
        if text[i] == '(':
            depth += 1
        elif text[i] == ')':
            depth -= 1
        i += 1
    return text[start:i]  # full call including closing )


def parse_args(body):
    """Parse named args from GoogleFonts.inter body, respecting nested parens."""
    args = {}
    i = 0
    while i < len(body):
        # Find next named arg: word:
        m = re.match(r'\s*(\w+):\s*', body[i:])
        if not m:
            i += 1
            continue
        key = m.group(1)
        val_start = i + m.end()

        # Find value end (next comma at depth 0, or end)
        depth = 0
        j = val_start
        while j < len(body):
            c = body[j]
            if c in '([':
                depth += 1
            elif c in ')]':
                if depth == 0:
                    break
                depth -= 1
            elif c == ',' and depth == 0:
                break
            j += 1

        value = body[val_start:j].strip()
        args[key] = value
        i = j
        if i < len(body) and body[i] == ',':
            i += 1

    return args


def get_texttheme_style(args):
    """Map parsed args to a textTheme style reference."""
    size = float(args.get('fontSize', '14').replace(',', ''))
    weight_str = args.get('fontWeight', '')
    is_bold = 'bold' in weight_str or 'w700' in weight_str or 'w800' in weight_str or 'w900' in weight_str
    is_semibold = 'w600' in weight_str or 'w500' in weight_str
    color = args.get('color', '')

    # Select base style
    s = int(size)
    if s >= 22:
        base = 'headlineLarge'  # displaySmall is 30, but use headlineLarge for 22-24px
        if s >= 26:
            base = 'displaySmall'
    elif s == 20:
        base = 'headlineLarge'
    elif s == 18:
        base = 'headlineMedium'
    elif s >= 16:
        base = 'headlineSmall'
    elif s == 15:
        base = 'titleLarge' if (is_bold or is_semibold) else 'bodyLarge'
    elif s == 14:
        base = 'titleMedium' if is_semibold else 'bodyMedium'
    elif s == 13:
        base = 'titleSmall'
    elif s == 12:
        base = 'labelLarge' if is_semibold else 'bodySmall'
    elif s == 11:
        base = 'labelMedium'
    else:
        base = 'labelSmall'

    # Build copyWith args
    copywith_args = {}
    if color and color != 'AppColors.textPrimary':
        if not (color == 'AppColors.textSecondary' and 'Small' in base):
            copywith_args['color'] = color

    for prop in ['letterSpacing', 'height', 'fontStyle']:
        if prop in args:
            copywith_args[prop] = args[prop]

    # If bold/semibold override needed explicitly
    explicit_weight = None
    if is_bold and 'headline' not in base and 'display' not in base and base not in ('titleMedium', 'titleSmall', 'titleLarge'):
        pass  # already encoded in base

    style = f'Theme.of(context).textTheme.{base}'
    if copywith_args:
        cw = ', '.join(f'{k}: {v}' for k, v in copywith_args.items())
        style = f'{style}!.copyWith({cw})'

    return style


def migrate_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'GoogleFonts.' not in content:
        return False

    result = []
    i = 0
    modified = False

    while i < len(content):
        idx = content.find('GoogleFonts.inter(', i)
        if idx == -1:
            result.append(content[i:])
            break

        result.append(content[i:idx])

        # Extract full call
        full_call = extract_full_call(content, idx)
        body = full_call[len('GoogleFonts.inter('):-1]  # without outer parens

        try:
            args = parse_args(body)
            style = get_texttheme_style(args)
            result.append(style)
            modified = True
        except Exception:
            # Fallback: keep original
            result.append(full_call)

        i = idx + len(full_call)

    if modified:
        new_content = ''.join(result)
        # Remove GoogleFonts import
        new_content = re.sub(r"import 'package:google_fonts/google_fonts\.dart';\n", '', new_content)
        # Add spacing import if not present
        if 'app_spacing.dart' not in new_content and 'AppSpacing' in new_content:
            lines = new_content.split('\n')
            last_imp = max((i for i,l in enumerate(lines) if l.strip().startswith('import ')), default=0)
            lines.insert(last_imp + 1, "import '../../../core/constants/app_spacing.dart';")
            new_content = '\n'.join(lines)
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        remaining = new_content.count('GoogleFonts.')
        print(f'OK {path} (remaining: {remaining})')
        return True
    return False


def main():
    changed = 0
    for path in TARGET_FILES:
        if os.path.exists(path):
            if migrate_file(path.replace('/', os.sep)):
                changed += 1
    print(f'\nTotal: {changed} files migrated')


if __name__ == '__main__':
    main()
