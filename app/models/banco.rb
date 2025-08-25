class Banco < ApplicationRecord
  # Validaciones
  validates :nombre, presence: true, length: { minimum: 2, maximum: 100 }
  validates :direccion, presence: true, length: { minimum: 5, maximum: 200 }
  validates :latitud, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitud, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :evaluacion, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true

  # Scopes
  scope :ordenados_por_evaluacion, -> { order(evaluacion: :desc) }
  scope :con_evaluacion_minima, ->(minima = 3.0) { where('evaluacion >= ?', minima) }

  # Método para calcular distancia a un punto dado (en kilómetros)
  def distancia_a(lat, lng)
    return nil unless lat.present? && lng.present?
    
    # Usando la fórmula de Haversine para calcular distancia entre dos puntos geográficos
    rad_per_deg = Math::PI / 180
    earth_radius_km = 6371

    lat1_rad = latitud * rad_per_deg
    lat2_rad = lat * rad_per_deg
    delta_lat_rad = (lat - latitud) * rad_per_deg
    delta_lng_rad = (lng - longitud) * rad_per_deg

    a = Math.sin(delta_lat_rad / 2) * Math.sin(delta_lat_rad / 2) +
        Math.cos(lat1_rad) * Math.cos(lat2_rad) *
        Math.sin(delta_lng_rad / 2) * Math.sin(delta_lng_rad / 2)
    
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    
    (earth_radius_km * c).round(2)
  end

  # Método de clase para encontrar el banco más cercano
  def self.mas_cercano_a(lat, lng, limite_km = 10)
    return nil unless lat.present? && lng.present?
    
    bancos = all.to_a
    return nil if bancos.empty?
    
    banco_mas_cercano = bancos.min_by { |banco| banco.distancia_a(lat, lng) }
    distancia = banco_mas_cercano.distancia_a(lat, lng)
    
    # Notificar si la distancia supera el límite
    if distancia > limite_km
      Rails.logger.warn "Banco más cercano (#{banco_mas_cercano.nombre}) está a #{distancia}km del punto (#{lat}, #{lng}) - Supera el límite de #{limite_km}km"
    end
    
    {
      banco: banco_mas_cercano,
      distancia_km: distancia,
      supera_limite: distancia > limite_km
    }
  end

  # Método para verificar si está dentro del radio especificado
  def dentro_del_radio?(lat, lng, radio_km = 10)
    distancia = distancia_a(lat, lng)
    distancia.present? && distancia <= radio_km
  end
end
