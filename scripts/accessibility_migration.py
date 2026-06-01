#!/usr/bin/env python3
"""
ISO 25010 Accessibility migration for Flutter.
Adds missing tooltips to IconButtons based on their icon.
"""
import re
import os

SKIP_FILES = {
    'app_theme.dart', 'accessibility_migration.py',
}

# Map icon name patterns → tooltip text (Spanish)
ICON_TOOLTIPS = {
    'arrow_back': 'Volver',
    'close': 'Cerrar',
    'search': 'Buscar',
    'notifications': 'Notificaciones',
    'menu': 'Menú',
    'add': 'Agregar',
    'edit': 'Editar',
    'delete': 'Eliminar',
    'more_vert': 'Más opciones',
    'more_horiz': 'Más opciones',
    'filter': 'Filtrar',
    'sort': 'Ordenar',
    'refresh': 'Actualizar',
    'send': 'Enviar',
    'attach': 'Adjuntar',
    'visibility': 'Ver contraseña',
    'visibility_off': 'Ocultar contraseña',
    'camera': 'Cámara',
    'image': 'Galería',
    'share': 'Compartir',
    'download': 'Descargar',
    'upload': 'Subir',
    'settings': 'Configuración',
    'info': 'Información',
    'help': 'Ayuda',
    'home': 'Inicio',
    'person': 'Perfil',
    'logout': 'Cerrar sesión',
    'check': 'Confirmar',
    'done': 'Listo',
    'copy': 'Copiar',
    'paste': 'Pegar',
    'mic': 'Micrófono',
    'stop': 'Detener',
    'play': 'Reproducir',
    'pause': 'Pausar',
    'star': 'Favorito',
    'bookmark': 'Guardar',
    'category': 'Categorías',
    'calendar': 'Calendario',
    'today': 'Hoy',
    'event': 'Evento',
    'assignment': 'Tarea',
    'grade': 'Calificación',
    'school': 'Curso',
    'group': 'Grupo',
    'person_add': 'Agregar miembro',
    'qr_code': 'Código QR',
    'link': 'Enlace',
    'auto_awesome': 'Captus IA',
}


def find_tooltip_for_icon(icon_str):
    """Given an icon name string like 'Icons.arrow_back_rounded', find tooltip."""
    icon_lower = icon_str.lower()
    for key, tooltip in ICON_TOOLTIPS.items():
        if key in icon_lower:
            return tooltip
    return None


def process_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    orig = content

    # Find IconButton blocks and add tooltip if missing
    # Pattern: IconButton(\n  icon: const Icon(Icons.X),\n  ...no tooltip...\n  onPressed: ...)
    # We need to find these patterns and inject tooltip

    result = []
    i = 0
    changes = 0

    while i < len(content):
        idx = content.find('IconButton(', i)
        if idx == -1:
            result.append(content[i:])
            break

        result.append(content[i:idx])

        # Find the full IconButton block
        start = idx + len('IconButton(')
        depth = 1
        j = start
        while j < len(content) and depth > 0:
            if content[j] == '(':
                depth += 1
            elif content[j] == ')':
                depth -= 1
            j += 1

        block = content[idx:j]

        # Check if tooltip is already present
        if 'tooltip:' not in block:
            # Find icon name
            icon_match = re.search(r'Icons\.(\w+)', block)
            if icon_match:
                icon_name = icon_match.group(1)
                tooltip = find_tooltip_for_icon(icon_name)
                if tooltip:
                    # Insert tooltip after the icon parameter
                    # Find 'icon:' line and add tooltip after its closing comma
                    icon_line_match = re.search(
                        r'(icon:\s*(?:const\s+)?Icon\([^)]+\)\s*,)',
                        block
                    )
                    if icon_line_match:
                        icon_end = icon_line_match.end()
                        # Calculate indentation from the icon line
                        icon_start = icon_line_match.start()
                        lines_before = block[:icon_start].split('\n')
                        last_line = lines_before[-1] if lines_before else ''
                        indent = len(last_line) - len(last_line.lstrip())
                        indent_str = ' ' * indent
                        new_block = (block[:icon_end] +
                                     f'\n{indent_str}tooltip: \'{tooltip}\',' +
                                     block[icon_end:])
                        block = new_block
                        changes += 1

        result.append(block)
        i = j

    new_content = ''.join(result)
    if new_content != orig and changes > 0:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True, changes
    return False, 0


def main():
    total_files = 0
    total_changes = 0
    for root, dirs, files in os.walk('lib'):
        dirs[:] = [d for d in dirs if d not in ['.dart_tool', 'build']]
        for fname in files:
            if not fname.endswith('.dart') or fname in SKIP_FILES:
                continue
            changed, count = process_file(os.path.join(root, fname))
            if changed:
                total_files += 1
                total_changes += count

    print(f'Added {total_changes} tooltips across {total_files} files')


if __name__ == '__main__':
    main()
