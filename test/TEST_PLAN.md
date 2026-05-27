# Captus Mobile — Plan de Testing

> **Fecha:** 2026-05-27  
> **Versión:** 1.0  
> **Autor:** Equipo Captus

---

## 1. Alcance y objetivos

| Objetivo | Métrica objetivo |
|---|---|
| Cobertura de línea (models + utils) | ≥ 80 % |
| Cobertura de ramas (lógica de negocio) | ≥ 70 % |
| Pruebas unitarias que pasan | 100 % |
| Pruebas de widget que pasan | 100 % |
| Tiempo total de suite completa | < 120 s |
| Cero crashes en flujo cold-start | ✅ |

---

## 2. Niveles de prueba (Pirámide de testing)

```
         ╔══════════╗
         ║   E2E    ║   2 tests  — integration_test/
         ╠══════════╣
         ║ Widget   ║   45+ tests — test/widgets/
         ╠══════════╣
         ║  Unit    ║   90+ tests — test/unit/ + test/models/ + test/providers/
         ╚══════════╝
```

---

## 3. Estructura de directorios

```
test/
├── helpers/
│   └── test_helpers.dart          # Utilidades compartidas, fixtures, pump helpers
├── unit/
│   └── utils/
│       ├── app_errors_test.dart   # friendlyError() — 28 casos
│       └── streak_messages_test.dart  # getStreakMessage/Emoji/Title — 35 casos
├── models/
│   ├── task_test.dart             # TaskModel + SubTask — 18 casos ✅
│   ├── note_test.dart             # NoteModel — 10 casos ✅
│   ├── course_test.dart           # CourseModel — 12 casos ✅
│   └── local_user_test.dart       # LocalUser/UserModel — 15 casos ✅
├── providers/
│   ├── tasks_provider_test.dart   # TaskFilters + providers — 22 casos ✅
│   ├── auth_provider_test.dart    # LocalUser persistence — 14 casos ✅
│   ├── courses_provider_test.dart # Courses provider — 8 casos ✅
│   └── ai_chat_provider_test.dart # AI chat provider — 15 casos ✅
├── widgets/
│   ├── task_card_test.dart        # TaskCard widget — 18 casos
│   ├── login_screen_test.dart     # LoginScreen — 9 casos
│   ├── home_dashboard_test.dart   # Dashboard composition — 8 casos
│   └── shared/
│       ├── streak_badge_test.dart     # StreakBadge — 8 casos
│       ├── empty_state_test.dart      # EmptyState — 6 casos
│       ├── countdown_chip_test.dart   # CountdownChip — 7 casos
│       └── offline_banner_test.dart   # OfflineBanner — 4 casos
└── integration/
    ├── api_client_test.dart        # ApiClient HTTP — 20+ casos ✅
    └── supabase_service_test.dart  # Contratos de mapping — 18 casos

integration_test/
└── app_navigation_test.dart       # E2E cold-start + nav — 4 casos
```

---

## 4. Tipos de prueba implementados

### 4.1 Pruebas Unitarias (`test/unit/`, `test/models/`, `test/providers/`)

**Objetivo:** Verificar la lógica de negocio de forma aislada, sin UI ni red.

| Módulo | Qué se verifica |
|---|---|
| `TaskModel` | Serialización JSON, campos opcionales, `isOverdue`, `completedSubtasks`, `copyWith`, prioridades |
| `SubTask` | `fromJson` con keys legacy (`id_SubTask`, `state`), `copyWith`, `toJson` |
| `TaskFilters` | Todos los campos `copyWith`, flags `clearX` |
| `friendlyError` | 15+ escenarios Dio + 10 excepciones de cadena de texto |
| `getStreakMessage` | 9 rangos de racha, aleatoriedad, valores límite |
| `getStreakEmoji` | 12 puntos de ruptura exactos |
| `getStreakTitle` | 12 puntos de ruptura exactos |
| `LocalStorageService` | CRUD básico con SharedPreferences mock |

### 4.2 Pruebas de Widget (`test/widgets/`)

**Objetivo:** Verificar el árbol de widgets, interacciones del usuario y accesibilidad sin red.

| Widget | Escenarios |
|---|---|
| `TaskCard` | Título, descripción, badge de prioridad, estado completado (tachado), checkbox, callbacks `onTap`/`onComplete`, progreso de subtareas, estado vencido (opacidad 0.7) |
| `LoginScreen` | Campos visibles, botón de acción, campo de contraseña obscurecido, toggle de visibilidad, validación de formulario |
| `StreakBadge` | Tres tamaños (micro/mini/hero), renderizado de días, texto "días consecutivos" |
| `EmptyState` | Ícono + título + subtítulo, botón condicional, callback de acción |
| `CountdownChip` | "Vencida" (pasada), "Vence en Xh" (< 24h), "Vence en Xd" (< 3d), fecha formateada (> 3d), "Menos de 1h" |
| `OfflineBanner` | Invisible cuando online, visible cuando offline, transición animada |
| `HomeDashboard` | Integración OfflineBanner + StreakBadge + TaskCard + EmptyState |

### 4.3 Pruebas de Integración (`test/integration/`)

**Objetivo:** Verificar contratos de servicio y comunicación HTTP sin infraestructura real.

| Módulo | Escenarios |
|---|---|
| `ApiClient` | GET/POST/PUT/DELETE, manejo de errores HTTP (400/401/403/404/500), retry, headers de auth, timeouts |
| `SupabaseService contract` | Mapping de campos Supabase → modelo, keys legacy (`endDate`, `subTasks`/`subtasks`), estado `overdue` computado, round-trip JSON |

### 4.4 Pruebas E2E (`integration_test/`)

**Objetivo:** Verificar flujos completos sobre dispositivo/emulador real.

| Flujo | Escenarios |
|---|---|
| Cold start | App lanza sin crash, transición splash → login en < 5s |
| Login form | Campo email acepta texto, validación sin envío, sin errores Flutter críticos |

---

## 5. Cómo ejecutar las pruebas

### Suite completa (unit + widget + integration)
```bash
flutter test --reporter compact
```

### Por categoría
```bash
# Solo unitarias
flutter test test/unit/ test/models/ test/providers/ --reporter compact

# Solo widgets
flutter test test/widgets/ --reporter compact

# Solo integración (sin red)
flutter test test/integration/ --reporter compact

# Con cobertura de código
flutter test --coverage --reporter compact
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### E2E en emulador
```bash
# Iniciar emulador primero
flutter test integration_test/app_navigation_test.dart --device-id <emulator-id>
```

### Reporte de cobertura rápido
```bash
flutter test --coverage && flutter pub run coverage:format_coverage \
  --lcov --in=coverage/lcov.info --out=coverage/lcov.info --report-on=lib
```

---

## 6. Métricas de calidad

| Métrica | Herramienta | Umbral |
|---|---|---|
| Cobertura de línea | `lcov` / `flutter test --coverage` | ≥ 80 % en `lib/` |
| Pruebas que pasan | `flutter test` | 100 % (0 fallos) |
| Tiempo de suite | CI timer | < 120 s |
| Errores de lint | `flutter analyze` | 0 errores, 0 warnings |
| Duplicación de código | revisión manual | < 5 % en lógica de negocio |

---

## 7. Cobertura actual estimada (por módulo)

| Módulo | Estado | Cobertura estimada |
|---|---|---|
| `models/task.dart` | ✅ Completo | ~90 % |
| `models/note.dart` | ✅ Completo | ~85 % |
| `models/user.dart` | ✅ Completo | ~85 % |
| `core/utils/app_errors.dart` | ✅ Nuevo | ~95 % |
| `features/statistics/utils/streak_messages.dart` | ✅ Nuevo | ~95 % |
| `core/providers/tasks_provider.dart` (filters) | ✅ Completo | ~85 % |
| `shared/widgets/task_card.dart` | ✅ Nuevo | ~80 % |
| `shared/widgets/streak_badge.dart` | ✅ Nuevo | ~90 % |
| `shared/widgets/empty_state.dart` | ✅ Nuevo | ~90 % |
| `shared/widgets/countdown_chip.dart` | ✅ Nuevo | ~85 % |
| `shared/widgets/offline_banner.dart` | ✅ Nuevo | ~80 % |
| `core/services/api_client.dart` | ✅ Completo | ~75 % |
| `features/auth/screens/login_screen.dart` | ✅ Nuevo | ~60 % |

---

## 8. Casos de prueba de usabilidad (manual)

Para la presentación, ejecutar manualmente los siguientes escenarios:

| ID | Escenario | Resultado esperado |
|---|---|---|
| U-01 | Iniciar sesión con credenciales válidas | Navega al dashboard sin errores |
| U-02 | Iniciar sesión con contraseña incorrecta | Muestra mensaje de error amigable |
| U-03 | Crear tarea con fecha pasada | Aparece como "Vencida" con color rojo |
| U-04 | Marcar tarea como completada | Checkbox lleno, título tachado, tarea sale de la lista |
| U-05 | Filtrar tareas por prioridad Alta | Lista muestra solo tareas de prioridad alta |
| U-06 | Desconectar internet | Banner "Sin conexión" aparece inmediatamente |
| U-07 | Reconectar internet | Banner desaparece con animación |
| U-08 | Navegar entre secciones del shell | Cada sección carga sin lag visible |
| U-09 | Crear nota con contenido Markdown | Vista previa renderiza correctamente |
| U-10 | Ver racha de 0 días en dashboard | Mensaje motivacional de 0 días |
| U-11 | Ver racha de 30+ días | Badge "👑 Maestro" visible |
| U-12 | Modo oscuro/claro | App usa el tema light configurado correctamente |
| U-13 | Gestos de desliz en TaskCard | Acciones "Listo / Editar / Eliminar" aparecen |
| U-14 | Lector de pantalla (TalkBack) | Todos los botones tienen etiquetas semánticas |
| U-15 | Fuente del sistema aumentada | Textos no se cortan ni desbordan |

---

## 9. Criterios de aceptación para presentación

- [ ] `flutter test` pasa 100 % de las pruebas
- [ ] `flutter analyze` reporta 0 errores
- [ ] Cold start en emulador llega a login en < 5 segundos
- [ ] Flujo de tareas (crear → completar) funciona sin errores de consola
- [ ] Banner offline se activa al desconectar internet
- [ ] StreakBadge muestra días correctos en dashboard
- [ ] No hay warnings de overflow en pantallas principales
