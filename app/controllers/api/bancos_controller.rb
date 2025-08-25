class Api::BancosController < ApplicationController
  before_action :set_banco, only: [:show]

  # GET /api/bancos/:id
  def show
    render json: {
      success: true,
      data: {
        id: @banco.id,
        nombre: @banco.nombre,
        direccion: @banco.direccion,
        latitud: @banco.latitud.to_f,
        longitud: @banco.longitud.to_f,
        evaluacion: @banco.evaluacion&.to_f,
        created_at: @banco.created_at,
        updated_at: @banco.updated_at
      }
    }
  rescue ActiveRecord::RecordNotFound
    render json: {
      success: false,
      error: 'Banco no encontrado'
    }, status: :not_found
  end

  # POST /api/bancos
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
          evaluacion: @banco.evaluacion&.to_f,
          created_at: @banco.created_at,
          updated_at: @banco.updated_at
        }
      }, status: :created
    else
      render json: {
        success: false,
        error: 'Error al crear el banco',
        details: @banco.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # GET /api/bancos/cercano
  def cercano
    lat = params[:latitud]&.to_f
    lng = params[:longitud]&.to_f
    limite_km = params[:limite_km]&.to_f || 10.0

    # Validar parámetros requeridos
    unless lat.present? && lng.present?
      return render json: {
        success: false,
        error: 'Los parámetros latitud y longitud son requeridos'
      }, status: :bad_request
    end

    # Validar rangos de coordenadas
    unless lat.between?(-90, 90) && lng.between?(-180, 180)
      return render json: {
        success: false,
        error: 'Coordenadas fuera de rango válido (latitud: -90 a 90, longitud: -180 a 180)'
      }, status: :bad_request
    end

    resultado = Banco.mas_cercano_a(lat, lng, limite_km)

    if resultado.nil?
      render json: {
        success: false,
        error: 'No hay bancos disponibles en la base de datos'
      }, status: :not_found
    else
      render json: {
        success: true,
        data: {
          banco: {
            id: resultado[:banco].id,
            nombre: resultado[:banco].nombre,
            direccion: resultado[:banco].direccion,
            latitud: resultado[:banco].latitud,
            longitud: resultado[:banco].longitud,
            evaluacion: resultado[:banco].evaluacion
          },
          distancia_km: resultado[:distancia_km],
          supera_limite: resultado[:supera_limite],
          limite_km: limite_km
        }
      }
    end
  end

  private

  def set_banco
    @banco = Banco.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      success: false,
      error: 'Banco no encontrado'
    }, status: :not_found
  end

  def banco_params
    params.require(:banco).permit(:nombre, :direccion, :latitud, :longitud, :evaluacion)
  end
end
