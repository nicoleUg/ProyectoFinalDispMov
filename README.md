# SaaS Restaurante - Cliente Frontend (Flutter)

Este es el cliente móvil y web del sistema **SaaS Restaurante**, desarrollado con **Flutter** utilizando principios de **Clean Architecture** y gestores de estado robustos como **BLoC/Cubit**. La aplicación está diseñada bajo el enfoque **Offline-First**, utilizando una base de datos local Drift (SQLite) sincronizada con el backend para garantizar un rendimiento óptimo y disponibilidad incluso sin conexión a internet.

---

##  Características Principales

*   **Autenticación Segura**: Registro e inicio de sesión de clientes y administradores con persistencia de sesión a través de almacenamiento seguro (`flutter_secure_storage`).
*   **Catálogo Interactivo**: Visualización de categorías y platos del menú con sincronización periódica desde el backend.
*   **Carrito de Compras Local**: Gestión reactiva del carrito, edición de cantidades, notas personalizadas para cocina y cálculo en tiempo real de subtotales/totales.
*   **Historial de Pedidos (`OrderHistoryPage`)**: Vista centralizada de pedidos anteriores organizada por estado.
*   **Pedir de Nuevo (Reorder)**: Clonación inteligente de pedidos anteriores hacia el carrito mediante una consulta local a la base de datos de productos.
*   **Seguimiento en Tiempo Real (`OrderTrackingPage`)**: Monitorización visual del estado del pedido (Pendiente, Preparando, Listo, Entregado) con soporte para calificación de platos.
*   **Soporte de Deep Linking**: Acceso directo al seguimiento de un pedido mediante el esquema `restaurantesaas://orders/:orderId`.
*   **Escáner QR (`TableScanner`)**: Integración de cámara para escanear el código QR de la mesa y asociarlo automáticamente al flujo de compra del cliente.
*   **Favoritos y Reseñas**: Guardado local de platos preferidos y sistema de comentarios con calificación por estrellas.

---

## Organización de Carpetas (Clean Architecture)

El frontend está estructurado por características del negocio (**features**), separando claramente la infraestructura de datos, las reglas de negocio (dominio) y la interfaz de usuario (presentación).

```text
lib/
├── Core/                       # Infraestructura y configuraciones transversales
│   ├── constants/              # Colores, estilos y URL base de la API
│   ├── database/               # Instancia y esquema de la BD Drift (SQLite)
│   ├── network/                # Cliente Dio configurado con interceptores de tokens
│   ├── router/                 # Navegación del app con GoRouter
│   └── secure_storage/         # Almacenamiento seguro de credenciales
│
└── features/                   # Módulos del negocio
    ├── auth/                   # Autenticación e inicio de sesión
    ├── menu/                   # Catálogo de platos y detalles
    ├── cart/                   # Carrito de compras y notas de cocina
    ├── orders/                 # Historial, re-orden y seguimiento de pedidos
    ├── table_scanner/          # Escaneo QR para asociar mesas
    ├── reviews/                # Reseñas y calificaciones de platos
    ├── favorites/              # Gestión de platos favoritos
    └── configuracion-informacion/ # Pantallas legales e informativas del restaurante
```

---

## Requisitos Previos

Asegúrate de contar con el siguiente entorno de desarrollo configurado:

*   **Flutter SDK**: Versión `^3.11.5` o superior.
*   **Dart SDK**: Compatible con la versión de Flutter instalada.
*   **Emulador/Dispositivo Físico**: Android (API 21+), iOS (12.0+) o un Navegador Web (Chrome/Edge).

---

## Configuración y Ejecución (Paso a Paso)

Sigue estos pasos para poner en marcha el proyecto:

### 1. Clonar y Entrar al Proyecto
Abre la terminal en la raíz del proyecto frontend:
```bash
cd saas_restaurante
```

### 2. Instalar Dependencias
Descarga los paquetes necesarios declarados en el `pubspec.yaml`:
```bash
flutter pub get
```

### 3. Generar Código (Drift y Modelos)
Dado que el proyecto utiliza **Drift** como ORM de base de datos local y otros generadores de código, es obligatorio ejecutar `build_runner` para compilar los archivos autogenerados (`.g.dart`):
```bash
dart run build_runner build --delete-conflicting-outputs
```
*(Usa `watch` en lugar de `build` si vas a estar editando el esquema de base de datos activamente).*

### 4. Configurar el Endpoint de la API (Opcional)
Si deseas cambiar la dirección del backend, dirígete a `lib/Core/constants/` (o el archivo de configuración correspondiente) y actualiza la URL base de conexión.

### 5. Ejecutar la Aplicación
Inicia el servidor de desarrollo y ejecuta la aplicación en tu dispositivo objetivo:

*   **Para buscar dispositivos disponibles:**
    ```bash
    flutter devices
    ```
*   **Para ejecutar en el dispositivo por defecto:**
    ```bash
    flutter run
    ```
*   **Para ejecutar en un dispositivo específico (ej. Chrome o Android):**
    ```bash
    flutter run -d chrome
    flutter run -d <device_id>
    ```

---

##  Compilación para Producción

Para compilar la versión optimizada de la aplicación lista para su distribución:

### Android
*   **Generar APK:**
    ```bash
    flutter build apk --release
    ```
*   **Generar Android App Bundle (AAB para Google Play):**
    ```bash
    flutter build appbundle --release
    ```

### Web
*   **Compilar para la Web:**
    ```bash
    flutter build web --release
    ```

### iOS
*   **Compilar para iOS (Requiere macOS y Xcode):**
    ```bash
    flutter build ipa --release
    ```
