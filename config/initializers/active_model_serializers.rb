# frozen_string_literal: true

# Configuración para Active Model Serializers
#
# Este archivo configura el comportamiento global de los serializers
# en la aplicación, incluyendo el adaptador por defecto y opciones
# de serialización.

ActiveModelSerializers.config.tap do |config|
  # Usar el adaptador JSON por defecto
  config.adapter = :json

  # Incluir timestamps por defecto
  config.include_timestamps = true

  # Configurar el formato de timestamps
  config.timestamp_format = :iso8601

  # Configurar el formato de errores
  config.error_format = :full_messages

  # Deshabilitar el root por defecto para evitar problemas con hashes
  config.root = false
end
