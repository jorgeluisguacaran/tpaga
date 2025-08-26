# frozen_string_literal: true

# Modelo para la gestión de bancos
#
# Este modelo representa una entidad Banco con funcionalidades para:
# - Almacenar información básica del banco (nombre, dirección, coordenadas)
# - Calcular distancias geográficas usando la fórmula de Haversine
# - Encontrar el banco más cercano a un punto específico
#
# @example Crear un nuevo banco
#   banco = Banco.create!(
#     nombre: "Banco de Bogotá",
#     direccion: "Calle 72 # 10-07, Bogotá",
#     latitud: 4.7110,
#     longitud: -74.0721
#   )
#
# @example Encontrar el banco más cercano
#   resultado = Banco.mas_cercano_a(4.7110, -74.0721, 10.0)
#   banco_cercano = resultado[:banco]
#   distancia = resultado[:distancia_km]
class Banco < ApplicationRecord
  # ============================================================================
  # VALIDACIONES
  # ============================================================================

  # Validación: El nombre es obligatorio y debe tener entre 2 y 100 caracteres
  validates :nombre, presence: true, length: { minimum: 2, maximum: 100 }

  # Validación: La dirección es obligatoria y debe tener entre 5 y 200 caracteres
  validates :direccion, presence: true, length: { minimum: 5, maximum: 200 }

  # Validación: La latitud es obligatoria y debe estar entre -90 y 90 grados
  validates :latitud, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }

  # Validación: La longitud es obligatoria y debe estar entre -180 y 180 grados
  validates :longitud, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

  # ============================================================================
  # MÉTODOS DE INSTANCIA
  # ============================================================================

  # Calcula la distancia desde este banco a un punto geográfico específico
  #
  # Utiliza la fórmula de Haversine para calcular la distancia entre dos puntos
  # en la superficie de la Tierra, considerando la curvatura del planeta.
  #
  # @param lat [Float] Latitud del punto de destino
  # @param lng [Float] Longitud del punto de destino
  # @return [Float, nil] Distancia en kilómetros, o nil si las coordenadas son inválidas
  #
  # @example Calcular distancia a Bogotá
  #   banco = Banco.find(1)
  #   distancia = banco.distancia_a(4.7110, -74.0721)
  #   puts "Distancia: #{distancia} km"
  def distancia_a(lat, lng)
    return nil unless coordenadas_validas_para_distancia?(lat, lng)

    coordenadas_rad = convertir_coordenadas_a_radianes(lat, lng)
    calcular_distancia_haversine(coordenadas_rad)
  end

  # Verifica si este banco está dentro del radio especificado desde un punto
  #
  # @param lat [Float] Latitud del punto de referencia
  # @param lng [Float] Longitud del punto de referencia
  # @param radio_km [Float] Radio en kilómetros (por defecto 10.0)
  # @return [Boolean] true si el banco está dentro del radio, false en caso contrario
  #
  # @example Verificar si está dentro de 5km
  #   banco = Banco.find(1)
  #   dentro = banco.dentro_del_radio?(4.7110, -74.0721, 5.0)
  #   puts "¿Está dentro del radio? #{dentro}"
  def dentro_del_radio?(lat, lng, radio_km = 10)
    distancia = distancia_a(lat, lng)
    distancia.present? && distancia <= radio_km
  end

  # ============================================================================
  # MÉTODOS DE CLASE
  # ============================================================================

  # Encuentra el banco más cercano a un punto geográfico específico
  #
  # Este método calcula la distancia desde el punto especificado a todos los bancos
  # en la base de datos y retorna el más cercano. También notifica si la distancia
  # supera el límite configurado.
  #
  # @param lat [Float] Latitud del punto de búsqueda
  # @param lng [Float] Longitud del punto de búsqueda
  # @param limite_km [Float] Límite de distancia en kilómetros (por defecto 10.0)
  # @return [Hash, nil] Hash con información del banco más cercano o nil si no hay bancos
  #
  # @option return [Banco] :banco El banco más cercano
  # @option return [Float] :distancia_km Distancia en kilómetros
  # @option return [Boolean] :supera_limite Indica si supera el límite configurado
  # @option return [Float] :limite_km El límite utilizado en el cálculo
  #
  # @example Encontrar banco más cercano a Bogotá
  #   resultado = Banco.mas_cercano_a(4.7110, -74.0721, 10.0)
  #   if resultado
  #     puts "Banco más cercano: #{resultado[:banco].nombre}"
  #     puts "Distancia: #{resultado[:distancia_km]} km"
  #     puts "¿Supera límite? #{resultado[:supera_limite]}"
  #   end
  def self.mas_cercano_a(lat, lng, limite_km = 10)
    return nil unless lat.present? && lng.present?

    # Obtener todos los bancos de la base de datos
    bancos = all.to_a
    return nil if bancos.empty?

    # Encontrar el banco con la distancia mínima
    banco_mas_cercano = bancos.min_by { |banco| banco.distancia_a(lat, lng) }
    distancia = banco_mas_cercano.distancia_a(lat, lng)

    # Notificar si la distancia supera el límite configurado
    if distancia > limite_km
      mensaje = "Banco más cercano (#{banco_mas_cercano.nombre}) está a #{distancia}km " \
                "del punto (#{lat}, #{lng}) - Supera el límite de #{limite_km}km"
      Rails.logger.warn mensaje
    end

    # Retornar hash con toda la información relevante
    {
      banco: banco_mas_cercano,
      distancia_km: distancia,
      supera_limite: distancia > limite_km,
      limite_km: limite_km,
    }
  end

  # ============================================================================
  # MÉTODOS PRIVADOS
  # ============================================================================

  private

  # Valida que las coordenadas sean válidas para el cálculo de distancia
  def coordenadas_validas_para_distancia?(lat, lng)
    lat.present? && lng.present?
  end

  # Convierte coordenadas de grados a radianes
  def convertir_coordenadas_a_radianes(lat, lng)
    rad_per_deg = Math::PI / 180

    {
      lat1_rad: latitud * rad_per_deg,
      lat2_rad: lat * rad_per_deg,
      delta_lat_rad: (lat - latitud) * rad_per_deg,
      delta_lng_rad: (lng - longitud) * rad_per_deg,
    }
  end

  # Calcula la distancia usando la fórmula de Haversine
  def calcular_distancia_haversine(coordenadas_rad)
    earth_radius_km = 6371

    # Fórmula de Haversine: a = sin²(Δφ/2) + cos(φ1) * cos(φ2) * sin²(Δλ/2)
    a = calcular_haversine_a(coordenadas_rad)

    # c = 2 * atan2(√a, √(1-a))
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    # Distancia = R * c (donde R es el radio de la Tierra)
    (earth_radius_km * c).round(2)
  end

  # Calcula la parte 'a' de la fórmula de Haversine
  def calcular_haversine_a(coordenadas_rad)
    (Math.sin(coordenadas_rad[:delta_lat_rad] / 2) * Math.sin(coordenadas_rad[:delta_lat_rad] / 2)) +
      (Math.cos(coordenadas_rad[:lat1_rad]) * Math.cos(coordenadas_rad[:lat2_rad]) *
       Math.sin(coordenadas_rad[:delta_lng_rad] / 2) * Math.sin(coordenadas_rad[:delta_lng_rad] / 2))
  end
end
