# Bancos API

## 📋 Descripción

Bancos API es una aplicación Ruby on Rails que proporciona una API REST para la gestión de bancos con funcionalidad especial de búsqueda por proximidad geográfica. La aplicación permite crear bancos, consultarlos por ID y encontrar el banco más cercano a un punto específico usando coordenadas geográficas.

## ✨ Características

- **CRUD de Bancos**: Creación y consulta de bancos por ID
- **Búsqueda por Proximidad**: Encuentra el banco más cercano a coordenadas específicas
- **Cálculos Geográficos**: Utiliza la fórmula de Haversine para cálculos precisos de distancia
- **Notificaciones**: Alerta cuando la distancia supera el límite configurado (10km por defecto)
- **API Documentada**: Documentación automática de endpoints
- **Validaciones Robustas**: Validación de coordenadas geográficas y datos de entrada
- **Tests Completos**: Cobertura de tests para todos los componentes

## 🛠️ Tecnologías

- **Ruby 3.3.9**: Lenguaje de programación
- **Rails 8.0.2.1**: Framework web
- **PostgreSQL 17.2**: Base de datos
- **Docker & Docker Compose**: Contenedorización
- **RSpec**: Framework de testing
- **FactoryBot**: Generación de datos de prueba
- **Faker**: Datos de prueba realistas

## 🚀 Instalación

### Prerrequisitos

- Docker
- Docker Compose

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd tpaga
   ```

2. **Construir y levantar los contenedores**
   ```bash
   docker compose up --build
   ```

3. **Ejecutar migraciones**
   ```bash
   docker compose exec tpaga_app rails db:migrate
   ```

4. **Cargar datos de ejemplo**
   ```bash
   docker compose exec tpaga_app rails db:seed
   ```

5. **Ejecutar tests**
   ```bash
   docker compose exec tpaga_app bundle exec rspec
   ```

## 📚 API Endpoints

### 1. Crear Banco
```http
POST /api/bancos
Content-Type: application/json

{
  "banco": {
    "nombre": "Banco de Bogotá",
    "direccion": "Calle 72 # 10-07, Bogotá",
    "latitud": 4.7110,
    "longitud": -74.0721
  }
}
```

**Respuesta exitosa (201):**
```json
{
  "success": true,
  "message": "Banco creado exitosamente",
  "data": {
    "id": 1,
    "nombre": "Banco de Bogotá",
    "direccion": "Calle 72 # 10-07, Bogotá",
    "latitud": 4.711,
    "longitud": -74.0721,
    "created_at": "2025-08-24T01:46:14.460Z",
    "updated_at": "2025-08-24T01:46:14.460Z"
  }
}
```

### 2. Obtener Banco por ID
```http
GET /api/bancos/:id
```

**Respuesta exitosa (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "nombre": "Banco de Bogotá",
    "direccion": "Calle 72 # 10-07, Bogotá",
    "latitud": 4.711,
    "longitud": -74.0721,
    "created_at": "2025-08-24T01:46:14.460Z",
    "updated_at": "2025-08-24T01:46:14.460Z"
  }
}
```

### 3. Buscar Banco Más Cercano
```http
GET /api/bancos/cercano?latitud=4.7110&longitud=-74.0721&limite_km=5.0
```

**Respuesta exitosa (200):**
```json
{
  "success": true,
  "data": {
    "banco": {
      "id": 1,
      "nombre": "Banco de Bogotá",
      "direccion": "Calle 72 # 10-07, Bogotá",
      "latitud": "4.711",
      "longitud": "-74.0721"
    },
    "distancia_km": 0.0,
    "supera_limite": false,
    "limite_km": 5.0
  }
}
```

### 4. Documentación de la API
```http
GET /api/documentacion
```

### 5. Estadísticas
```http
GET /api/documentacion/estadisticas
```

**Respuesta:**
```json
{
  "success": true,
  "data": {
    "estadisticas": {
      "total_bancos": 10
    },
    "timestamp": "2025-08-24T01:46:14.460Z"
  }
}
```

## 🧪 Testing

### Ejecutar Tests
```bash
# Todos los tests
docker compose exec tpaga_app bundle exec rspec

# Tests específicos
docker compose exec tpaga_app bundle exec rspec spec/models/
docker compose exec tpaga_app bundle exec rspec spec/controllers/
docker compose exec tpaga_app bundle exec rspec spec/services/
```

### Cobertura de Tests
- **Modelo Banco**: Validaciones, cálculos geográficos, métodos de instancia y clase
- **Controlador API**: Endpoints, respuestas JSON, manejo de errores
- **Servicio**: Lógica de negocio, notificaciones, estadísticas
- **Factories**: Datos de prueba realistas

## 📁 Estructura del Proyecto

```
tpaga/
├── app/
│   ├── controllers/
│   │   └── api/
│   │       ├── bancos_controller.rb
│   │       └── documentacion_controller.rb
│   ├── models/
│   │   └── banco.rb
│   └── services/
│       └── banco_service.rb
├── config/
│   └── routes.rb
├── db/
│   ├── migrate/
│   └── seeds.rb
├── spec/
│   ├── factories/
│   ├── models/
│   ├── controllers/
│   └── services/
├── docker-compose.yml
└── README.md
```

## 🏗️ Arquitectura

### Patrones de Diseño
- **MVC**: Separación de responsabilidades
- **Service Layer**: Lógica de negocio encapsulada
- **Repository Pattern**: Acceso a datos a través del modelo

### Componentes Principales
1. **Modelo Banco**: Validaciones y cálculos geográficos
2. **Controlador API**: Manejo de peticiones HTTP
3. **Servicio**: Lógica de negocio y notificaciones
4. **Base de Datos**: PostgreSQL con índices optimizados

## 🔍 Funcionalidades Clave

### Búsqueda por Proximidad
- Utiliza la fórmula de Haversine para cálculos precisos
- Notifica cuando la distancia supera el límite configurado
- Permite personalizar el límite de distancia
- Maneja casos edge (sin bancos, coordenadas inválidas)

### Validaciones
- Coordenadas geográficas válidas (-90 a 90, -180 a 180)
- Longitudes de texto apropiadas
- Parámetros requeridos
- Tipos de datos correctos

### Notificaciones
- Logging de distancias excesivas
- Estructura preparada para notificaciones adicionales
- Información detallada para análisis

## 📊 Estadísticas

La API proporciona estadísticas básicas sobre los bancos almacenados:
- Total de bancos
- Timestamp de la consulta

## ⚙️ Configuración

### Variables de Entorno
```bash
# Base de datos
DATABASE_URL=postgresql://user:password@host:port/database

# Rails
RAILS_ENV=development
SECRET_KEY_BASE=your_secret_key
```

### Docker
- **Contenedor Rails**: Puerto 3000
- **Contenedor PostgreSQL**: Puerto 5432
- **Volúmenes**: Persistencia de datos

## 🚀 Deployment

### Producción
1. Configurar variables de entorno
2. Ejecutar migraciones
3. Precompilar assets
4. Configurar servidor web (Nginx/Apache)

### Docker Production
```bash
docker compose -f docker-compose.prod.yml up -d
```

## 🤝 Contribución

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 📞 Contacto

- **Desarrollador**: [Tu Nombre]
- **Email**: [tu.email@ejemplo.com]
- **Proyecto**: [https://github.com/usuario/tpaga]

---

**Nota**: Esta aplicación fue desarrollada como parte de un desafío técnico para demostrar habilidades en Ruby on Rails, APIs REST, testing y buenas prácticas de desarrollo.
