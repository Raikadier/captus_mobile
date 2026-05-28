# CAPTUS DESIGN SYSTEM v2.0
> Fuente única de verdad para diseño visual en Captus Web y Captus Mobile.
> Toda decisión de color, tipografía, espaciado, sombra, movimiento o componente
> debe derivarse de este documento. Sujeto a revisión incremental.

---

## Filosofía de diseño

**"Precisión con propósito"** — Cada decisión visual sirve al estudiante.
La jerarquía clara elimina carga cognitiva. El movimiento generoso recompensa
el compromiso. El lenguaje consistente construye confianza.

### Tres pilares

| Pilar | Qué significa | Qué evitamos |
|-------|--------------|--------------|
| **Claridad** | Información siempre escaneable, nunca saturada | Elementos decorativos sin función |
| **Momentum** | El diseño celebra el progreso y motiva la acción | Estados vacíos sin guía, cero feedback |
| **Calidez** | Premium no significa frío; Captus es un compañero de estudio | Interfaces asépticas, corporativas |

---

## 1. SISTEMA DE COLOR

### Decisión de modelo de color

Todos los tokens de color se especifican en **HEX** (implementación) y
**OKLCH** (referencia perceptual). OKLCH garantiza uniformidad perceptual:
dos colores con mismo L tienen igual brillo percibido, independiente del matiz.

```
OKLCH(L C H)
  L = Luminosidad  0–1    (0=negro, 1=blanco)
  C = Croma        0–0.4  (0=gris, 0.4=máx saturación)
  H = Matiz        0–360° (148° = verde Captus)
```

---

### 1.1 Paleta de marca — Emerald (verde Captus)

El verde de Captus (#1DB954) es el corazón de la marca.
Se construye una escala tonal completa alrededor de él.

| Token | HEX | OKLCH | Uso |
|-------|-----|-------|-----|
| `brand-50`  | `#ECFDF5` | `oklch(0.97 0.05 148)` | Fondos de sección con tinte verde muy suave |
| `brand-100` | `#D1FAE5` | `oklch(0.94 0.08 148)` | Badge bg, chip activo bg |
| `brand-200` | `#A7F3D0` | `oklch(0.89 0.11 148)` | Bordes de selección, underlines |
| `brand-300` | `#6EE7B7` | `oklch(0.83 0.13 148)` | Hover en modo oscuro |
| `brand-400` | `#34D399` | `oklch(0.76 0.14 148)` | Primary en dark mode |
| `brand-500` | `#1DB954` | `oklch(0.65 0.15 148)` | **PRIMARY — acciones principales (light)** |
| `brand-600` | `#17A148` | `oklch(0.58 0.15 148)` | Pressed / hover en primary |
| `brand-700` | `#138A3A` | `oklch(0.51 0.14 148)` | Texto sobre fondos claros de marca |
| `brand-800` | `#0F6B2D` | `oklch(0.42 0.12 148)` | Texto muted en chips |
| `brand-900` | `#0A4E20` | `oklch(0.32 0.09 148)` | Decoraciones oscuras |
| `brand-950` | `#052E12` | `oklch(0.20 0.06 148)` | Backgrounds de alto contraste |

---

### 1.2 Paleta neutral — Slate (gris con undertone azul)

**Por qué Slate y no gray puro:** Los grises puros se ven apagados y baratos.
Slate tiene un sutil undertone azul-frío que hace las interfaces verse más
nítidas, modernas y de alto costo percibido. Fundamento visual de apps
premium como Linear, Vercel, Notion.

| Token | HEX | OKLCH | Uso |
|-------|-----|-------|-----|
| `slate-50`  | `#F8FAFC` | `oklch(0.985 0.005 246)` | Background principal (light) |
| `slate-100` | `#F1F5F9` | `oklch(0.967 0.007 246)` | Surface-2, inputs rest |
| `slate-200` | `#E2E8F0` | `oklch(0.922 0.013 246)` | Borders, dividers |
| `slate-300` | `#CBD5E1` | `oklch(0.865 0.020 246)` | Border 2, separadores fuertes |
| `slate-400` | `#94A3B8` | `oklch(0.712 0.032 246)` | Text-3, placeholders |
| `slate-500` | `#64748B` | `oklch(0.556 0.038 246)` | Text-2, iconos secundarios |
| `slate-600` | `#475569` | `oklch(0.462 0.040 246)` | Text-2 (alternativo oscuro) |
| `slate-700` | `#334155` | `oklch(0.360 0.037 246)` | Dark surface-3 |
| `slate-800` | `#1E293B` | `oklch(0.249 0.035 246)` | Dark surface-2 / bottom nav bg |
| `slate-900` | `#0F172A` | `oklch(0.160 0.030 246)` | Dark background |
| `slate-950` | `#020617` | `oklch(0.075 0.020 246)` | Más oscuro posible |

---

### 1.3 Paleta de acento — Violet

Reemplaza el `#7C4DFF` existente por un violet más refinado y menos saturado.

| Token | HEX | OKLCH | Uso |
|-------|-----|-------|-----|
| `violet-100` | `#EDE9FE` | `oklch(0.94 0.06 285)` | Chip bg activo (materias) |
| `violet-500` | `#7C3AED` | `oklch(0.52 0.21 285)` | Accent primary |
| `violet-600` | `#6D28D9` | `oklch(0.46 0.20 285)` | Hover accent |
| `violet-200` | `#DDD6FE` | `oklch(0.89 0.10 285)` | Border accent |

---

### 1.4 Paleta de Streak — Amber

| Token | HEX | OKLCH | Uso |
|-------|-----|-------|-----|
| `amber-100` | `#FEF3C7` | `oklch(0.96 0.09 90)` | Streak bg chip |
| `amber-400` | `#FBBF24` | `oklch(0.83 0.17 90)` | Streak accent |
| `amber-500` | `#F59E0B` | `oklch(0.75 0.17 90)` | Streak fill |
| `amber-800` | `#92400E` | `oklch(0.42 0.12 60)` | Streak text |

---

### 1.5 Tokens semánticos (LIGHT MODE)

```
// Backgrounds / Surfaces
background          = slate-50   (#F8FAFC)
surface             = white      (#FFFFFF)
surface-2           = slate-100  (#F1F5F9)
surface-3           = slate-200  (#E2E8F0)

// Brand
primary             = brand-500  (#1DB954)
primary-hover       = brand-600  (#17A148)
primary-active      = brand-700  (#138A3A)
primary-fg          = white
primary-subtle      = brand-50   (#ECFDF5)
primary-muted       = brand-100  (#D1FAE5)

// Texto
text-primary        = slate-900  (#0F172A)   ← era #111111
text-secondary      = slate-500  (#64748B)   ← era #888888
text-disabled       = slate-400  (#94A3B8)   ← era #BBBBBB
text-inverse        = white
text-on-primary     = white

// Bordes
border              = slate-200  (#E2E8F0)   ← era #E0E0E0
border-strong       = slate-300  (#CBD5E1)
divider             = slate-100  (#F1F5F9)   ← era #EEEEEE

// Semánticos
error               = #DC2626   (oklch 0.55 0.22 29)
error-bg            = #FEF2F2
warning             = #D97706   (oklch 0.63 0.17 60)
warning-bg          = #FFFBEB
info                = #2563EB   (oklch 0.51 0.22 264)
info-bg             = #EFF6FF
success             = brand-600 (#17A148)
success-bg          = brand-50  (#ECFDF5)
offline             = #B91C1C

// Shell oscura (bottom nav, drawer)
shell-bg            = slate-900  (#0F172A)   ← era #1A1A1A
shell-surface       = slate-800  (#1E293B)
modal-bg            = slate-800  (#1E293B)
```

### 1.6 Tokens semánticos (DARK MODE)

```
background          = slate-900  (#0F172A)
surface             = slate-800  (#1E293B)
surface-2           = slate-700  (#334155)
surface-3           = slate-600  (#475569)

primary             = brand-400  (#34D399)
primary-hover       = brand-300  (#6EE7B7)
primary-active      = brand-200  (#A7F3D0)
primary-fg          = slate-900
primary-subtle      = brand-950  (brand-900/30)
primary-muted       = brand-900  (brand-900/40)

text-primary        = slate-50   (#F8FAFC)
text-secondary      = slate-300  (#CBD5E1)
text-disabled       = slate-500  (#64748B)

border              = slate-700  (#334155)
border-strong       = slate-600  (#475569)
divider             = slate-800  (#1E293B)
```

---

## 2. TIPOGRAFÍA

### Familia tipográfica

```
Primary:   Inter (variable font, Google Fonts)
Mono/Nums: Inter con feature "tnum" (tabular numbers)
```

**Por qué Inter:** Diseñada específicamente para pantallas. Excelente legibilidad
a tamaños pequeños. La versión variable permite control fino de peso.
El mismo font en ambas plataformas garantiza coherencia.

### Escala tipográfica

**Base:** 1rem = 16px en web / 1sp = 1dp en mobile

| Token | Size | Line-Height | Weight | Letter-Spacing | Uso Principal |
|-------|------|-------------|--------|----------------|---------------|
| `display-xl`  | 48px | 1.10 (52px) | 800 | -0.04em | Pantallas hero, onboarding |
| `display-lg`  | 36px | 1.15 (42px) | 700 | -0.03em | Título de página |
| `display-md`  | 30px | 1.20 (36px) | 700 | -0.025em | Estadísticas hero |
| `display-sm`  | 24px | 1.25 (30px) | 700 | -0.02em | Card hero, contadores |
| `heading-lg`  | 20px | 1.30 (26px) | 700 | -0.015em | Título de pantalla |
| `heading-md`  | 18px | 1.35 (24px) | 600 | -0.010em | Encabezado de sección |
| `heading-sm`  | 16px | 1.40 (22px) | 600 | -0.005em | Título de card |
| `title-lg`    | 15px | 1.45 (22px) | 600 | 0em | Elemento de lista (título) |
| `title-sm`    | 14px | 1.45 (20px) | 500 | 0em | Sublabel de item |
| `body-lg`     | 15px | 1.60 (24px) | 400 | 0em | Párrafo |
| `body-md`     | 14px | 1.60 (22px) | 400 | 0em | Texto por defecto |
| `body-sm`     | 13px | 1.55 (20px) | 400 | +0.005em | Descripciones pequeñas |
| `caption`     | 12px | 1.50 (18px) | 500 | +0.010em | Labels, captions, badges |
| `overline`    | 11px | 1.40 (15px) | 600 | +0.08em | Etiquetas de sección (UPPERCASE) |
| `micro`       | 10px | 1.40 (14px) | 500 | +0.02em | Chips, badges compactos |

### Reglas tipográficas

1. **Jerarquía de 3 niveles máximo** en cualquier pantalla: título + body + caption
2. **Tracking negativo solo en displays** (≥20px) — nunca en body
3. **Tabular numbers** para: contadores, porcentajes, tiempos, fechas numéricas
4. **Line-height reducido en displays** (1.1-1.25) para impacto visual; 
   **line-height expandido en body** (1.55-1.6) para legibilidad
5. **Máximo 2 weights en pantalla**: preferir 400+600 ó 500+700

---

## 3. SISTEMA DE ESPACIADO

**Base grid: 4px.** Todos los valores son múltiplos de 4.

| Token | px | rem | Uso típico |
|-------|----|-----|-----------|
| `space-0`  | 0   | 0      | Reset |
| `space-px` | 1   | —      | Hairlines (borders, shadows) |
| `space-1`  | 4   | 0.25   | Gaps mínimos entre elementos inline (icon-label) |
| `space-2`  | 8   | 0.5    | Gaps pequeños, padding de badge/chip |
| `space-3`  | 12  | 0.75   | Padding interno compact (botones sm, chips) |
| `space-4`  | 16  | 1.0    | Padding estándar de componente (input, card compact) |
| `space-5`  | 20  | 1.25   | Padding cómodo (card standard, list item) |
| `space-6`  | 24  | 1.5    | Gap entre cards, sección interna |
| `space-8`  | 32  | 2.0    | Gap grande, padding de sección |
| `space-10` | 40  | 2.5    | Gap de página |
| `space-12` | 48  | 3.0    | Padding hero, altura de bottom-nav |
| `space-16` | 64  | 4.0    | Margen de página, padding hero grande |
| `space-20` | 80  | 5.0    | Padding de sección vertical |

### Espaciado de layout

```
// Mobile
page-margin-sm:  16px  (pantallas < 375px)
page-margin:     20px  (pantallas ≥ 375px)
bottom-nav-h:    64px + safe-area-inset-bottom
page-header-h:   56px
section-gap:     24px
card-gap:        12px
list-item-h:     56px (mínimo touch target = 44px)

// Web
sidebar-width:   240px (expandido) / 64px (colapsado)
main-padding:    24px
max-content-w:   1280px
grid-gap:        24px
card-gap-web:    16px
```

---

## 4. SISTEMA DE RADIOS (BORDER-RADIUS)

**Principio:** Elementos relacionados comparten radio. Contenedores tienen
radio igual o mayor que su contenido. Proporcionalidad visual consistente.

| Token | px | Uso |
|-------|----|-----|
| `radius-xs`   | 4  | Badges inline, tags de categoría muy pequeños |
| `radius-sm`   | 6  | Inputs, campos de texto, chips en estado desactivado |
| `radius-md`   | 8  | Botones secundarios, filter chips, tooltips |
| `radius-lg`   | 12 | Botones primarios, dropdowns, menús |
| `radius-xl`   | 16 | Cards estándar, bottom sheets internas |
| `radius-2xl`  | 20 | Cards grandes, modales |
| `radius-3xl`  | 28 | Bottom sheets, drawers, dialogs |
| `radius-pill` | 9999 | Avatares, FAB, progress pills, tag pills |

### Regla de contenedor

```
container-radius ≥ child-radius + content-padding
```

Ejemplo: Card (radius-xl = 16px) contiene un badge (radius-xs = 4px).
El padding del card (16px) + 4px del badge = 20px, menor que 16px del card ✓.

---

## 5. SISTEMA DE SOMBRAS / ELEVACIÓN

**Modelo:** Cada nivel de elevación tiene dos sombras: una ambiental
(difusa, opacidad baja, sin desplazamiento) y una directa
(más nítida, desplazamiento Y+, opacidad media).

### Light Mode

```
shadow-none  → ninguna sombra (elementos planos)

shadow-xs    → 0 1px 2px rgba(15,23,42, 0.04)
               Uso: separar elemento del background (subtle, chips)

shadow-sm    → 0 1px 3px rgba(15,23,42, 0.08),
               0 1px 2px rgba(15,23,42, 0.04)
               Uso: cards estándar, inputs en focus

shadow-md    → 0 4px 6px  rgba(15,23,42, 0.07),
               0 2px 4px  rgba(15,23,42, 0.04)
               Uso: cards elevadas, dropdowns, hovers

shadow-lg    → 0 10px 15px rgba(15,23,42, 0.08),
               0  4px  6px rgba(15,23,42, 0.04)
               Uso: modales, popovers, bottom sheets

shadow-xl    → 0 20px 25px rgba(15,23,42, 0.10),
               0  8px 10px rgba(15,23,42, 0.04)
               Uso: dialogs, overlays críticos

// Sombras de marca (para elementos primarios)
shadow-brand-sm → 0 2px  8px rgba(29,185,84, 0.24)
                  Uso: FAB, botón primario en rest

shadow-brand-md → 0 4px 16px rgba(29,185,84, 0.30)
                  Uso: FAB hover, botón primario hover

shadow-brand-lg → 0 8px 24px rgba(29,185,84, 0.35),
                  0 0   0   1px rgba(29,185,84, 0.12) inset
                  Uso: achievement unlock, streak hero
```

### Dark Mode

```
shadow-sm-dark → 0 1px 3px rgba(0,0,0, 0.35),
                 0 0   0   0.5px rgba(255,255,255, 0.05) inset
                 Uso: cards en dark

shadow-md-dark → 0 4px 12px rgba(0,0,0, 0.40),
                 0 0   0   0.5px rgba(255,255,255, 0.06) inset

shadow-brand-dark → 0 4px 20px rgba(52,211,153, 0.25),
                    0 0   0   1px  rgba(52,211,153, 0.15) inset
```

---

## 6. SISTEMA DE ANIMACIÓN / MOVIMIENTO

### Principios de movimiento

1. **Respuesta inmediata:** Todo tap muestra feedback en ≤80ms
2. **Exit < Enter:** Salir es más rápido que entrar (el usuario ya procesó la info)
3. **Física natural:** Las transiciones respetan inercia (spring, no linear)
4. **Semanticidad:** La dirección del movimiento comunica jerarquía
   - Navegar hacia adelante: slide-in desde derecha
   - Volver: slide-in desde izquierda
   - Modal: emerge desde abajo / desvanece hacia arriba
   - Destructivo: slide-out hacia izquierda

### Tokens de duración

| Token | ms | Uso |
|-------|-----|-----|
| `instant`    | 80  | Press feedback (ripple, scale, checkbox toggle) |
| `quick`      | 120 | Icon state change, color swap |
| `fast`       | 180 | Chip/badge state, opacity inline |
| `standard`   | 240 | Card aparición, tab switch, container resize |
| `comfortable`| 320 | Screen enter, modal open, bottom sheet |
| `slow`       | 420 | Achievement unlock, streak hero |
| `deliberate` | 600 | Count-up, progress fill, onboarding slide |
| `loop`       | 900 | Typing dots, spinners |
| `shimmer`    | 1200| Skeleton sweep (ciclo completo) |

### Tokens de curvas

```
// CSS cubic-bezier
ease-standard:  cubic-bezier(0.645, 0.045, 0.355, 1.000)  // start & end at rest
ease-enter:     cubic-bezier(0.250, 0.460, 0.450, 0.940)  // decelerate (enter)
ease-exit:      cubic-bezier(0.550, 0.055, 0.675, 0.190)  // accelerate (exit)
ease-spring:    cubic-bezier(0.340, 1.560, 0.640, 1.000)  // bouncy (completions)
ease-spring-soft: cubic-bezier(0.175, 0.885, 0.320, 1.275) // soft bounce
ease-linear:    cubic-bezier(0.000, 0.000, 1.000, 1.000)  // looping

// Flutter
AppCurves.standard  → Curves.easeInOutCubic
AppCurves.enter     → Curves.easeOut
AppCurves.exit      → Curves.easeIn
AppCurves.spring    → Curves.elasticOut  (amplitude:0.6, period:0.4)
AppCurves.springShort → Cubic(0.34, 1.56, 0.64, 1.0)
```

### Patrones de interacción nombrados

| Patrón | Transform | Duración | Curva | Trigger |
|--------|-----------|----------|-------|---------|
| `press`    | scale(0.97) + opacity 0.9 | instant | ease-in | Tap inicio |
| `release`  | scale(1.00) + opacity 1.0 | quick   | spring-soft | Tap fin |
| `appear`   | opacity 0→1 + translateY(8→0) | standard | ease-enter | Mount |
| `exit`     | opacity 1→0 + translateY(0→-8) | fast | ease-exit | Unmount |
| `pop`      | scale(0.8→1.05→1) | slow | spring | Achievement |
| `shake`    | translateX(±4px × 3) | fast × 3 | ease-standard | Error |
| `float-in` | translateY(16→0) + opacity 0→1 | comfortable | ease-enter | Modal |
| `stagger`  | appear × N, delay: 40ms cada item | standard | ease-enter | Lista |

---

## 7. SISTEMA DE GRADIENTES

```
// Gradiente de marca — CTA, FAB, botón hero
gradient-brand:   linear-gradient(135°, #1DB954 0%, #17A148 100%)

// Gradiente de acento — Achievement, header de streak
gradient-accent:  linear-gradient(135°, #7C3AED 0%, #1DB954 100%)

// Gradiente amber — Streak, gamificación
gradient-streak:  linear-gradient(135°, #FBBF24 0%, #F59E0B 100%)

// Gradiente neutro — Background de sección, card hero
gradient-surface: linear-gradient(180°, #FFFFFF 0%, #F8FAFC 100%)

// Gradiente de skeleton (shimmer)
gradient-shimmer: linear-gradient(
  90°,
  transparent   0%,
  rgba(241,245,249, 0.8) 50%,
  transparent   100%
)

// Dark mode brand
gradient-brand-dark: linear-gradient(135°, #34D399 0%, #059669 100%)
```

---

## 8. ESPECIFICACIONES DE COMPONENTES

### 8.1 Botón (Button)

**Anatomía:** [icon-izq? 20px + gap-2] [label] [icon-der? 20px + gap-2]

**Dimensiones:**
```
height:     44px (mobile) / 40px (web default) / 36px (sm) / 48px (lg)
padding-x:  16px (default), 12px (sm), 20px (lg)
gap:        8px (icon-to-label)
min-width:  120px (web), full-width en mobile por defecto
radius:     radius-lg (12px) primary / radius-md (8px) secondary
```

**Variantes:**

| Variante | Background | Texto | Border | Sombra |
|----------|-----------|-------|--------|--------|
| Primary | `gradient-brand` | white | ninguna | `shadow-brand-sm` |
| Secondary | transparent | primary | 1.5px primary | ninguna |
| Ghost | transparent | primary | ninguna | ninguna |
| Destructive | `#DC2626` | white | ninguna | `shadow-xs` |
| Muted | surface-2 | text-secondary | border | ninguna |

**Estados:**

| Estado | Transform | Opacity | Sombra | Duración |
|--------|-----------|---------|--------|----------|
| Rest | scale(1) | 1 | según variante | — |
| Hover | translateY(-1px) | 1 | +1 nivel | standard |
| Active | scale(0.97) | 0.9 | -1 nivel | instant |
| Focus | ring 3px offset-2px primary/50 | 1 | según variante | quick |
| Disabled | scale(1) | 0.4 | ninguna | quick |
| Loading | scale(1) | 0.7 | según variante | — |

---

### 8.2 Card

**Tipos:**

```
Card.flat ─────────────────────────────────────────────
  bg:      surface (white)
  border:  1px slate-200 (#E2E8F0)
  radius:  radius-xl (16px)
  shadow:  shadow-xs
  padding: space-4 (16px) compact / space-5 (20px) standard

Card.elevated ──────────────────────────────────────────
  bg:      surface (white)
  border:  ninguna
  radius:  radius-xl (16px)
  shadow:  shadow-sm
  padding: space-5 (20px)

Card.premium ───────────────────────────────────────────
  bg:      surface (white)
  border:  0.5px rgba(226,232,240, 0.5)  ← hairline muy sutil
  radius:  radius-2xl (20px)
  shadow:  shadow-md
  hover:   shadow-lg + translateY(-2px) @ standard/ease-enter
  padding: space-5 (20px) / space-6 (24px)
  
Card.filled (acento) ────────────────────────────────────
  bg:      primary-subtle (brand-50) o gradient-surface
  border:  1px brand-200
  radius:  radius-xl (16px)
  shadow:  shadow-brand-sm
```

---

### 8.3 Input Field

```
height:         48px (default) / 40px (sm)
padding:        16px horizontal, 14px vertical
radius:         radius-sm (6px)   ← levemente cuadrado vs botones (intención)
font:           body-md (14px, w400)
bg-rest:        surface-2 (slate-100)
bg-focus:       surface (white)
border-rest:    1px border (slate-200)
border-focus:   2px primary (brand-500)
border-error:   1px-rest/2px-focus error (#DC2626)
prefix-icon:    text-secondary, 20px, space-3 gap
transition:     border-color, background @ fast/ease-standard
label-style:    caption (12px, w500) para floating label
                title-sm (14px, w500) para label estático
```

---

### 8.4 Badge / Chip

```
// Badge (estado, prioridad)
Badge:
  height:   20px
  padding:  2px 8px
  radius:   radius-xs (4px)
  font:     overline (11px, w600, uppercase)
  
// Chip (filtro, categoría)
Chip:
  height:   28px
  padding:  4px 12px
  radius:   radius-pill
  font:     caption (12px, w500)
  icon:     16px, gap space-1
  
// Chip activo:
  bg:     primary-muted (brand-100)
  text:   brand-700
  border: 1px brand-200
  icon:   brand-600
```

---

### 8.5 Progress Bar

```
height:    6px (default) / 3px (micro en list items)
radius:    pill
bg:        surface-3 (slate-200)
fill:      gradient-brand (primary → primary-hover)
animation: fill de 0% al valor real @ deliberate/ease-enter
           leading edge: psuedo-element shimmer
overflow:  hidden (contiene fill gradient)
```

---

### 8.6 Avatar

```
xs:  24px  — inline en texto, tabla
sm:  32px  — lista compacta
md:  40px  — lista estándar, item default
lg:  48px  — perfil inline, card header
xl:  64px  — pantalla de perfil
2xl: 96px  — hero de perfil

shape:   radius-pill (círculo perfecto)
border:  2px surface (crea separación del fondo)
fallback: initials (1-2 chars) sobre gradient-brand o gradient-accent
          seed del color: hash(user.id) % courseColors.length
```

---

### 8.7 Bottom Navigation (Mobile)

```
height:        64px + safe-area-inset-bottom
bg:            shell-bg (slate-900)
border-top:    0.5px rgba(255,255,255, 0.08)  ← separador muy sutil
selected-icon: primary (brand-500), 24px
selected-label:caption (10px, w600), primary color
unselected:    slate-400, 22px icon
indicator:     2px capsule bajo ícono, gradient-brand
transition:    color + scale @ quick/ease-spring
```

---

### 8.8 App Bar (Mobile)

```
height:        56px
bg:            background (F8FAFC) con blur backdrop en scroll
elevation:     0 en rest → shadow-xs al scrollear
title:         heading-md (18px, w600), text-primary
leading-icon:  text-secondary, 24px
trailing-icons: text-secondary, 24px, gap space-2
status-bar:    transparent, dark icons (light mode)
```

---

## 9. SISTEMA DE ICONOS

**Librería:** Lucide (web: lucide-react, mobile: lucide_flutter)
**Estilo:** Rounded, stroke 1.75px, 24dp grid base

| Token | px | Contexto |
|-------|----|----------|
| `icon-micro`   | 12 | Badges, indicadores inline muy pequeños |
| `icon-sm`      | 16 | Inline en texto cuerpo, labels |
| `icon-md`      | 20 | Botones, list items, chips (DEFAULT) |
| `icon-default` | 24 | Nav bar, app bar, tarjetas |
| `icon-lg`      | 32 | Empty states, section headers |
| `icon-xl`      | 48 | Onboarding, error/success pages |
| `icon-hero`    | 64 | Ilustraciones de apoyo |

**Reglas:**
1. Todos los iconos usan `currentColor` — heredan del texto padre
2. Navigation: **filled** para seleccionado, **outlined** para no seleccionado
3. Nunca mezclar outlined y filled en el mismo contexto funcional
4. Stroke weight fijo: 1.75px (no 2px) para look premium y fino
5. Padding de icon: siempre 2px menor que el touch target (icon 20dp → tap 44dp)

---

## 10. LAYOUT Y GRID

### Mobile

```
Grid base:          8-column fluid
Márgenes:           16px (< 375px) / 20px (≥ 375px)
Gutter:             8px
Content max-width:  100%

Zonas seguras:
  top:    status-bar height (sistema)
  bottom: safe-area-inset-bottom + bottom-nav-height

Breakpoints:
  compact:  < 375px  (SE, iPhone mini)
  standard: 375–414px
  large:    > 414px  (Plus, Pro Max)
```

### Web

```
Grid:             12 columnas
Gutter:           24px
Breakpoints:
  mobile-web:     < 768px
  tablet:         768–1024px
  desktop:        1024–1280px
  wide:           > 1280px

Containers:
  sidebar:        240px (expandida) / 64px (colapsada)
  main-content:   max-width 960px en 1280px viewport
  page-padding:   24px desktop / 16px mobile
```

---

## 11. DECORACIONES

### Fondos de sección (patterned backgrounds)
```
// Grid sutil: 1px líneas slate-200 cada 24px (solo web, sections hero)
pattern-grid: svg inline, opacity 0.3

// Puntos: 2px dot slate-100/50, cada 20px (hero backgrounds)
pattern-dots: radial-gradient(circle, slate-200 1px, transparent 1px) 0 0 / 20px 20px
```

### Glassmorphism (uso controlado y específico)
```
// Solo para: overlays de tab bar scrolleado, modales en dark mode
backdrop-filter:  blur(16px) saturate(150%)
background:       rgba(255,255,255, 0.80) light / rgba(15,23,42, 0.80) dark
border:           0.5px rgba(255,255,255, 0.15)
```

### Efectos de hover en web
```
card-hover:
  transform:    translateY(-2px)
  shadow:       shadow-md (from shadow-sm)
  transition:   all @ standard/ease-standard

button-hover:
  transform:    translateY(-1px)
  shadow:       +1 nivel
  transition:   all @ standard/ease-enter
```

---

## 12. ACCESIBILIDAD (A11Y)

### Contraste mínimo (WCAG 2.1 AA)
```
Texto normal   (< 18px):  4.5:1
Texto grande   (≥ 18px):  3.0:1
UI elements:              3.0:1
```

**Verificaciones obligatorias:**
- primary (#1DB954) sobre white: 3.11:1 → ⚠️ Solo para texto grande/iconos
- primary-fg (white) sobre primary (#1DB954): 3.11:1 → ✓ para labels en botones
- text-primary (slate-900) sobre background (slate-50): 14.5:1 → ✓✓
- text-secondary (slate-500) sobre background (slate-50): 4.6:1 → ✓

### Touch targets (Mobile)
- Mínimo absoluto: 44×44dp (Apple HIG) / 48×48dp (Material)
- Preferido: 56×56dp para acciones frecuentes
- Si el elemento visual es pequeño: usar área de tap expandida invisible

### Movimiento
- Respetar `prefers-reduced-motion`: desactivar transforms, mantener opacity
- Nunca usar parpadeo o flash > 3Hz

---

## 13. TOKENS DE PLATAFORMA

### Tabla de correspondencia Flutter ↔ CSS

| Concepto | Flutter (Dart) | CSS (web) |
|----------|---------------|-----------|
| Primary | `AppColors.primary` | `var(--primary)` |
| Background | `AppColors.background` | `var(--background)` |
| Surface | `AppColors.surface` | `var(--card)` |
| Text primary | `AppColors.textPrimary` | `var(--foreground)` |
| Text secondary | `AppColors.textSecondary` | `var(--muted-foreground)` |
| Border | `AppColors.border` | `var(--border)` |
| Error | `AppColors.error` | `var(--destructive)` |
| Card radius | `16px` | `var(--radius-xl)` = `1rem` |
| Standard duration | `AppDurations.standard` (240ms) | `240ms` |
| Enter curve | `AppCurves.enter` | `cubic-bezier(0.25, 0.46, 0.45, 0.94)` |

---

## 14. VERSIONADO Y PROCESO DE CAMBIO

### Reglas para modificar el design system

1. **Proponer cambio**: Issue de GitHub con label `design-system`
2. **Branch**: `design/DS-{número}-{descripción}`
3. **Scope mínimo**: Un cambio por PR
4. **Retrocompatibilidad**: Nunca eliminar un token sin migration period de 1 sprint
5. **Review**: Aprobación requerida de quien definió el token + líder de proyecto

### Tokens en estado de migración

| Token viejo | Token nuevo | Estado | Deadline |
|-------------|------------|--------|---------|
| `AppColors.bottomNavBg` `#1A1A1A` | `AppColors.shellBg` `#0F172A` | En migración v2 | Sprint actual |
| `AppColors.textSecondary` `#888888` | `#64748B` (slate-500) | En migración v2 | Sprint actual |
| `AppColors.surface2` `#F2F2F2` | `#F1F5F9` (slate-100) | En migración v2 | Sprint actual |

---

## GLOSARIO

| Término | Definición |
|---------|-----------|
| Token | Variable con nombre que almacena un valor de diseño (color, tamaño, etc.) |
| Semantic token | Token que describe propósito ("error") no implementación ("#DC2626") |
| Primitive | Token de valor crudo en la escala (brand-500, slate-200) |
| Alias | Token que apunta a otro token (primary → brand-500) |
| OKLCH | Espacio de color perceptualmente uniforme (Lightness, Chroma, Hue) |
| Tonal palette | Conjunto de 11 tintes del mismo matiz (50–950) |
| Elevation | Nivel de profundidad simulado mediante sombra |
| Spring curve | Curva de animación con overshooting natural (rebote) |
