# Captus Design System — v1.0
**Single Source of Truth** · Flutter · Material Design 3 · Inter

> Este documento es la referencia definitiva para diseñadores y desarrolladores. Toda decisión visual del proyecto parte de aquí. Los tokens están en `tokens.json` (mismo directorio). El archivo Figma está en: https://www.figma.com/design/otGjpaniX0JYN2zOTr1i9I

---

## Índice

1. [Principios de Diseño](#1-principios-de-diseño)
2. [Capa 1 — Tokens de Color](#2-capa-1--tokens-de-color)
3. [Capa 1 — Tipografía](#3-capa-1--tipografía)
4. [Capa 1 — Espaciado & Grid](#4-capa-1--espaciado--grid)
5. [Capa 2 — Radius & Sombras](#5-capa-2--radius--sombras)
6. [Capa 2 — Animación & Movimiento](#6-capa-2--animación--movimiento)
7. [Capa 2 — Estados de Interacción](#7-capa-2--estados-de-interacción)
8. [Capa 3 — Componentes: Botones](#8-capa-3--componentes-botones)
9. [Capa 3 — Componentes: Inputs](#9-capa-3--componentes-inputs)
10. [Capa 3 — Componentes: Cards](#10-capa-3--componentes-cards)
11. [Capa 3 — Componentes: Navegación](#11-capa-3--componentes-navegación)
12. [Capa 3 — Componentes: Feedback](#12-capa-3--componentes-feedback)
13. [Capa 4 — Patrones UX](#13-capa-4--patrones-ux)
14. [Capa 4 — Accesibilidad](#14-capa-4--accesibilidad)
15. [Arquitectura de Información](#15-arquitectura-de-información)
16. [Apéndice — Código Dart](#16-apéndice--código-dart)

---

## 1. Principios de Diseño

| # | Principio | Descripción |
|---|-----------|-------------|
| 1 | **Verde como energía** | El verde `#1DB954` no es decoración — es acción, progreso y logro. Úsalo solo en CTAs primarios y métricas positivas. |
| 2 | **Oscuro como base** | El fondo `#121212` reduce fatiga visual en sesiones de estudio largas. El contraste se logra con superficie, no con color. |
| 3 | **Jerarquía por peso, no por tamaño** | Diferencia contenido con font-weight antes de cambiar tamaño de fuente. |
| 4 | **Movimiento con propósito** | Cada animación comunica algo: progreso, confirmación, error. Sin animaciones decorativas. |
| 5 | **Tokens primero** | Ningún valor de color, spacing o tipografía va hardcodeado en un widget. Siempre usar token. |
| 6 | **WCAG AA mínimo** | Todo texto normal ≥4.5:1. Texto grande ≥3.0:1. Targets táctiles ≥44dp. |

---

## 2. Capa 1 — Tokens de Color

### Paleta Primitiva (no usar en UI directamente)

| Token | Valor | Uso |
|-------|-------|-----|
| `brand/green-300` | `#55D983` | Hover states, highlights |
| `brand/green-500` | `#1DB954` | **Color primario Captus** |
| `brand/green-700` | `#158A3E` | Pressed state, dark variant |
| `neutral/0`       | `#FFFFFF` | |
| `neutral/900`     | `#121212` | |
| `neutral/800`     | `#1E1E1E` | |
| `neutral/700`     | `#2C2C2C` | |
| `neutral/300`     | `#9E9E9E` | |

### Tokens Semánticos — Light Mode

| Token | Valor Light | Descripción |
|-------|-------------|-------------|
| `bg/default` | `#FFFFFF` | Fondo principal |
| `bg/surface` | `#F5F5F5` | Cards, sheets |
| `bg/surface-variant` | `#EEEEEE` | Inputs, chips |
| `text/primary` | `#121212` | Texto principal |
| `text/secondary` | `#616161` | Texto de soporte |
| `text/disabled` | `#BDBDBD` | No interactivo |
| `text/on-brand` | `#FFFFFF` | Sobre fondo verde |
| `border/default` | `#BDBDBD` | Bordes, dividers |
| `state/error` | `#CF6679` | Errores |
| `state/warning` | `#FF9800` | Advertencias |
| `state/success` | `#1B5E20` | Éxito |
| `state/info` | `#0277BD` | Información |

### Tokens Semánticos — Dark Mode (modo actual de Captus)

| Token | Valor Dark | Descripción |
|-------|------------|-------------|
| `bg/default` | `#121212` | Fondo principal |
| `bg/surface` | `#1E1E1E` | Cards, sheets |
| `bg/surface-variant` | `#2C2C2C` | Inputs, chips |
| `text/primary` | `#FFFFFF` | Texto principal |
| `text/secondary` | `#9E9E9E` | Texto de soporte |
| `text/disabled` | `#616161` | No interactivo |
| `border/default` | `#3D3D3D` | Bordes, dividers |
| `state/error` | `#EF9A9A` | Errores (más suave en dark) |
| `state/warning` | `#FFCC80` | Advertencias |
| `state/success` | `#A5D6A7` | Éxito |
| `state/info` | `#81D4FA` | Información |

### ⚠️ WCAG — Tabla de Contraste Crítica

| Combinación | Ratio | WCAG | Mínimo requerido |
|-------------|-------|------|-----------------|
| `text/primary` sobre `bg/default` (dark) | **21:1** | ✅ AAA | 4.5:1 |
| `text/secondary` sobre `bg/default` (dark) | **3.9:1** | ✅ AA | 3.0:1 (large) |
| `brand/green-500` sobre `bg/default` (dark) | **3.0:1** | ⚠️ | Válido **solo** para texto ≥18sp o bold ≥14sp |
| `brand/green-500` sobre `bg/default` (light) | **3.0:1** | ⚠️ | Igual — no usar como texto pequeño sobre blanco |
| `text/on-brand` (#FFF) sobre `brand/green-500` | **3.0:1** | ⚠️ | Solo para botones con texto ≥14sp bold |
| `state/error` (dark) sobre `bg/surface` | **4.6:1** | ✅ AA | 4.5:1 |

> **Regla de oro:** el verde `#1DB954` NUNCA va como texto pequeño normal. Solo en botones grandes, iconos, y métricas numéricas grandes (≥24sp).

---

## 3. Capa 1 — Tipografía

**Fuente:** Inter via `google_fonts` package.
**Escala:** Material Type Scale adaptada.

| Estilo | Tamaño | Peso | Line Height | Letter Spacing | Uso |
|--------|--------|------|-------------|----------------|-----|
| `Display/Large` | 57sp | Regular (400) | 64px | -0.25% | Nunca en móvil |
| `Display/Medium` | 45sp | Regular | 52px | 0 | Splash / onboarding hero |
| `Display/Small` | 36sp | Regular | 44px | 0 | Número grande de stat |
| `Headline/Large` | 32sp | Semi Bold (600) | 40px | 0 | Títulos de sección principal |
| `Headline/Medium` | 28sp | Semi Bold | 36px | 0 | AppBar title en modo expanded |
| `Headline/Small` | 24sp | Semi Bold | 32px | 0 | Título de card hero |
| `Title/Large` | 22sp | Medium (500) | 28px | 0 | Título de pantalla |
| `Title/Medium` | 16sp | Medium | 24px | +0.15% | Título de sección, ListTile |
| `Title/Small` | 14sp | Medium | 20px | +0.1% | Subtítulo, chip label |
| `Body/Large` | 16sp | Regular | 24px | +0.5% | Texto de lectura principal |
| `Body/Medium` | 14sp | Regular | 20px | +0.25% | Descripción, body secundario |
| `Body/Small` | 12sp | Regular | 16px | +0.4% | Metadata, timestamps |
| `Label/Large` | 14sp | Medium | 20px | +0.1% | Botón, tab label |
| `Label/Medium` | 12sp | Medium | 16px | +0.5% | Badge, chip |
| `Label/Small` | 11sp | Medium | 16px | +0.5% | Overline de card |
| `Utility/Button` | 14sp | Semi Bold | 20px | +1.25% | Texto de botones |
| `Utility/Caption` | 12sp | Regular | 16px | +0.4% | Captions bajo imágenes |
| `Utility/Overline` | 10sp | Medium | 16px | +1.5% | Etiqueta de sección en caps |

### Reglas de uso tipográfico

- **Nunca más de 3 tamaños diferentes** en una misma pantalla.
- **Jerarquía:** diferenciar con peso antes que tamaño. Un `Title/Medium` bold y un `Body/Medium` regular crean jerarquía sin aumentar tamaño.
- **Línea máxima:** 70 caracteres en `Body/Large` (legibilidad óptima). Usar `maxLines` + `overflow: TextOverflow.ellipsis`.
- **Texto en mayúsculas:** solo `Utility/Overline`. Nunca transformar otros estilos a uppercase.

---

## 4. Capa 1 — Espaciado & Grid

### Escala de Espaciado (base 4dp)

| Token | Valor | Uso típico |
|-------|-------|-----------|
| `spacing/2` | 2dp | Separación mínima interna |
| `spacing/4` | 4dp | Gap entre icono y texto |
| `spacing/8` | 8dp | Padding interno de chip, gap de fila |
| `spacing/12` | 12dp | Gap de columna, padding de badge |
| `spacing/16` | 16dp | Padding estándar de contenedor |
| `spacing/20` | 20dp | Margen horizontal de página |
| `spacing/24` | 24dp | Gap entre secciones |
| `spacing/32` | 32dp | Espaciado entre grupos |
| `spacing/40` | 40dp | Separación de bloques mayores |
| `spacing/48` | 48dp | AppBar height base |
| `spacing/56` | 56dp | FAB size, BottomNav height base |
| `spacing/64` | 64dp | Hero image height mínimo |
| `spacing/80` | 80dp | Separaciones grandes |

### Padding de Página

| Token | Valor | Uso |
|-------|-------|-----|
| `padding/page` | 20dp | Margen horizontal estándar en todas las pantallas |
| `padding/md` | 16dp | Padding interno de cards |
| `padding/sm` | 8dp | Padding de elementos compactos |

### Grid System

| Breakpoint | Columnas | Gutter | Margin | Ancho |
|------------|----------|--------|--------|-------|
| Mobile (xs) | 4 | 16dp | 20dp | 0dp+ |
| Tablet (sm) | 8 | 24dp | 32dp | 600dp+ |
| Desktop (md) | 12 | 32dp | 64dp | 900dp+ |

---

## 5. Capa 2 — Radius & Sombras

### Border Radius

| Token | Valor | Uso |
|-------|-------|-----|
| `radius/none` | 0dp | Dividers, separadores |
| `radius/xs` | 4dp | Chips, badges, tags pequeños |
| `radius/sm` | 8dp | Inputs, botones secundarios pequeños |
| `radius/md` | 12dp | Cards estándar, botones principales |
| `radius/lg` | 14dp | Cards grandes, bottom sheets |
| `radius/xl` | 16dp | Dialogs, modales |
| `radius/xxl` | 20dp | Hero cards, featured content |
| `radius/full` | 999dp | Pills, FAB, avatares, toggle |

### Sistema de Sombras (Elevación)

| Nivel | Token | CSS Shadow | Uso |
|-------|-------|-----------|-----|
| 0 | `shadow/flat` | none | Superficie base, sin elevación |
| 1 | `shadow/low` | `0 1px 3px rgba(0,0,0,.12), 0 1px 2px rgba(0,0,0,.24)` | Cards en reposo |
| 2 | `shadow/medium` | `0 3px 6px rgba(0,0,0,.15), 0 2px 4px rgba(0,0,0,.12)` | FAB, BottomNav |
| 3 | `shadow/high` | `0 10px 20px rgba(0,0,0,.15), 0 3px 6px rgba(0,0,0,.10)` | Modales, Drawers |
| 4 | `shadow/overlay` | `0 19px 38px rgba(0,0,0,.30), 0 15px 12px rgba(0,0,0,.22)` | Full-screen overlays |

> **Dark mode:** Las sombras son menos visibles sobre fondos oscuros. Complementar elevación con diferencia de color de superficie (`bg/surface` vs `bg/elevated`).

---

## 6. Capa 2 — Animación & Movimiento

**Package recomendado:** `flutter_animate` (fluent API, stagger nativo).

### Duraciones

| Token | Valor | Uso |
|-------|-------|-----|
| `motion/instant` | 80ms | Ripple, checkbox tick, icon swap instantáneo |
| `motion/fast` | 150ms | Tooltips, hover feedback, badge appear |
| `motion/standard` | 250ms | Transición de modal, page push estándar |
| `motion/enter` | 350ms | Animaciones elaboradas de entrada |
| `motion/exit` | 200ms | Salida siempre más rápida que entrada |
| `motion/long` | 500ms | Secuencias complejas, confetti, celebration |

### Curvas de Easing

| Token | Curva Bezier | Uso |
|-------|-------------|-----|
| `motion/easing/standard` | `(0.2, 0.0, 0.0, 1.0)` | Default — la mayoría de transiciones |
| `motion/easing/decelerate` | `(0.0, 0.0, 0.2, 1.0)` | Elementos que entran a la pantalla |
| `motion/easing/accelerate` | `(0.3, 0.0, 1.0, 1.0)` | Elementos que salen de la pantalla |
| `motion/easing/spring` | `(0.34, 1.56, 0.64, 1.0)` | Success states, FAB, celebración |
| `motion/easing/linear` | `(0.0, 0.0, 1.0, 1.0)` | Progress bars, shimmer |

### Stagger (animaciones de lista)

| Token | Valor | Uso |
|-------|-------|-----|
| `motion/stagger/list-item` | 40ms | Delay entre cada item de lista en entrada |
| `motion/stagger/card` | 60ms | Delay entre cards en grid |

### Patrones de Animación

```dart
// Entrada de pantalla — fade + slide estándar
widget.animate()
  .fadeIn(duration: 250.ms, curve: Curves.easeOut)
  .slideY(begin: 0.04, end: 0, duration: 250.ms);

// Lista con stagger
ListView.builder(
  itemBuilder: (ctx, i) => item
    .animate(delay: (40 * i).ms)
    .fadeIn(duration: 200.ms)
    .slideX(begin: 0.03),
);

// Success celebration (spring)
icon.animate()
  .scale(begin: const Offset(0.5, 0.5), duration: 350.ms,
         curve: Curves.elasticOut);

// Shimmer loading (siempre linear)
Shimmer.fromColors(
  baseColor: AppColors.surfaceVariant,
  highlightColor: AppColors.surface,
  child: skeletonWidget,
);
```

---

## 7. Capa 2 — Estados de Interacción

Todo componente interactivo **debe** implementar los 8 estados:

| Estado | Descripción | Visual |
|--------|-------------|--------|
| **Default** | Reposo | Estilo base del componente |
| **Hover** | Cursor encima (tablet/web) | Overlay `brand/primary` al 8% |
| **Focus** | Foco de teclado / accesibilidad | Border `border/brand` 2dp + outline 2dp offset |
| **Active / Pressed** | Toque activo | Overlay `brand/primary` al 16% + scale 0.97 |
| **Disabled** | No interactivo | Opacity 0.38, sin hover/focus |
| **Loading** | Operación en curso | Spinner o skeleton según contexto |
| **Error** | Validación fallida | Color `state/error`, shake animation 4dp |
| **Success** | Operación completada | Color `state/success`, spring scale in |

### Overlay de estado (Material ripple equivalente)

```dart
// Usar InkWell con borderRadius correcto, NO GestureDetector
InkWell(
  borderRadius: BorderRadius.circular(AppRadius.md),
  onTap: onTap,
  child: child,
)

// Para elementos que necesitan splash personalizado
Material(
  color: Colors.transparent,
  child: InkWell(
    splashColor: AppColors.primary.withAlpha(40),
    highlightColor: AppColors.primary.withAlpha(20),
    ...
  ),
)
```

---

## 8. Capa 3 — Componentes: Botones

### Variantes

| Variante | Uso | Fondo | Texto | Borde |
|----------|-----|-------|-------|-------|
| **Primary** | Acción principal de pantalla | `brand/primary` | `text/on-brand` | Ninguno |
| **Secondary** | Acción secundaria | `bg/surface-variant` | `text/primary` | Ninguno |
| **Outlined** | Acción alternativa de igual peso | Transparente | `brand/primary` | `border/brand` 1.5dp |
| **Ghost / Text** | Acción terciaria, links | Transparente | `brand/primary` | Ninguno |
| **Destructive** | Acciones irreversibles (eliminar) | `state/error` | `#FFFFFF` | Ninguno |

### Tamaños

| Tamaño | Alto | Padding H | Fuente | Uso |
|--------|------|-----------|--------|-----|
| `sm` | 36dp | 16dp | `Label/Large` | Botones en listas, chips de acción |
| `md` | 48dp | 24dp | `Utility/Button` | **Default** — la mayoría de CTAs |
| `lg` | 56dp | 32dp | `Utility/Button` | Hero CTA, pantallas de onboarding |

### Estados de botón

```dart
// Primary button completo con todos los estados
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textOnPrimary, // SIEMPRE blanco, no negro
    minimumSize: const Size.fromHeight(48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md), // 12dp
    ),
    textStyle: AppTextStyles.button,
    elevation: 0,
    shadowColor: Colors.transparent,
  ).copyWith(
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) return Colors.white.withAlpha(40);
      if (states.contains(WidgetState.hovered)) return Colors.white.withAlpha(20);
      return null;
    }),
  ),
  onPressed: isLoading ? null : onPressed,
  child: isLoading
    ? const SizedBox(width: 20, height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
    : Text(label),
)
```

### Reglas

- ❌ Nunca usar `Colors.black` como `foregroundColor` en un botón verde.
- ❌ Nunca mezclar dos botones Primary en la misma pantalla.
- ✅ Primary + Outlined = par correcto para pantallas con dos CTAs.
- ✅ El estado loading desactiva el botón (`onPressed: null`) y muestra spinner interno.

---

## 9. Capa 3 — Componentes: Inputs

### Variantes de TextField

| Estado | Border | Background | Label | Icono |
|--------|--------|-----------|-------|-------|
| Default | `border/default` 1dp | `bg/surface-variant` | `text/hint` | `text/secondary` |
| Focus | `border/brand` 2dp | `bg/surface-variant` | `brand/primary` | `brand/primary` |
| Filled (con valor) | `border/default` 1dp | `bg/surface-variant` | flotando arriba | normal |
| Error | `state/error` 2dp | `bg/surface-variant` | `state/error` | error icon |
| Disabled | `border/default` 0.5dp | `bg/surface-variant` opacity 0.38 | `text/disabled` | — |
| Success | `state/success` 2dp | `bg/surface-variant` | `state/success` | check icon |

### Animación de error (shake)

```dart
// Shake horizontal 4dp × 3 cuando validación falla
fieldKey.currentState?.shake(); // usando flutter_animate

// Implementación:
TextField(...).animate(target: hasError ? 1 : 0)
  .shake(duration: 300.ms, hz: 3, offset: const Offset(4, 0));
```

### Especificaciones

```dart
InputDecoration(
  filled: true,
  fillColor: AppColors.surfaceVariant,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.sm), // 8dp
    borderSide: BorderSide(color: AppColors.border, width: 1),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.sm),
    borderSide: BorderSide(color: AppColors.primary, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.sm),
    borderSide: BorderSide(color: AppColors.error, width: 2),
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
)
```

---

## 10. Capa 3 — Componentes: Cards

### Tipos de Card

| Tipo | Radio | Sombra | Uso |
|------|-------|--------|-----|
| **Flat** | `radius/md` (12dp) | `shadow/flat` | Listas densas, dentro de contenedores |
| **Elevated** | `radius/md` (12dp) | `shadow/low` | Cards de contenido estándar |
| **Hero** | `radius/xxl` (20dp) | `shadow/medium` | Card destacada, top de sección |
| **Compact** | `radius/sm` (8dp) | `shadow/flat` | Lista de tareas, items de actividad |
| **Outline** | `radius/md` (12dp) | ninguna | Selectable cards, opciones |

### Anatomía de Card Estándar

```
┌─────────────────────────────────┐  ← radius/md
│  [Icon/Image]                   │  ← Padding: 16dp
│                                 │
│  Title/Medium ─────────────     │  ← text/primary
│  Body/Small ─────────────────   │  ← text/secondary
│                                 │
│  [Chip]  [Chip]     [CTA ───>]  │  ← Label/Medium
└─────────────────────────────────┘
          padding: 16dp all sides
```

### Reglas de Card

- ✅ Usar `InkWell` dentro del `Card` para ripple correcto.
- ✅ `clipBehavior: Clip.antiAlias` siempre que haya imagen en el card.
- ❌ Nunca anidar cards (card dentro de card).
- ❌ Nunca más de 3 acciones en un card.

---

## 11. Capa 3 — Componentes: Navegación

### Bottom Navigation Bar

| Propiedad | Valor |
|-----------|-------|
| Height | 64dp + safe area |
| Background | `bg/surface` |
| Shadow | `shadow/medium` en top |
| Items | 4–5 máximo |
| Active icon | `brand/primary` |
| Active label | `brand/primary`, `Label/Medium` |
| Inactive icon | `text/secondary` |
| Inactive label | `text/secondary`, `Label/Medium` |
| Active indicator | `brand/primary` 10% opacity, `radius/full` |

### Estructura propuesta (IA Captus)

| Tab | Ícono | Contenido |
|-----|-------|-----------|
| 🏠 Inicio | `home_rounded` | Dashboard, actividad reciente |
| 📚 Cursos | `menu_book_rounded` | Listado, filtros, progreso |
| ✅ Tareas | `task_alt_rounded` | Lista agrupada, filtros |
| 👤 Yo | `person_rounded` | Perfil + Estadísticas + Logros |

> **Cambio propuesto:** reemplazar "Grupos/Más" por "Yo" — hub personal que unifica Perfil, Estadísticas, Grupos y Logros.

### AppBar — 4 variantes

| Variante | Alto | Cuándo usar |
|----------|------|------------|
| **Compact** | 56dp | Pantallas estándar con título y 1-2 acciones |
| **Medium** | 112dp | Pantallas con título largo que necesita espacio |
| **Large** | 152dp | Hero sections, pantalla de inicio |
| **Transparent** | 56dp | Sobre imágenes/contenido multimedia |

```dart
// AppBar correcta — background siempre AppColors.surface, no background
AppBar(
  backgroundColor: AppColors.surface,   // ✅ surface
  // backgroundColor: AppColors.background, // ❌ incorrecto
  foregroundColor: AppColors.textPrimary,
  elevation: 0,
  scrolledUnderElevation: 2,
  surfaceTintColor: Colors.transparent,
)
```

---

## 12. Capa 3 — Componentes: Feedback

### Toast / Snackbar

| Tipo | Color de fondo | Ícono | Duración |
|------|---------------|-------|----------|
| Info | `neutral/700` | `info_rounded` | 3s |
| Success | `state/success` (dark: `#1B5E20`) | `check_circle_rounded` | 2s |
| Warning | `state/warning` | `warning_rounded` | 4s |
| Error | `state/error` | `error_rounded` | persist hasta dismiss |

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(children: [
      Icon(icon, color: Colors.white, size: 20),
      const SizedBox(width: 8),
      Text(message, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
    ]),
    backgroundColor: bgColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
    margin: const EdgeInsets.all(16),
    duration: duration,
  ),
);
```

### Loading: Skeleton vs Spinner

```
¿El layout es conocido? ──Yes──> Skeleton Loader
         │
        No
         │
¿Duración < 2s? ──Yes──> Spinner circular pequeño (20dp)
         │
        No
         │
¿Toda la pantalla espera? ──Yes──> Skeleton de pantalla completa
         │
        No
         ╰──> Shimmer en el área específica
```

### Empty States

Toda pantalla vacía **debe** tener: ilustración/ícono + título + descripción + CTA.

```dart
// Estructura de empty state
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(Icons.inbox_rounded, size: 64, color: AppColors.textSecondary),
    const SizedBox(height: AppSpacing.s16),
    Text('No hay tareas', style: AppTextStyles.titleMedium),
    const SizedBox(height: AppSpacing.s8),
    Text('Crea tu primera tarea para comenzar',
         style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
         textAlign: TextAlign.center),
    const SizedBox(height: AppSpacing.s24),
    CaptusButton.primary(label: 'Crear tarea', onPressed: onCreate),
  ],
)
```

---

## 13. Capa 4 — Patrones UX

### Transiciones entre pantallas

| Transición | Cuándo usar | Package |
|------------|------------|---------|
| **Slide horizontal** | Navegación push/pop estándar | Navigator 2.0 |
| **Fade** | Cambio de tab en BottomNav | AnimatedSwitcher |
| **Hero** | Detalle de card → pantalla full | Hero widget |
| **SharedAxis Z** | Login → Home, modales | `animations` package |
| **SharedAxis X** | Onboarding steps | `animations` package |
| **Container Transform** | Card → detalle expandido | `animations` package |

### Formularios — Flujo de validación

1. **No validar on-type** — demasiado agresivo. Validar `onFocusLost` o `onSubmit`.
2. **Mensaje de error debajo del campo** — `errorText` en `InputDecoration`.
3. **Shake animation** al submit con errores (ver §9).
4. **Scroll automático** al primer campo con error: `Scrollable.ensureVisible(fieldKey.currentContext!)`.
5. **Botón de submit:** desactivado mientras loading, nunca mientras hay errores visibles.

### Gestión de estados de pantalla

```
Toda pantalla debe manejar:
├── Loading (inicial)     → Skeleton
├── Error (sin datos)     → Empty state de error + retry CTA
├── Empty (sin contenido) → Empty state + CTA de creación
└── Content               → El contenido real
```

```dart
// Patrón recomendado
return switch(state) {
  LoadingState() => const ScreenSkeleton(),
  ErrorState()   => ErrorView(onRetry: viewModel.load),
  EmptyState()   => EmptyView(onAction: viewModel.create),
  ContentState() => ContentView(data: state.data),
};
```

---

## 14. Capa 4 — Accesibilidad

### Targets Táctiles

| Estándar | Mínimo | Recomendado |
|----------|--------|-------------|
| WCAG 2.5.5 | 44×44dp | 48×48dp |
| Material M3 | 48×48dp | 56×56dp |

```dart
// Envolver elementos pequeños con área táctil mínima
IconButton(
  padding: const EdgeInsets.all(12), // mínimo para llegar a 44dp
  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
  onPressed: onPressed,
  icon: Icon(icon, size: 20),
)
```

### Semántica para Screen Reader

```dart
Semantics(
  label: 'Tarea: Matemáticas. Vence en 2 días. Pendiente.',
  button: false,
  child: taskCard,
)
```

### Checklist de accesibilidad por pantalla

- [ ] Todo texto visible tiene `Semantics` o es detectado automáticamente.
- [ ] Botones y elementos interactivos tienen `tooltip` o `semanticLabel`.
- [ ] Imágenes decorativas tienen `excludeFromSemantics: true`.
- [ ] Contraste verificado con la tabla de §2.
- [ ] Navegación completa posible con teclado externo (tablet).
- [ ] `TextScaleFactor` probado a 1.5x — sin overflow.
- [ ] Targets táctiles ≥44dp.

---

## 15. Arquitectura de Información

### Mapa de navegación actual vs propuesto

**Actual:** Inicio / Cursos / Tareas / IA / Grupos+Más (5 tabs)
**Propuesto:** Inicio / Cursos / Tareas / Yo (4 tabs)

El hub "Yo" consolida:
- Perfil de usuario
- Estadísticas y progreso
- Logros y racha
- Grupos / comunidades
- Configuración

### Jerarquía máxima de navegación

```
L1: Bottom Nav (4 tabs)
└── L2: Pantalla principal de cada tab
    └── L3: Detalle (push) — máx. 1 nivel de profundidad
```

> Nunca más de 3 niveles de profundidad. Si una acción requiere L4, convertir en modal/bottom sheet.

### IA Assistant — mejora propuesta

El asistente de IA debe vivir como **acción flotante persistente** (FAB extendido) en Inicio y Tareas, no como tab dedicado. Esto libera el slot de navegación y hace el asistente más contextual.

---

## 16. Apéndice — Código Dart

### AppColors (completo, corregido)

```dart
import 'package:flutter/material.dart';

/// Tokens de color de Captus Design System v1.0
/// Última actualización: 2025
abstract class AppColors {
  // ─── PRIMITIVOS (uso interno del sistema) ───────────────────────────────
  static const _green300 = Color(0xFF55D983);
  static const _green500 = Color(0xFF1DB954);
  static const _green700 = Color(0xFF158A3E);

  // ─── BRAND ──────────────────────────────────────────────────────────────
  static const primary      = _green500;
  static const primaryDark  = _green700;
  static const primaryLight = _green300;

  // ─── FONDOS (Dark mode — modo actual de Captus) ─────────────────────────
  static const background      = Color(0xFF121212); // bg/default
  static const surface         = Color(0xFF1E1E1E); // bg/surface
  static const surfaceVariant  = Color(0xFF2C2C2C); // bg/surface-variant
  static const elevated        = Color(0xFF2C2C2C); // bg/elevated
  static const overlay         = Color(0xFF000000); // bg/overlay

  // ─── TEXTO ──────────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFFFFFFF); // text/primary (dark)
  static const textSecondary = Color(0xFF9E9E9E); // text/secondary (dark)
  static const textDisabled  = Color(0xFF616161); // text/disabled (dark)
  static const textOnPrimary = Color(0xFFFFFFFF); // text/on-brand — SIEMPRE BLANCO
  static const textHint      = Color(0xFF616161); // text/hint (dark)

  // ─── BORDES ─────────────────────────────────────────────────────────────
  static const border        = Color(0xFF3D3D3D); // border/default (dark)
  static const borderStrong  = Color(0xFF757575); // border/strong
  static const borderBrand   = _green500;         // border/brand

  // ─── ESTADOS (dark mode) ────────────────────────────────────────────────
  static const error   = Color(0xFFEF9A9A); // state/error (dark)
  static const warning = Color(0xFFFFCC80); // state/warning (dark)
  static const success = Color(0xFFA5D6A7); // state/success (dark) — DIFERENTE de primary
  static const info    = Color(0xFF81D4FA); // state/info (dark)

  // ─── ACENTOS ────────────────────────────────────────────────────────────
  static const accentPurple = Color(0xFFCE93D8); // accent/purple (dark)
  static const accentAmber  = Color(0xFFFFD54F);  // accent/amber (dark)
}
```

### AppSpacing

```dart
abstract class AppSpacing {
  static const double s2   = 2;
  static const double s4   = 4;
  static const double s8   = 8;
  static const double s12  = 12;
  static const double s16  = 16;
  static const double s20  = 20;
  static const double s24  = 24;
  static const double s32  = 32;
  static const double s40  = 40;
  static const double s48  = 48;
  static const double s56  = 56;
  static const double s64  = 64;
  static const double s80  = 80;
  static const double s96  = 96;
  static const double s120 = 120;

  // Semánticos
  static const double pagePadding = s20;
  static const double cardPadding = s16;
  static const double sectionGap  = s24;
}
```

### AppRadius

```dart
abstract class AppRadius {
  static const double none = 0;
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 14;
  static const double xl   = 16;
  static const double xxl  = 20;
  static const double full = 999;

  static BorderRadius get xsAll   => BorderRadius.circular(xs);
  static BorderRadius get smAll   => BorderRadius.circular(sm);
  static BorderRadius get mdAll   => BorderRadius.circular(md);
  static BorderRadius get lgAll   => BorderRadius.circular(lg);
  static BorderRadius get xlAll   => BorderRadius.circular(xl);
  static BorderRadius get xxlAll  => BorderRadius.circular(xxl);
  static BorderRadius get fullAll => BorderRadius.circular(full);
}
```

### AppMotion

```dart
abstract class AppMotion {
  // Duraciones
  static const Duration instant  = Duration(milliseconds: 80);
  static const Duration fast     = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration enter    = Duration(milliseconds: 350);
  static const Duration exit     = Duration(milliseconds: 200);
  static const Duration long     = Duration(milliseconds: 500);

  // Stagger
  static const Duration staggerItem = Duration(milliseconds: 40);
  static const Duration staggerCard = Duration(milliseconds: 60);

  // Curvas
  static const Curve standard_  = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve decelerate = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Curve accelerate = Cubic(0.3, 0.0, 1.0, 1.0);
  static const Curve spring     = Cubic(0.34, 1.56, 0.64, 1.0);
}
```

### Bugs conocidos a corregir

| Archivo | Bug | Fix |
|---------|-----|-----|
| `login_screen.dart` | `foregroundColor: Colors.black` en ElevatedButton | → `AppColors.textOnPrimary` |
| `courses_list_screen.dart` | `AppBar(backgroundColor: AppColors.background)` | → `AppColors.surface` |
| `courses_list_screen.dart` | FAB `Colors.black` icon | → `Colors.white` |
| `courses_list_screen.dart` | `.withOpacity()` | → `.withAlpha()` |
| `profile_screen.dart` | `Color(0xFFAB47BC)` hardcodeado | → `AppColors.accentPurple` |
| `tasks_list_screen.dart` | `GestureDetector` sin ripple | → `InkWell` con `borderRadius` |
| `statistics_screen.dart` | `trend: '='` hardcodeado | → calcular dinámicamente |
| `app_colors.dart` | `success == primary` (#1DB954) | → `success = Color(0xFFA5D6A7)` |

---

*Captus Design System v1.0 — Generado como parte del proceso de elevación de diseño.*
*Archivos del sistema: `DESIGN_SYSTEM.md` (este doc) · `tokens.json` · Figma: https://www.figma.com/design/otGjpaniX0JYN2zOTr1i9I*
