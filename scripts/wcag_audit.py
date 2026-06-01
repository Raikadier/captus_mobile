#!/usr/bin/env python3
"""WCAG 2.1 contrast ratio audit for Captus design system."""

def hex_to_rgb(hex_str):
    h = hex_str.lstrip('#')
    return tuple(int(h[i:i+2], 16)/255 for i in (0,2,4))

def linearize(c):
    return c/12.92 if c <= 0.03928 else ((c+0.055)/1.055)**2.4

def luminance(r, g, b):
    return 0.2126*linearize(r) + 0.7152*linearize(g) + 0.0722*linearize(b)

def contrast(hex1, hex2):
    l1 = luminance(*hex_to_rgb(hex1))
    l2 = luminance(*hex_to_rgb(hex2))
    lighter = max(l1, l2)
    darker = min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)

def wcag(ratio, large=False):
    req = 3.0 if large else 4.5
    aaa = 4.5 if large else 7.0
    if ratio >= aaa: return 'AAA'
    elif ratio >= req: return 'AA'
    else: return 'FAIL'

# Flutter AppColors
COLORS = {
    'background':    '#F8FAFC',  # slate50
    'surface':       '#FFFFFF',  # white
    'surface2':      '#F1F5F9',  # slate100
    'textPrimary':   '#0F172A',  # slate900
    'textSecondary': '#64748B',  # slate500
    'textDisabled':  '#CBD5E1',  # slate300 (disabled — OK to be low)
    'textOnPrimary': '#FFFFFF',  # white
    'primary':       '#1DB954',  # brand500
    'primaryDark':   '#138A3A',  # brand700
    'primaryLight':  '#D1FAE5',  # brand100
    'error':         '#DC2626',  # red-600
    'warning':       '#D97706',  # amber-600
    'info':          '#2563EB',  # blue-600
    'streak':        '#F59E0B',  # amber-500
    'successDark':   '#138A3A',  # using primaryDark as success bg
    'surface3':      '#E2E8F0',  # slate200 (border)
}

COMBOS = [
    # Standard text
    ('textPrimary',   'background',   'Body text on page bg'),
    ('textPrimary',   'surface',      'Body text on card'),
    ('textSecondary', 'background',   'Secondary text on page bg'),
    ('textSecondary', 'surface',      'Secondary text on card'),
    ('textSecondary', 'surface2',     'Secondary text on surface2'),
    ('textDisabled',  'background',   'Disabled text [excluded from WCAG]'),
    # Primary/brand color as text (nav label, links)
    ('primary',       'surface',      'Brand green text on white'),
    ('primary',       'background',   'Brand green text on page bg'),
    ('primary',       'surface2',     'Brand green text on surface2'),
    # White on colored backgrounds (buttons)
    ('textOnPrimary', 'primary',      '** White on primary green button'),
    ('textOnPrimary', 'primaryDark',  'White on dark green'),
    ('textOnPrimary', 'error',        'White on red button'),
    ('textOnPrimary', 'info',         'White on blue button'),
    ('textOnPrimary', 'warning',      '** White on amber'),
    # Semantic colors as text
    ('error',         'surface',      'Error text on white'),
    ('error',         'background',   'Error text on page bg'),
    ('warning',       'surface',      '** Warning amber text on white'),
    ('info',          'surface',      'Info blue text on white'),
    ('streak',        'surface',      '** Streak amber text on white'),
    ('primary',       'primaryLight', 'Brand green on light green bg'),
]

print("WCAG 2.1 Contrast Ratio Audit — Captus Flutter Design System")
print("=" * 72)
header = "{:<30} {:<20} {:>6}  {:>7}  {:>8}".format(
    "Combination", "Colors", "Ratio", "Normal", "Large")
print(header)
print("-" * 72)

fails = []
warns = []
for text_key, bg_key, desc in COMBOS:
    tc = COLORS[text_key]
    bc = COLORS[bg_key]
    r = contrast(tc, bc)
    n = wcag(r, large=False)
    l = wcag(r, large=True)
    colors_str = "{} on {}".format(tc, bc)
    flag = " FAIL" if n == 'FAIL' else ""
    print("{:<30} {:<20} {:>6.2f}  {:>7}  {:>8}{}".format(
        desc, colors_str, r, n, l, flag))
    if n == 'FAIL':
        if '[excluded' not in desc:
            fails.append((desc, r, tc, bc, text_key, bg_key))
    elif n == 'AA' and r < 4.5 and '[excluded' not in desc:
        pass  # AA is fine

print()
print("FAILS (WCAG AA — 4.5:1 for normal, 3:1 for large):")
for desc, r, tc, bc, tk, bk in fails:
    fix = ""
    if tk == 'textOnPrimary' and bk == 'primary':
        fix = " → Use dark text OR darken bg to primaryDark"
    elif tk in ('warning', 'streak') and bk == 'surface':
        fix = " → Use darker shade for text (amber-700: #B45309)"
    print("  {} ({:.2f}:1) {}{}".format(desc, r, fix, ""))

# React CSS vars (approximate hex)
print()
print("=" * 72)
print("WCAG 2.1 — Captus React Design System (CSS custom properties)")
print("=" * 72)

REACT_COLORS = {
    '--background':           '#F8FAFC',  # slate-50
    '--foreground':           '#0F172A',  # slate-900
    '--card':                 '#FFFFFF',
    '--muted':                '#F1F5F9',  # slate-100
    '--muted-foreground':     '#64748B',  # slate-500
    '--primary':              '#1DB954',  # brand-500
    '--primary-foreground':   '#FFFFFF',
    '--secondary':            '#ECFDF5',  # brand-50
    '--secondary-foreground': '#138A3A',  # brand-700
    '--destructive':          '#DC2626',
    '--destructive-foreground': '#FFFFFF',
    '--border':               '#E2E8F0',  # slate-200
    '--brand-700':            '#138A3A',
    '--brand-400':            '#4ade80',  # lighter green
}

REACT_COMBOS = [
    ('--foreground',            '--background',     'Body text on page'),
    ('--foreground',            '--card',            'Body text on card'),
    ('--muted-foreground',      '--background',      'Muted text on page'),
    ('--muted-foreground',      '--card',             'Muted text on card'),
    ('--muted-foreground',      '--muted',            'Muted text on muted bg'),
    ('--primary',               '--card',             'Brand green on white'),
    ('--primary-foreground',    '--primary',          '** White on primary green'),
    ('--secondary-foreground',  '--secondary',        'Dark green on light green'),
    ('--destructive',           '--card',             'Error red on white'),
    ('--destructive-foreground','--destructive',      'White on red button'),
]

print("{:<35} {:>6}  {:>7}  {:>8}".format(
    "Combination", "Ratio", "Normal", "Large"))
print("-" * 60)

react_fails = []
for text_key, bg_key, desc in REACT_COMBOS:
    tc = REACT_COLORS[text_key]
    bc = REACT_COLORS[bg_key]
    r = contrast(tc, bc)
    n = wcag(r, large=False)
    l = wcag(r, large=True)
    flag = " FAIL" if n == 'FAIL' else ""
    print("{:<35} {:>6.2f}  {:>7}  {:>8}{}".format(
        desc, r, n, l, flag))
    if n == 'FAIL':
        react_fails.append((desc, r, tc, bc))

print()
print("React FAILS:")
for desc, r, tc, bc in react_fails:
    print("  {} ({:.2f}:1) {} on {}".format(desc, r, tc, bc))
