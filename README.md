# StockMaster — App de Gestión de Inventario (Flutter)

Aplicación móvil de gestión de inventario desarrollada en Flutter, con backend en Django REST Framework. Incluye panel de administración (catálogo, inventario, compras, ventas, clientes) y zona pública para el usuario final.

## Requisitos

- **Flutter SDK** 3.x o superior 
# macOS con Homebrew
brew install flutter

# Windows — descargar el SDK desde flutter.dev/install
 Luego añadir al PATH:
C:\flutter\bin

# Linux
sudo snap install flutter --classic

# Verificar instalación
flutter doctor
- Un editor compatible: VS Code, Android Studio, o similar
- Un emulador Android/iOS configurado, o un dispositivo físico con depuración USB habilitada
- Conexión a internet (la app consume una API remota, no funciona 100% offline)

Verifica tu instalación con:

```bash
flutter doctor
```

Resuelve cualquier ❌ que te marque antes de continuar.

## 🚀 Instalación

1. Clona el repositorio:
   ```bash
   git clone <url-del-repositorio>
   cd flutter_inventario_app
   ```

2. Instala las dependencias:
   ```bash
   flutter pub get
   ```

3. Verifica que tengas un dispositivo o emulador disponible:
   ```bash
   flutter devices
   ```

## ▶️ Comandos principales

| Comando | Qué hace |
|---|---|
| `flutter pub get` | Instala/actualiza las dependencias del proyecto |
| `flutter run` | Ejecuta la app en modo debug en el dispositivo/emulador conectado |
| `flutter run --release` | Ejecuta la app en modo release (más rápido, sin hot reload) |
| `flutter build apk` | Genera un APK de Android para distribución |
| `flutter build ios` | Genera el build de iOS (requiere macOS + Xcode) |
| `flutter analyze` | Revisa el código en busca de errores y warnings |
| `flutter clean` | Limpia archivos de build (útil si algo no compila tras cambios grandes) |

## ⚙️ Configuración de la API

La app consume una API REST (Django REST Framework) ya desplegada. La URL base está definida como constante en:

```
lib/data/remote/api/dio_client.dart
```

Actualmente apunta a:

```
https://stock-master.nael.live/api
```

Si necesitas apuntar a otro backend (por ejemplo, uno corriendo en local durante desarrollo), edita esa constante directamente en el archivo. Ejemplo:

```dart
// lib/data/remote/api/dio_client.dart
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://stock-master.nael.live/api', // 👈 cambia aquí si es necesario
    // ...
  ));
  return dio;
});
```

> **Nota:** el proyecto no usa `.env` ni `--dart-define` actualmente — la URL está fija en el código. Si trabajas en equipo con distintos entornos (local/staging/producción), considera migrar esto a variables de entorno más adelante.

## 🔑 Credenciales de prueba

Para iniciar sesión y probar la app con un usuario de tipo Staff/Admin:

```
Usuario:     admin
Contraseña:  admin123
```

> Estas son credenciales de **prueba/desarrollo**. No uses estas credenciales en un entorno de producción real.

## 🔌 Cómo se conecta la app a la API

- La app usa el paquete **Dio** como cliente HTTP, configurado en `lib/data/remote/api/dio_client.dart`.
- La autenticación es mediante **JWT** (`djangorestframework-simplejwt`): al iniciar sesión (`/auth/login/`), el backend devuelve un token que Dio adjunta automáticamente en las peticiones siguientes.
- Cada módulo (Clientes, Turno de Caja, Ventas, Cotizaciones, Métodos de Pago, Devoluciones, etc.) tiene su propio **datasource** en `lib/data/remote/api/`, que llama a los endpoints correspondientes bajo `/api/...`.
- Puedes explorar la documentación interactiva de la API (Swagger) en:
  ```
  https://stock-master.nael.live/api/docs/
  ```

## 📁 Estructura del proyecto (resumen)

```
lib/
├── data/remote/api/        # Datasources (llamadas HTTP a la API)
├── domain/model/           # Algunos modelos de datos (estructura legada)
├── presentation/
│   ├── domain/model/       # Modelos de datos (estructura actual)
│   ├── providers/          # Estado de la app (Riverpod)
│   ├── screens/            # Pantallas de la app (admin, auth, catálogo, etc.)
│   ├── widgets/             # Componentes reutilizables (formularios, shells)
│   └── navigation/         # Definición de rutas (GoRouter)
└── theme/                  # Colores y tema visual de la app
```

## 🐛 Problemas comunes

- **Error de login / "Bad Request" / timeouts**: el backend puede estar temporalmente caído. Verifica con `https://stock-master.nael.live/api/health/` en el navegador.
- **`flutter pub get` falla**: asegúrate de tener la versión de Flutter/Dart compatible con las dependencias del `pubspec.yaml`.
- **Cambios no se reflejan**: corre `flutter clean && flutter pub get` y vuelve a intentar.