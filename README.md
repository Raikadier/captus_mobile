# Captus — Mobile (Flutter)

Aplicación móvil del sistema académico **Captus**, construida con Flutter.

## Requisitos

- Flutter 3.x o superior
- Dart SDK 3.x
- Android Studio / Xcode para emuladores

## Instalación

```bash
flutter pub get
flutter run
```

Configura la URL del backend en `lib/core/config/app_config.dart` (o el archivo `.env` equivalente del proyecto).

---

## Cuentas de prueba (datos mock)

El backend tiene **555 usuarios de prueba** pre-cargados distribuidos en 5 universidades colombianas reales. Todas las cuentas comparten la misma contraseña.

**Contraseña universal:** `123456789`

### Patrón de emails

| Rol | Formato | Ejemplo |
|---|---|---|
| Estudiante | `firstname.lastname.mock@dominio.edu.co` | `carlos.garcia.mock@unal.edu.co` |
| Profesor | `firstname.lastname.mock@dominio.edu.co` | `maria.rodriguez.mock@udea.edu.co` |
| Admin institución | `admin.[slug].mock@dominio.edu.co` | `admin.uniandes.mock@uniandes.edu.co` |
| Superadmin | — | `admin@captus.dev` / contraseña propia |

> Todos los emails mock contienen `.mock@` — es fácil identificarlos o filtrarlos en Supabase.

### Universidades disponibles

| Institución | Dominio | Slug | Ciudad |
|---|---|---|---|
| Universidad Nacional de Colombia | `unal.edu.co` | `unal` | Bogotá |
| Universidad de Antioquia | `udea.edu.co` | `udea` | Medellín |
| Universidad del Valle | `univalle.edu.co` | `univalle` | Cali |
| Universidad de los Andes | `uniandes.edu.co` | `uniandes` | Bogotá |
| Universidad Popular del Cesar | `unicesar.edu.co` | `unicesar` | Valledupar |

### Ejemplos rápidos para probar

```
# Estudiante — UNAL
Email:    carlos.garcia.mock@unal.edu.co
Password: 123456789

# Estudiante — UdeA
Email:    maria.rodriguez.mock@udea.edu.co
Password: 123456789

# Profesor — Univalle
Email:    ivan.lopez.mock@univalle.edu.co
Password: 123456789

# Admin institución — Uniandes
Email:    admin.uniandes.mock@uniandes.edu.co
Password: 123456789

# Admin institución — Unicesar
Email:    admin.unicesar.mock@unicesar.edu.co
Password: 123456789
```

---

## Roles y accesos

| Rol | Acceso |
|---|---|
| `student` | Tareas, notas, eventos, cursos matriculados, asistente IA |
| `teacher` | Todo lo anterior + gestión de curso, calificaciones, analítica IA |
| `admin` | Panel de institución: cursos, períodos, escala de notas, usuarios |
| `superadmin` | Panel global: todas las instituciones, auditoría, estadísticas |
