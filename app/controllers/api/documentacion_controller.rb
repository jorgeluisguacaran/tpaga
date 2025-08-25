class Api::DocumentacionController < ApplicationController
  # GET /api/documentacion
  def index
    render json: {
      success: true,
      data: {
        nombre: "Bancos API",
        version: "1.0.0",
        descripcion: "API para gestión de bancos y búsqueda del banco más cercano",
        endpoints: [
          {
            metodo: "POST",
            ruta: "/api/bancos",
            descripcion: "Crear un nuevo banco",
            parametros: {
              banco: {
                nombre: "string (requerido, 2-100 caracteres)",
                direccion: "string (requerido, 5-200 caracteres)",
                latitud: "decimal (requerido, -90 a 90)",
                longitud: "decimal (requerido, -180 a 180)",
                evaluacion: "decimal (opcional, 0 a 5)"
              }
            },
            ejemplo: {
              banco: {
                nombre: "Banco de Bogotá",
                direccion: "Calle 123 # 45-67, Bogotá",
                latitud: 4.7110,
                longitud: -74.0721,
                evaluacion: 4.5
              }
            }
          },
          {
            metodo: "GET",
            ruta: "/api/bancos/:id",
            descripcion: "Obtener un banco por ID",
            parametros: {
              id: "integer (requerido)"
            },
            ejemplo: "/api/bancos/1"
          },
          {
            metodo: "GET",
            ruta: "/api/bancos/cercano",
            descripcion: "Encontrar el banco más cercano a un punto",
            parametros: {
              latitud: "decimal (requerido, -90 a 90)",
              longitud: "decimal (requerido, -180 a 180)",
              limite_km: "decimal (opcional, por defecto 10.0)"
            },
            ejemplo: "/api/bancos/cercano?latitud=4.7110&longitud=-74.0721&limite_km=5.0"
          },
          {
            metodo: "GET",
            ruta: "/api/documentacion/estadisticas",
            descripcion: "Obtener estadísticas de los bancos",
            parametros: "Ninguno"
          }
        ],
        respuestas: {
          exito: {
            success: true,
            data: { /* datos del recurso */ }
          },
          error: {
            success: false,
            error: "Mensaje de error",
            details: ["Detalles adicionales"]
          }
        },
        codigos_estado: {
          "200": "OK - Operación exitosa",
          "201": "Created - Recurso creado exitosamente",
          "400": "Bad Request - Parámetros inválidos",
          "404": "Not Found - Recurso no encontrado",
          "422": "Unprocessable Entity - Error de validación"
        }
      }
    }
  end

  # GET /api/documentacion/estadisticas
  def estadisticas
    service = BancoService.new
    stats = service.estadisticas

    render json: {
      success: true,
      data: {
        estadisticas: stats,
        timestamp: Time.current.iso8601
      }
    }
  end
end
