# frozen_string_literal: true

# Serializer para respuestas de éxito estandarizadas
#
# Este serializer proporciona un formato consistente para todas las respuestas
# exitosas de la API, incluyendo mensajes y metadatos opcionales.
class SuccessSerializer < ActiveModel::Serializer
  attributes :success, :message, :data

  def success
    true
  end

  def message
    object[:message]
  end

  def data
    object[:data]
  end

  # Solo incluir mensaje si está presente
  def attributes(*args)
    hash = super
    hash.except!(:message) unless message.present?
    hash
  end
end
