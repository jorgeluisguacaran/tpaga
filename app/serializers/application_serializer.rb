# frozen_string_literal: true

# Serializer base para toda la aplicación
#
# Este serializer proporciona funcionalidades comunes para todos los serializers
# de la aplicación, incluyendo el manejo de timestamps y metadatos básicos.
class ApplicationSerializer < ActiveModel::Serializer
  # Incluir timestamps por defecto en todos los serializers
  attributes :created_at, :updated_at

  # Formato de timestamps
  def created_at
    object.created_at&.iso8601
  end

  def updated_at
    object.updated_at&.iso8601
  end
end
