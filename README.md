# Bancos API

Una aplicación Ruby on Rails que proporciona una API RESTful para gestionar bancos y encontrar el banco más cercano a una ubicación específica.

## 🎯 Descripción

Esta aplicación resuelve el desafío de identificar el banco más cercano a la ubicación de un cliente. Cuando la distancia al banco más cercano supera los 10km, el sistema notifica este hecho para análisis posterior.

## 🚀 Características

- **CRUD de Bancos**: Creación y lectura de entidades Banco
- **Búsqueda por proximidad**: Encuentra el banco más cercano a coordenadas específicas
- **Notificaciones**: Alerta cuando la distancia supera el límite configurable
- **Validaciones**: Coordenadas geográficas válidas y datos requeridos
- **API Documentada**: Endpoints bien documentados para consumo externo
- **Tests Completos**: Cobertura de tests para modelos, controladores y servicios

## 🛠 Tecnologías

- **Ruby**: 3.3.9
- **Rails**: 8.0.2.1
- **PostgreSQL**: 17.2
- **Docker & Docker Compose**: Para desarrollo y despliegue
- **RSpec**: Framework de testing
- **FactoryBot**: Factories para tests
- **Faker**: Datos de prueba realistas
- **Geocoder**: Cálculos de distancia geográfica

## 📋 Requisitos

- Docker
- Docker Compose

## 🚀 Instalación y Configuración

### 1. Clonar el repositorio
```bash
git clone <repository-url>
cd tpaga
```

### 2. Iniciar los servicios con Docker Compose
```bash
docker compose up -d
```

### 3. Instalar dependencias
```bash
docker compose exec tpaga_app bundle install
```

### 4. Configurar la base de datos
```bash
docker compose exec tpaga_app rails db:create
docker compose exec tpaga_app rails db:migrate
docker compose exec tpaga_app rails db:seed
```

### 5. Verificar que todo funciona
```bash
docker compose exec tpaga_app bundle exec rspec
```

## 📚 API Endpoints

### Documentación
- `GET /api/documentacion` - Documentación completa de la API
- `GET /api/documentacion/estadisticas` - Estadísticas de los bancos

### Bancos
- `POST /api/bancos` - Crear un nuevo banco
- `GET /api/bancos/:id` - Obtener un banco por ID
- `GET /api/bancos/cercano` - Encontrar el banco más cercano

## 🔧 Uso de la API

### Crear un Banco
```bash
curl -X POST http://localhost:5000/api/bancos \
  -H "Content-Type: application/json" \
  -d '{
    "banco": {
      "nombre": "Banco de Bogotá",
      "direccion": "Calle 72 # 10-07, Bogotá",
      "latitud": 4.7110,
      "longitud": -74.0721,
      "evaluacion": 4.5
    }
  }'
```

### Obtener un Banco
```bash
curl http://localhost:5000/api/bancos/1
```

### Encontrar Banco Más Cercano
```bash
curl "http://localhost:5000/api/bancos/cercano?latitud=4.7110&longitud=-74.0721&limite_km=10.0"
```

### Ver Documentación
```bash
curl http://localhost:5000/api/documentacion
```

## 🧪 Ejecutar Tests

```bash
# Todos los tests
docker compose exec tpaga_app bundle exec rspec

# Tests específicos
docker compose exec tpaga_app bundle exec rspec spec/models/
docker compose exec tpaga_app bundle exec rspec spec/controllers/
docker compose exec tpaga_app bundle exec rspec spec/services/
```

## 📊 Estructura del Proyecto

```
app/
├── controllers/
│   └── api/
│       ├── bancos_controller.rb      # Controlador principal de la API
│       └── documentacion_controller.rb # Documentación de la API
├── models/
│   └── banco.rb                      # Modelo Banco con validaciones y métodos
├── services/
│   └── banco_service.rb              # Lógica de negocio
└── views/

spec/
├── factories/
│   └── bancos.rb                     # Factories para tests
├── models/
│   └── banco_spec.rb                 # Tests del modelo
├── controllers/
│   └── api/
│       └── bancos_controller_spec.rb # Tests del controlador
└── services/
    └── banco_service_spec.rb         # Tests del servicio

db/
├── migrate/
│   └── create_bancos.rb              # Migración de la tabla bancos
└── seeds.rb                          # Datos de prueba
```

## 🏗 Arquitectura

### Modelo Banco
- **Validaciones**: Nombre, dirección, coordenadas geográficas válidas
- **Métodos**: Cálculo de distancia, búsqueda del más cercano
- **Scopes**: Ordenamiento por evaluación, filtros por evaluación mínima

### Controlador API
- **Endpoints RESTful**: Create, Show, Búsqueda por proximidad
- **Manejo de errores**: Respuestas JSON consistentes
- **Validaciones**: Parámetros requeridos y rangos válidos

### Servicio BancoService
- **Lógica de negocio**: Separada del controlador
- **Notificaciones**: Logging de distancias excesivas
- **Estadísticas**: Métricas de los bancos

## 🔍 Funcionalidades Clave

### Cálculo de Distancia
Utiliza la fórmula de Haversine para calcular la distancia entre dos puntos geográficos:

```ruby
def distancia_a(lat, lng)
  # Fórmula de Haversine para distancia entre coordenadas
  # Retorna distancia en kilómetros
end
```

### Búsqueda del Más Cercano
```ruby
Banco.mas_cercano_a(latitud, longitud, limite_km = 10.0)
```

### Notificaciones
Cuando la distancia supera el límite configurado, se registra en el log:
```
ALERTA: Banco más cercano 'Nombre Banco' está a X.XXkm del punto (lat, lng) - Supera el límite de Ykm
```

## 📈 Estadísticas Disponibles

- Total de bancos
- Promedio de evaluación
- Bancos con alta evaluación (≥4.0)
- Porcentaje de bancos con alta evaluación

## 🔧 Configuración

### Variables de Entorno
- `DATABASE_HOST`: Host de la base de datos
- `DATABASE_USERNAME`: Usuario de la base de datos
- `DATABASE_PASSWORD`: Contraseña de la base de datos
- `DATABASE_NAME`: Nombre de la base de datos

### Límites Configurables
- **Límite de distancia por defecto**: 10km
- **Rangos de coordenadas**: Latitud (-90 a 90), Longitud (-180 a 180)
- **Evaluación**: 0 a 5 estrellas

## 🚀 Despliegue

### Desarrollo
```bash
docker compose up -d
```

### Producción
1. Configurar variables de entorno de producción
2. Ejecutar migraciones
3. Configurar servidor web (Nginx, Apache)
4. Configurar SSL/TLS

## 🤝 Contribución

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 📞 Contacto

Para preguntas o soporte, contactar al equipo de desarrollo.

---

**Desarrollado con ❤️ usando Ruby on Rails**
