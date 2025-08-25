# Arquitectura de la Aplicación Bancos API

## 🏗️ Visión General

Esta aplicación implementa una API REST para la gestión de bancos con funcionalidad especial de búsqueda por proximidad geográfica. La arquitectura sigue los principios de Rails y patrones de diseño establecidos para APIs.

## 📐 Patrones de Diseño Utilizados

### 1. **Model-View-Controller (MVC)**
- **Modelo (Banco)**: Encapsula la lógica de negocio, validaciones y cálculos geográficos
- **Controlador (Api::BancosController)**: Maneja las peticiones HTTP y respuestas JSON
- **Vista**: Representada por respuestas JSON estructuradas

### 2. **Service Layer Pattern**
- **BancoService**: Encapsula lógica de negocio compleja y operaciones que involucran múltiples modelos
- Separa la lógica de negocio de los controladores
- Facilita testing y reutilización de código

### 3. **Repository Pattern** (implícito)
- Los modelos actúan como repositorios para el acceso a datos
- Scopes proporcionan interfaces específicas para consultas comunes

## 🏛️ Estructura de Capas

```
┌─────────────────────────────────────┐
│           API Layer                 │
│  (Controllers + Routes)             │
├─────────────────────────────────────┤
│         Service Layer               │
│     (BancoService)                  │
├─────────────────────────────────────┤
│         Model Layer                 │
│       (Banco + Validations)         │
├─────────────────────────────────────┤
│        Database Layer               │
│    (PostgreSQL + Migrations)        │
└─────────────────────────────────────┘
```

## 🔧 Componentes Principales

### 1. **Modelo Banco**
```ruby
class Banco < ApplicationRecord
  # Responsabilidades:
  # - Validaciones de datos
  # - Cálculos geográficos (fórmula de Haversine)
  # - Scopes para consultas comunes
  # - Métodos de instancia para operaciones específicas
end
```

**Características:**
- **Validaciones robustas**: Coordenadas geográficas, longitudes de texto, rangos numéricos
- **Cálculos geográficos**: Implementación de la fórmula de Haversine para distancias precisas
- **Scopes optimizados**: Consultas predefinidas para casos de uso comunes
- **Métodos de clase**: Funcionalidad para encontrar el banco más cercano

### 2. **Controlador API**
```ruby
class Api::BancosController < ApplicationController
  # Responsabilidades:
  # - Manejo de peticiones HTTP
  # - Validación de parámetros
  # - Respuestas JSON estructuradas
  # - Manejo de errores HTTP
end
```

**Características:**
- **Respuestas consistentes**: Estructura JSON uniforme con campos `success`, `data`, `error`
- **Validación de entrada**: Verificación de parámetros requeridos y rangos válidos
- **Códigos de estado HTTP**: Uso apropiado de códigos 200, 201, 400, 404, 422
- **Strong Parameters**: Prevención de asignación masiva no autorizada

### 3. **Servicio de Negocio**
```ruby
class BancoService
  # Responsabilidades:
  # - Lógica de negocio compleja
  # - Notificaciones y logging
  # - Manejo centralizado de errores
  # - Cálculos de estadísticas
end
```

**Características:**
- **Separación de responsabilidades**: Lógica de negocio separada de controladores
- **Notificaciones**: Sistema de alertas para distancias excesivas
- **Manejo de errores**: Centralización de errores con atributo `@errors`
- **Estadísticas**: Cálculos de métricas de negocio

## 🌐 API Design

### Principios REST
- **Recursos**: `/api/bancos` representa la colección de bancos
- **Verbos HTTP**: GET, POST para operaciones de lectura y creación
- **Estados HTTP**: Códigos apropiados para cada situación
- **JSON**: Formato de intercambio de datos

### Estructura de Respuestas
```json
{
  "success": true|false,
  "data": { ... },
  "error": "mensaje de error",
  "details": ["detalles adicionales"]
}
```

### Endpoints Disponibles
1. `POST /api/bancos` - Crear banco
2. `GET /api/bancos/:id` - Obtener banco por ID
3. `GET /api/bancos/cercano` - Buscar banco más cercano
4. `GET /api/documentacion` - Documentación de la API
5. `GET /api/documentacion/estadisticas` - Estadísticas

## 🗄️ Diseño de Base de Datos

### Tabla `bancos`
```sql
CREATE TABLE bancos (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  direccion VARCHAR(200) NOT NULL,
  latitud DECIMAL(10,8) NOT NULL,
  longitud DECIMAL(11,8) NOT NULL,
  evaluacion DECIMAL(3,2) DEFAULT 0.0,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

### Índices
- `(latitud, longitud)`: Optimiza consultas geográficas
- `nombre`: Optimiza búsquedas por nombre

### Consideraciones de Diseño
- **Precisión geográfica**: Decimales con alta precisión para cálculos exactos
- **Validaciones a nivel DB**: Constraints NOT NULL y tipos apropiados
- **Índices estratégicos**: Optimización para consultas frecuentes

## 🔍 Algoritmo de Búsqueda por Proximidad

### Fórmula de Haversine
```ruby
def distancia_a(lat, lng)
  # Constantes
  rad_per_deg = Math::PI / 180
  earth_radius_km = 6371

  # Conversión a radianes
  lat1_rad = latitud * rad_per_deg
  lat2_rad = lat * rad_per_deg
  delta_lat_rad = (lat - latitud) * rad_per_deg
  delta_lng_rad = (lng - longitud) * rad_per_deg

  # Fórmula de Haversine
  a = Math.sin(delta_lat_rad / 2) * Math.sin(delta_lat_rad / 2) +
      Math.cos(lat1_rad) * Math.cos(lat2_rad) *
      Math.sin(delta_lng_rad / 2) * Math.sin(delta_lng_rad / 2)

  c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

  (earth_radius_km * c).round(2)
end
```

### Proceso de Búsqueda
1. **Validación**: Verificar coordenadas de entrada
2. **Cálculo**: Calcular distancia a todos los bancos
3. **Selección**: Encontrar el banco con distancia mínima
4. **Notificación**: Alertar si supera el límite configurado
5. **Respuesta**: Retornar información estructurada

## 🧪 Testing Strategy

### Cobertura de Tests
- **Modelo**: Validaciones, scopes, métodos de instancia y clase
- **Controlador**: Endpoints, respuestas, manejo de errores
- **Servicio**: Lógica de negocio, notificaciones, estadísticas
- **Factories**: Datos de prueba realistas con Faker

### Patrones de Testing
- **Arrange-Act-Assert**: Estructura clara de tests
- **Contextos**: Organización por escenarios
- **Mocks**: Simulación de dependencias externas
- **Factories**: Generación de datos de prueba

## 🔒 Seguridad y Validaciones

### Validaciones de Entrada
- **Coordenadas geográficas**: Rangos válidos (-90 a 90, -180 a 180)
- **Longitudes de texto**: Límites apropiados para campos
- **Tipos de datos**: Conversión y validación de tipos
- **Parámetros requeridos**: Verificación de presencia

### Prevención de Vulnerabilidades
- **Strong Parameters**: Prevención de asignación masiva
- **Validaciones de modelo**: Doble validación (cliente y servidor)
- **Sanitización**: Limpieza de datos de entrada
- **Logging**: Registro de operaciones para auditoría

## 📈 Escalabilidad y Performance

### Optimizaciones Implementadas
- **Índices de base de datos**: Consultas geográficas optimizadas
- **Cálculos eficientes**: Fórmula de Haversine optimizada
- **Respuestas JSON**: Estructura ligera y consistente
- **Validaciones tempranas**: Falla rápida en datos inválidos

### Consideraciones Futuras
- **Caching**: Redis para resultados frecuentes
- **Paginación**: Para grandes volúmenes de datos
- **Búsqueda espacial**: Índices GiST para PostgreSQL
- **Microservicios**: Separación por dominio de negocio

## 🚀 Deployment y Configuración

### Docker
- **Contenedorización**: Aislamiento de dependencias
- **Docker Compose**: Orquestación de servicios
- **Volúmenes**: Persistencia de datos
- **Networking**: Comunicación entre servicios

### Variables de Entorno
- **Configuración de BD**: Host, usuario, contraseña, nombre
- **Configuración de Rails**: Entorno, secretos
- **Configuración de API**: Límites, timeouts

## 📚 Documentación

### Documentación de Código
- **YARD**: Documentación de métodos y clases
- **Comentarios**: Explicaciones de lógica compleja
- **Ejemplos**: Casos de uso en documentación
- **README**: Guía de instalación y uso

### Documentación de API
- **Auto-documentación**: Endpoint `/api/documentacion`
- **Ejemplos de uso**: Casos prácticos incluidos
- **Códigos de respuesta**: Documentación completa
- **Parámetros**: Descripción detallada de entrada

## 🔄 Flujo de Datos

```
Cliente HTTP → Controller → Service → Model → Database
     ↑                                 ↓
     └── JSON Response ←── JSON ←── Hash ←── ActiveRecord
```

### Ejemplo: Búsqueda de Banco Más Cercano
1. **Cliente**: Envía GET `/api/bancos/cercano?lat=4.7110&lng=-74.0721`
2. **Controller**: Valida parámetros y llama al modelo
3. **Model**: Calcula distancias usando fórmula de Haversine
4. **Service**: Notifica si supera límite (opcional)
5. **Controller**: Formatea respuesta JSON
6. **Cliente**: Recibe respuesta estructurada

Esta arquitectura proporciona una base sólida, mantenible y escalable para la API de bancos, siguiendo las mejores prácticas de Rails y patrones de diseño establecidos.
