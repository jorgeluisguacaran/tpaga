# frozen_string_literal: true

# Serializer para respuestas de banco cercano
#
# Este serializer maneja la respuesta específica del endpoint de banco cercano,
# incluyendo información de distancia y límites.
class BancoCercanoSerializer < ActiveModel::Serializer
  attributes :banco, :distancia_km, :supera_limite, :limite_km

  def banco
    BancoSerializer.new(object[:banco])
  end

  def distancia_km
    object[:distancia_km]
  end

  def supera_limite
    object[:supera_limite]
  end

  def limite_km
    object[:limite_km]
  end
end
