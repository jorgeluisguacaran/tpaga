class BancoService
  attr_reader :errors

  def initialize
    @errors = []
  end

  # Crear un nuevo banco
  def crear_banco(params)
    banco = Banco.new(params)

    if banco.save
      { success: true, banco: banco }
    else
      @errors = banco.errors.full_messages
      { success: false, errors: @errors }
    end
  end

  # Buscar banco por ID
  def buscar_por_id(id)
    banco = Banco.find_by(id: id)

    if banco
      { success: true, banco: banco }
    else
      @errors = ['Banco no encontrado']
      { success: false, errors: @errors }
    end
  end

  # Encontrar el banco más cercano
  def encontrar_mas_cercano(lat, lng, limite_km = 10.0)
    # Validar parámetros
    unless coordenadas_validas?(lat, lng)
      @errors = ['Coordenadas inválidas']
      return { success: false, errors: @errors }
    end

    resultado = Banco.mas_cercano_a(lat, lng, limite_km)

    if resultado.nil?
      @errors = ['No hay bancos disponibles']
      return { success: false, errors: @errors }
    end

    # Notificar si supera el límite
    if resultado[:supera_limite]
      notificar_distancia_excesiva(resultado[:banco], resultado[:distancia_km], lat, lng, limite_km)
    end

    {
      success: true,
      banco: resultado[:banco],
      distancia_km: resultado[:distancia_km],
      supera_limite: resultado[:supera_limite],
      limite_km: limite_km
    }
  end

  # Obtener estadísticas de bancos
  def estadisticas
    total_bancos = Banco.count
    promedio_evaluacion = Banco.average(:evaluacion)&.round(2) || 0.0
    bancos_alta_evaluacion = Banco.con_evaluacion_minima(4.0).count

    {
      total_bancos: total_bancos,
      promedio_evaluacion: promedio_evaluacion,
      bancos_alta_evaluacion: bancos_alta_evaluacion,
      porcentaje_alta_evaluacion: total_bancos > 0 ? ((bancos_alta_evaluacion.to_f / total_bancos) * 100).round(2) : 0.0
    }
  end

  private

  def coordenadas_validas?(lat, lng)
    lat.present? && lng.present? &&
    lat.between?(-90, 90) && lng.between?(-180, 180)
  end

  def notificar_distancia_excesiva(banco, distancia, lat, lng, limite)
    mensaje = "ALERTA: Banco más cercano '#{banco.nombre}' está a #{distancia}km del punto (#{lat}, #{lng}) - Supera el límite de #{limite}km"

    # Log de la notificación
    Rails.logger.warn mensaje

    # Aquí se podría implementar notificaciones adicionales como:
    # - Envío de email
    # - Notificación push
    # - Integración con sistemas de monitoreo
    # - Almacenamiento en base de datos para análisis posterior

    # Por ahora solo registramos en el log
    Rails.logger.info "Notificación de distancia excesiva registrada: #{mensaje}"
  end
end
