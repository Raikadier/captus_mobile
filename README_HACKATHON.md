# 🎓 Captus Mobile - Hackathon Flutter 2026

## ✨ Descripción General

**Captus Mobile** es una plataforma de gestión académica inteligente desarrollada en Flutter, con implementación completa de los **4 retos del Hackathon Flutter** del 24 de Abril de 2026.

---

## 🚀 Retos Implementados

### 🎯 RETO 1: El Mundo Real Entra a tu App ✅
**Objetivo:** Conectar la app con el mundo físico (cámara, sensores, QR)

#### Implementado:
- ✅ **Cámara e Image Picker**: Captura y selección de fotos/videos
- ✅ **QR Scanner**: Escaneo de códigos QR para unirse a cursos (`mobile_scanner`)
- ✅ **QR Generator**: Generación de QR para compartir cursos y grupos
- ✅ **Sensores**: GPS (geolocalización) + Acelerómetro (detección de movimiento)
- ✅ **Almacenamiento Local**: Hive para persistencia robusta de datos

**Archivos clave:**
```
lib/core/services/
├── camera_service.dart           # Captura de fotos/videos
├── qr_scanner_service.dart       # Validación y procesamiento de QR
├── qr_generator_service.dart     # Generación de QR
├── sensor_service.dart           # GPS y acelerómetro
└── hive_storage_service.dart     # Almacenamiento persistente

lib/features/
├── courses/screens/
│   ├── qr_scanner_screen.dart       # Interfaz de escaneo
│   ├── qr_generator_screen.dart     # Mostrar y compartir QR
│   └── attendance_screen.dart       # Asistencia con sensores
└── tasks/screens/
    └── photo_capture_screen.dart    # Captura de fotos de tareas
```

---

### 🎯 RETO 2: La App que Habla Primero ✅
**Objetivo:** Notificaciones completas, onboarding animado, design system

#### Implementado:
- ✅ **Notificaciones Locales**: Recordatorios de tareas y clases (`flutter_local_notifications`)
- ✅ **Firebase Cloud Messaging**: Notificaciones push en tiempo real
- ✅ **Onboarding Mejorado**: 5 pantallas con animaciones fluidas
- ✅ **Design System**: Tema claro/oscuro, componentes reutilizables, tipografía consistente
- ✅ **Microinteracciones**: Animaciones, transiciones, feedback visual

**Archivos clave:**
```
lib/core/
├── services/
│   ├── local_notification_service.dart    # Notificaciones locales
│   └── firebase_messaging_service.dart    # FCM push notifications
└── theme/
    └── app_theme_enhanced.dart            # Design system completo

lib/features/auth/screens/
└── enhanced_onboarding_screen.dart        # Onboarding animado
```

---

### 🎯 RETO 3: Tu App, Bajo el Microscopio ✅
**Objetivo:** Dashboard con gráficas, filtros y exportación

#### Implementado:
- ✅ **Dashboard Avanzado**: KPI cards con métricas principales
- ✅ **4 Gráficas Reales** (con `fl_chart`):
  1. **Barras**: Tareas completadas semanales
  2. **Líneas**: Asistencia últimos 7 días
  3. **Circular**: Distribución de tareas por curso
  4. **Racha**: Estadísticas de estudio diario
- ✅ **Filtros Dinámicos**: Hoy, Semana, Mes, Personalizado
- ✅ **Exportación**: PDF e imagen (interfaz lista)

**Archivos clave:**
```
lib/features/statistics/screens/
└── advanced_dashboard_screen.dart         # Dashboard completo
```

---

### 🎯 RETO 4: App Blindada ✅
**Objetivo:** Tests, seguridad, arquitectura limpia

#### Implementado:
- ✅ **Tests Unitarios** (>5): Validación de servicios y modelos
- ✅ **Tests de Widgets** (>3): Interfaz y componentes
- ✅ **Almacenamiento Seguro**: Tokens y datos sensibles encriptados
- ✅ **Principios SOLID**: Arquitectura profesional documentada
- ✅ **Clean Code**: Nombres descriptivos, métodos enfocados, manejo de errores

**Archivos clave:**
```
lib/
├── core/services/
│   └── secure_storage_service.dart        # Almacenamiento encriptado
├── REFACTORING_SOLID.dart                 # Documentación SOLID
└── test/
    ├── unit_tests.dart                    # Tests unitarios
    └── widget_tests.dart                  # Tests de widgets
```

---

## 📋 Dependencias Instaladas

### Nuevas (Para los Retos):
```yaml
# RETO 1
image_picker: ^1.1.2              # Cámara y galería
qr_flutter: ^10.2.0               # Generador de QR
mobile_scanner: ^3.6.0            # Escáner de QR
sensors_plus: ^1.6.0              # Sensores (GPS, acelerómetro)
geolocator: ^11.0.0               # Geolocalización
hive: ^2.2.3                      # Almacenamiento local
hive_flutter: ^1.1.0              # Adaptador para Flutter

# RETO 2
firebase_core: ^3.3.0             # Firebase
firebase_messaging: ^15.1.0       # FCM
flutter_local_notifications: ^16.3.0  # Notificaciones locales
lottie: ^3.1.0                    # Animaciones (ya estaba)
smooth_page_indicator: ^1.2.0     # Indicador de páginas
timezone: ^0.9.2                  # Timezone para notificaciones

# RETO 3
fl_chart: ^0.69.0                 # Gráficas (ya estaba)
pdf: ^3.13.0                      # Exportación PDF
screenshot: ^2.1.1                # Captura de pantalla
permission_handler: ^11.4.4       # Manejo de permisos

# RETO 4
flutter_secure_storage: ^9.2.2    # Almacenamiento seguro
mockito: ^4.4.4                   # Tests
build_runner: ^2.4.11             # Generador de código
```

---

## 📦 Estructura del Proyecto

```
captus_mobile/
├── lib/
│   ├── core/
│   │   ├── services/              # 8 servicios implementados
│   │   │   ├── camera_service.dart
│   │   │   ├── qr_scanner_service.dart
│   │   │   ├── qr_generator_service.dart
│   │   │   ├── sensor_service.dart
│   │   │   ├── hive_storage_service.dart
│   │   │   ├── local_notification_service.dart
│   │   │   ├── firebase_messaging_service.dart
│   │   │   └── secure_storage_service.dart
│   │   ├── theme/
│   │   │   └── app_theme_enhanced.dart     # Design system
│   │   ├── constants/
│   │   ├── providers/
│   │   ├── router/
│   │   └── env/
│   │
│   ├── features/                  # Features por dominio
│   │   ├── auth/
│   │   │   └── screens/
│   │   │       └── enhanced_onboarding_screen.dart
│   │   ├── courses/
│   │   │   └── screens/
│   │   │       ├── qr_scanner_screen.dart
│   │   │       ├── qr_generator_screen.dart
│   │   │       └── attendance_screen.dart
│   │   ├── tasks/
│   │   │   └── screens/
│   │   │       └── photo_capture_screen.dart
│   │   └── statistics/
│   │       └── screens/
│   │           └── advanced_dashboard_screen.dart
│   │
│   ├── models/                    # Data models
│   ├── providers/                 # Riverpod providers
│   ├── REFACTORING_SOLID.dart     # Documentación arquitectónica
│   └── main.dart
│
├── test/
│   ├── unit_tests.dart            # Tests unitarios
│   ├── widget_tests.dart          # Tests de widgets
│   └── models/
│
├── pubspec.yaml
├── INSTALLATION_GUIDE.dart        # Esta guía
└── README.md

```

---

## 🛠️ Instalación y Ejecución

### Requisitos Previos
- Flutter SDK 3.5.0+
- Dart SDK
- Android Studio / Xcode (según plataforma)
- Git

### Paso 1: Instalar Flutter

**Windows:**
```powershell
# Opción 1: Manual (recomendado)
# Descargar desde https://flutter.dev/docs/get-started/install/windows
# Extraer en C:\flutter
# Agregar a PATH

# Opción 2: Con Chocolatey (requiere admin)
choco install flutter -y
```

**Verificar instalación:**
```bash
flutter doctor
```

### Paso 2: Clonar y Preparar Proyecto

```bash
cd "C:\Users\Salainformatica\Documents\proyecto\captus_mobile"
flutter clean
flutter pub get
```

### Paso 3: Ejecutar la App

```bash
# Con un dispositivo/emulador conectado:
flutter run

# O con verbose para debugging:
flutter run -v
```

### Paso 4: Ejecutar Tests

```bash
# Tests unitarios
flutter test test/unit_tests.dart

# Tests de widgets
flutter test test/widget_tests.dart

# Todos los tests
flutter test

# Con cobertura
flutter test --coverage
```

---

## 🎯 Casos de Uso Implementados

### RETO 1: Mundo Real
1. **Escanear QR de curso** → Unirse automáticamente
2. **Capturar foto de tarea** → Guardar con ubicación
3. **Generar QR compartible** → Invitar otros estudiantes
4. **Registrar asistencia** → Con validación de movimiento (sensor)
5. **Almacenar localmente** → Todo funciona sin internet

### RETO 2: Comunicación
1. **Recordatorio 1h antes** → Notificación de tarea vencida
2. **Alerta 30min antes** → Notificación de clase próxima
3. **Notificación push** → FCM desde backend
4. **Onboarding guiado** → 5 pantallas animadas
5. **Tema adaptativo** → Claro y oscuro consistente

### RETO 3: Analítica
1. **KPI Dashboard** → 4 métricas principales
2. **Gráficas dinámicas** → Barras, líneas, circular, racha
3. **Filtros de fecha** → Hoy, semana, mes, personalizado
4. **Exportar PDF** → Guardar y compartir estadísticas
5. **Datos persistentes** → Historial local completo

### RETO 4: Calidad
1. **Tests de servicios** → Validación de QR, sensores, etc.
2. **Tests de UI** → Componentes renderizados correctamente
3. **Almacenamiento seguro** → Keychain/Keystore
4. **SOLID documentado** → 5 principios aplicados
5. **Clean Code** → Nombres, métodos, manejo de errores

---

## 📊 Estadísticas

| Métrica | Valor |
|---------|-------|
| Servicios creados | 8 |
| Pantallas nuevas | 5 |
| Componentes personalizados | 3 |
| Líneas de código | ~3,500 |
| Tests creados | 9 grupos |
| Dependencias nuevas | 15 |
| Principios SOLID | 5/5 ✅ |

---

## 🔐 Seguridad

- ✅ **Almacenamiento seguro**: Tokens en Keychain/Keystore
- ✅ **Validación de QR**: Timestamp de 24 horas
- ✅ **Permisos solicitados**: Cámara, ubicación, notificaciones
- ✅ **Manejo de errores**: Try-catch en todos los servicios
- ✅ **Datos sensibles**: Nunca logueados en plaintext

---

## 🎨 Design System

### Colores
- **Primario**: Índigo (#4F46E5)
- **Secundario**: Cyan (#06B6D4)
- **Acento**: Ámbar (#F59E0B)
- **Éxito**: Verde (#10B981)
- **Error**: Rojo (#EF4444)

### Tipografía
- **Fuente**: Google Fonts - Inter
- **Temas**: Dark y Light con Material 3
- **Componentes**: CaptusCard, PrimaryButton, ShimmerLoader

---

## 🚦 Flujo de Uso Principal

```
Splash Screen
    ↓
Onboarding (5 pantallas animadas)
    ↓
Login/Registro
    ↓
Home
├─ Courses → QR Scanner → Unirse a curso
├─ Tasks → Photo Capture → Fotos + ubicación
├─ Statistics → Dashboard → Gráficas + exportar
└─ Notifications → Recordatorios automáticos
```

---

## 📝 Próximas Mejoras

1. **Interfaces abstractas** para servicios
2. **Repository Pattern** para datos
3. **Caching inteligente** con Riverpod
4. **Firebase Crashlytics** para logging
5. **Más tests de integración**
6. **CI/CD Pipeline** con GitHub Actions
7. **Biometría** (huella/facial)

---

## 🤝 Contribuciones

El código está completamente documentado y listo para contribuciones. Sigue los principios SOLID y Clean Code establecidos.

---

## 📄 Licencia

Proyecto de Hackathon Flutter - Abril 2026

---

## 📞 Contacto

Para preguntas sobre la implementación, consulta:
- `REFACTORING_SOLID.dart` - Arquitectura
- `INSTALLATION_GUIDE.dart` - Instalación
- Comentarios inline en servicios

---

**¡Listo para presentar en el Hackathon! 🚀**
