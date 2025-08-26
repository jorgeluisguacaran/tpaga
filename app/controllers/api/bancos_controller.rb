# frozen_string_literal: true

# Controller para la gestión de bancos a través de API REST
#
# Este controlador maneja todas las operaciones CRUD para la entidad Banco,
# incluyendo la funcionalidad especial de encontrar el banco más cercano
# a un punto geográfico específico.
#
# Endpoints disponibles:
# - POST /api/bancos - Crear un nuevo banco
# - GET /api/bancos/:id - Obtener un banco por ID
# - GET /api/bancos/cercano - Encontrar el banco más cercano
module Api
  class BancosController < ApplicationController
    before_action :set_banco, only: [:show]

    # ============================================================================
    # ENDPOINTS PÚBLICOS
    # ============================================================================

    # GET /api/bancos/:id
    #
    # Obtiene la información completa de un banco específico por su ID.
    #
    # @param id [Integer] ID del banco a consultar
    # @return [JSON] Información del banco o error si no existe
    #
    # @example Respuesta exitosa (200)
    #   {
    #     "success": true,
    #     "data": {
    #       "id": 1,
    #       "nombre": "Banco de Bogotá",
    #       "direccion": "Calle 72 # 10-07, Bogotá",
    #       "latitud": 4.711,
    #       "longitud": -74.0721,
    #       "created_at": "2025-08-24T01:46:14.460Z",
    #       "updated_at": "2025-08-24T01:46:14.460Z"
    #     }
    #   }
    #
    # @example Respuesta de error (404)
    #   {
    #     "success": false,
    #     "error": "Banco no encontrado"
    #   }
    def show
      render json: {
        success: true,
        data: {
          id: @banco.id,
          nombre: @banco.nombre,
          direccion: @banco.direccion,
          latitud: @banco.latitud.to_f,
          longitud: @banco.longitud.to_f,
          created_at: @banco.created_at,
          updated_at: @banco.updated_at,
        },
      }
    rescue ActiveRecord::RecordNotFound
      render json: {
        success: false,
        error: 'Banco no encontrado',
      }, status: :not_found
    end

    # POST /api/bancos
    #
    # Crea un nuevo banco en la base de datos.
    #
    # @param banco [Hash] Parámetros del banco a crear
    # @option banco [String] :nombre Nombre del banco (2-100 caracteres)
    # @option banco [String] :direccion Dirección del banco (5-200 caracteres)
    # @option banco [Float] :latitud Latitud (-90 a 90)
    # @option banco [Float] :longitud Longitud (-180 a 180)
    # @return [JSON] Banco creado o errores de validación
    #
    # @example Request
    #   POST /api/bancos
    #   Content-Type: application/json
    #   {
    #     "banco": {
    #       "nombre": "Banco de Bogotá",
    #       "direccion": "Calle 72 # 10-07, Bogotá",
    #       "latitud": 4.7110,
    #       "longitud": -74.0721
    #     }
    #   }
    #
    # @example Respuesta exitosa (201)
    #   {
    #     "success": true,
    #     "message": "Banco creado exitosamente",
    #     "data": {
    #       "id": 1,
    #       "nombre": "Banco de Bogotá",
    #       "direccion": "Calle 72 # 10-07, Bogotá",
    #       "latitud": 4.711,
    #       "longitud": -74.0721,
    #       "created_at": "2025-08-24T01:46:14.460Z",
    #       "updated_at": "2025-08-24T01:46:14.460Z"
    #     }
    #   }
    #
    # @example Respuesta de error (422)
    #   {
    #     "success": false,
    #     "error": "Error al crear el banco",
    #     "details": ["Nombre can't be blank"]
    #   }
    def create
      @banco = Banco.new(banco_params)

      if @banco.save
        render json: {
          success: true,
          message: 'Banco creado exitosamente',
          data: {
            id: @banco.id,
            nombre: @banco.nombre,
            direccion: @banco.direccion,
            latitud: @banco.latitud.to_f,
            longitud: @banco.longitud.to_f,
            created_at: @banco.created_at,
            updated_at: @banco.updated_at,
          },
        }, status: :created
      else
        render json: {
          success: false,
          error: 'Error al crear el banco',
          details: @banco.errors.full_messages,
        }, status: :unprocessable_entity
      end
    end

    # GET /api/bancos/cercano
    #
    # Encuentra el banco más cercano a un punto geográfico específico.
    # Utiliza la fórmula de Haversine para calcular distancias y notifica
    # si la distancia supera el límite configurado.
    #
    # @param latitud [Float] Latitud del punto de búsqueda (-90 a 90)
    # @param longitud [Float] Longitud del punto de búsqueda (-180 a 180)
    # @param limite_km [Float] Límite de distancia en kilómetros (opcional, default: 10.0)
    # @return [JSON] Banco más cercano con información de distancia
    #
    # @example Request
    #   GET /api/bancos/cercano?latitud=4.7110&longitud=-74.0721&limite_km=5.0
    #
    # @example Respuesta exitosa (200)
    #   {
    #     "success": true,
    #     "data": {
    #       "banco": {
    #         "id": 1,
    #         "nombre": "Banco de Bogotá",
    #         "direccion": "Calle 72 # 10-07, Bogotá",
    #         "latitud": "4.711",
    #         "longitud": "-74.0721"
    #       },
    #       "distancia_km": 0.0,
    #       "supera_limite": false,
    #       "limite_km": 5.0
    #     }
    #   }
    #
    # @example Respuesta cuando supera el límite
    #   {
    #     "success": true,
    #     "data": {
    #       "banco": { ... },
    #       "distancia_km": 4635.88,
    #       "supera_limite": true,
    #       "limite_km": 10.0
    #     }
    #   }
    #
    # @example Respuesta de error - parámetros faltantes (400)
    #   {
    #     "success": false,
    #     "error": "Los parámetros latitud y longitud son requeridos"
    #   }
    #
    # @example Respuesta de error - coordenadas inválidas (400)
    #   {
    #     "success": false,
    #     "error": "Coordenadas fuera de rango válido (latitud: -90 a 90, longitud: -180 a 180)"
    #   }
    #
    # @example Respuesta de error - no hay bancos (404)
    #   {
    #     "success": false,
    #     "error": "No hay bancos disponibles en la base de datos"
    #   }
    def cercano
      validation_result = validate_cercano_params
      return validation_result if validation_result

      @resultado = Banco.mas_cercano_a(@lat, @lng, @limite_km)

      if @resultado.nil?
        render json: {
          success: false,
          error: 'No hay bancos disponibles en la base de datos',
        }, status: :not_found
      else
        render json: {
          success: true,
          data: {
            banco: {
              id: @resultado[:banco].id,
              nombre: @resultado[:banco].nombre,
              direccion: @resultado[:banco].direccion,
              latitud: @resultado[:banco].latitud.to_f,
              longitud: @resultado[:banco].longitud.to_f,
            },
            distancia_km: @resultado[:distancia_km],
            supera_limite: @resultado[:supera_limite],
            limite_km: @resultado[:limite_km],
          },
        }
      end
    end

    # ============================================================================
    # MÉTODOS PRIVADOS
    # ============================================================================

    private

    # Busca un banco por ID y lo asigna a @banco
    # Si no se encuentra, renderiza un error 404
    #
    # @param id [Integer] ID del banco a buscar
    # @raise [ActiveRecord::RecordNotFound] Si el banco no existe
    def set_banco
      @banco = Banco.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: {
        success: false,
        error: 'Banco no encontrado',
      }, status: :not_found
    end

    # Define los parámetros permitidos para crear/actualizar un banco
    # Utiliza strong parameters para prevenir asignación masiva no autorizada
    #
    # @return [ActionController::Parameters] Parámetros permitidos
    def banco_params
      params.expect(banco: %i[nombre direccion latitud longitud])
    end

    # Valida los parámetros del método cercano
    # @return [nil, ActionController::Response] nil si es válido, respuesta de error si no
    def validate_cercano_params
      extract_cercano_params
      return validate_required_params if missing_required_params?
      return validate_coordinate_ranges if invalid_coordinate_ranges?

      nil
    end

    # Extrae y convierte los parámetros del método cercano
    def extract_cercano_params
      @lat = params[:latitud]&.to_f
      @lng = params[:longitud]&.to_f
      @limite_km = params[:limite_km]&.to_f || 10.0
    end

    # Verifica si faltan parámetros requeridos
    def missing_required_params?
      @lat.blank? || @lng.blank?
    end

    # Verifica si las coordenadas están fuera de rango
    def invalid_coordinate_ranges?
      !@lat.between?(-90, 90) || !@lng.between?(-180, 180)
    end

    # Valida parámetros requeridos
    def validate_required_params
      render json: {
        success: false,
        error: 'Los parámetros latitud y longitud son requeridos',
      }, status: :bad_request
    end

    # Valida rangos de coordenadas
    def validate_coordinate_ranges
      render json: {
        success: false,
        error: 'Coordenadas fuera de rango válido (latitud: -90 a 90, longitud: -180 a 180)',
      }, status: :bad_request
    end
  end
end
