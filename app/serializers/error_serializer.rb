# frozen_string_literal: true

# Serializer para respuestas de error estandarizadas
#
# Este serializer proporciona un formato consistente para todos los errores
# de la API, incluyendo códigos de estado HTTP y mensajes descriptivos.
class ErrorSerializer < ActiveModel::Serializer
  attributes :success, :error, :details, :code

  def success
    false
  end

  def error
    object[:error] || object[:message] || 'Error desconocido'
  end

  def details
    object[:details] || object[:errors]
  end

  def code
    object[:code] || object[:status]
  end

  # Solo incluir detalles si están presentes
  def attributes(*args)
    hash = super
    hash.except!(:details) unless details.present?
    hash.except!(:code) unless code.present?
    hash
  end
end
