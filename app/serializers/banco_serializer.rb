# frozen_string_literal: true

# Serializer para el modelo Banco
#
# Este serializer define cómo se debe representar un objeto Banco en formato JSON,
# incluyendo todos los atributos relevantes y cualquier información adicional
# que sea necesaria para la API.
class BancoSerializer < ApplicationSerializer
  # Atributos básicos del banco
  attributes :id, :nombre, :direccion, :latitud, :longitud

  # Convertir coordenadas a float para consistencia
  def latitud
    object.latitud.to_f
  end

  def longitud
    object.longitud.to_f
  end
end
