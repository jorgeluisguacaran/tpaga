# Serializers

Este directorio contiene todos los serializers de la aplicación para la serialización de objetos a JSON.

## Estructura

### Serializers Base
- `application_serializer.rb` - Serializer base con funcionalidades comunes
- `error_serializer.rb` - Para respuestas de error estandarizadas
- `success_serializer.rb` - Para respuestas de éxito estandarizadas

### Serializers de Modelos
- `banco_serializer.rb` - Serializer básico para el modelo Banco
- `banco_cercano_serializer.rb` - Serializer específico para respuestas de banco cercano

## Uso

### En Controladores

```ruby
# Serialización básica usando el serializer directamente
render json: {
  success: true,
  data: BancoSerializer.new(@banco).as_json
}

# Respuestas de éxito
render json: {
  success: true,
  message: 'Operación exitosa',
  data: BancoSerializer.new(@banco).as_json
}

# Respuestas de error
render json: {
  success: false,
  error: 'Mensaje de error'
}, status: :bad_request
```

### Serialización Automática

Los serializers se aplican manualmente para control total:

```ruby
# Usar el serializer específico del modelo
banco_data = BancoSerializer.new(@banco).as_json

# Usar el serializer con contexto adicional
banco_detailed = BancoDetailedSerializer.new(@banco,
  distancia_km: 5.2,
  dentro_del_radio: true
).as_json
```

## Configuración

La configuración global se encuentra en `config/initializers/active_model_serializers.rb`.

### Configuración Actual:
- **Adaptador**: JSON
- **Timestamps**: Incluidos por defecto
- **Formato de timestamps**: ISO8601
- **Root**: Deshabilitado para evitar problemas con hashes

## Convenciones

1. Todos los serializers heredan de `ApplicationSerializer`
2. Los serializers de modelos usan el nombre del modelo + "Serializer"
3. Los serializers especializados usan nombres descriptivos
4. Los atributos opcionales se excluyen automáticamente si no están presentes
5. Las coordenadas se convierten automáticamente a float

## Beneficios

- **Código más limpio** en los controladores
- **Respuestas JSON consistentes** en toda la API
- **Separación de responsabilidades** (lógica de presentación separada)
- **Reutilización de código** para diferentes endpoints
- **Mantenibilidad mejorada**
- **Control granular** sobre la serialización

## Ejemplo de Respuesta

```json
{
  "success": true,
  "data": {
    "id": 1,
    "nombre": "Banco de Bogotá",
    "direccion": "Calle 72 # 10-07, Bogotá",
    "latitud": 4.711,
    "longitud": -74.0721,
    "created_at": "2025-08-25T19:29:04.349Z",
    "updated_at": "2025-08-25T19:29:04.349Z"
  }
}
```
