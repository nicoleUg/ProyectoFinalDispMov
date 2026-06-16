#  SaaS Restaurante

## 1. Organización de Carpetas (Folders & Files)

###  A. Backend (NestJS)
El backend está estructurado bajo los principios de modularidad e inyección de dependencias de NestJS. La carpeta principal es `src/`:

```text
src/
│
├── core/                       # Configuraciones globales, infraestructura y seguridad transversal
│   ├── guards/                 # Guardianes de seguridad (ej. JwtAuthGuard, RolesGuard para rutas Admin)
│   ├── interceptors/           # Interceptores de peticiones (estandarización de JSONs de respuesta)
│   ├── filters/                # Filtros globales para manejo de excepciones (ej. HttpErrorFilter)
│   └── database/               # Configuración de base de datos (PostgreSQL/Firebase Data Connect)
│
├── modules/                    # Módulos encapsulados que representan la lógica del negocio
│   │
│   ├── auth/                   # Módulo de Autenticación y Seguridad
│   │   ├── controllers/        # auth.controller.ts (Endpoints /login, /refresh)
│   │   ├── services/           # auth.service.ts (Generación y validación de tokens JWT)
│   │   ├── repositories/       # auth.repository.ts (Consultas y transacciones sobre usuarios)
│   │   ├── dto/                # DTOs para validación de entrada (ej. login-request.dto.ts)
│   │   ├── entities/           # user.entity.ts (Entidad de BD / ORM)
│   │   └── auth.module.ts      # Contenedor que agrupa y expone los componentes de Auth
│   │
│   ├── menu/                   # Módulo de Catálogo de Productos y Categorías
│   │   ├── controllers/        # menu.controller.ts (Endpoints /menu)
│   │   ├── services/           # menu.service.ts (Negocio, filtrados por restaurant_id)
│   │   ├── repositories/       # menu.repository.ts (Acceso a base de datos de productos)
│   │   ├── dto/                # create-product.dto.ts
│   │   └── menu.module.ts      # Contenedor del catálogo de menús
│   │
│   └── orders/                 # Módulo de Pedidos e integración offline
│       ├── controllers/        # orders.controller.ts (Recibe y procesa la cola de sincronización)
│       ├── services/           # orders.service.ts (Validación de stock y recálculo de precios)
│       ├── repositories/       # orders.repository.ts (Persistencia de órdenes y detalles)
│       ├── dto/                # sync-orders.dto.ts
│       └── orders.module.ts    # Contenedor del módulo de pedidos
│
├── app.module.ts               # Módulo raíz del backend que importa todos los submódulos
└── main.ts                     # Punto de entrada de la aplicación NestJS
```

### B. Frontend (Flutter)
El frontend implementa **Clean Architecture** organizada por **features** (características del negocio), manteniendo una clara separación entre los datos, el dominio de negocio y la presentación.

```text
lib/
├── Core/                       # Configuración e infraestructura global del App
│   ├── constans/               # Constantes de diseño, colores y URLs de API
│   ├── database/               # Instancia y configuración de la BD Drift (SQLite)
│   ├── network/                # Cliente HTTP configurado (Dio) con reintentos y cabeceras
│   ├── router/                 # Configuración de navegación (go_router)
│   └── secure_storage/         # Almacenamiento seguro de tokens y credenciales locales
│
└── features/                   # Funcionalidades modulares del negocio
    │
    ├── auth/                   # Módulo de Autenticación de Usuarios
    │
    ├── menu/                   # MÓDULO DE CATÁLOGO (Visualización del menú)
    │   ├── data/
    │   │   ├── datasource/
    │   │   ├── models/
    │   │   └── repositories/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   └── presentation/
    │       ├── bloc/
    │       ├── pages/
    │       └── widgets/
    │
    ├── cart/                   # MÓDULO DE CARRITO DE COMPRAS (Gestión local reactiva)
    │   ├── data/
    │   │   ├── datasource/
    │   │   ├── models/
    │   │   └── repositories/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   └── presentation/
    │       ├── cubit/
    │       ├── pages/
    │       └── widgets/
    │
    ├── orders/                 # MÓDULO DE PEDIDOS Y SINCRONIZACIÓN OFFLINE-FIRST
    │   ├── data/
    │   │   ├── datasource/
    │   │   ├── models/
    │   │   └── repositories/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   └── presentation/
    │       ├── bloc/
    │       ├── pages/
    │       └── widgets/
    │
    └── settings/                 # MÓDULO DE CONFIGURACIÓN E INFORMACIÓN
        ├── data/
        │   ├── datasource/       # settings_remote_datasource.dart (Para leer info del restaurante de la API)
        │   ├── models/           # restaurant_info_model.dart, user_preferences_model.dart
        │   └── repositories/     # settings_repository_impl.dart
        ├── domain/
        │   ├── entities/         # restaurant_info_entity.dart
        │   ├── repositories/     # settings_repository.dart
        │   └── usecases/         # get_restaurant_info_usecase.dart, update_restaurant_settings_usecase.dart
        └── presentation/
            ├── bloc/             # settings_cubit.dart (Suele ser más práctico un Cubit aquí)
            ├── pages/            # about_us_page.dart, admin_settings_page.dart, terms_page.dart
            └── widgets/          # info_card_widget.dart, toggle_switch_setting.dart
```
