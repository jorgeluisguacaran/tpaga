# frozen_string_literal: true

# Servicio para la gestión de bancos
#
# Este servicio encapsula la lógica de negocio relacionada con la gestión de bancos,
# proporcionando una capa de abstracción entre los controladores y los modelos.
# Incluye funcionalidades para crear bancos, buscar por ID, encontrar el más cercano
# y generar estadísticas.
#
# El servicio maneja:
# - Validaciones de negocio
# - Notificaciones de eventos importantes
# - Cálculos de estadísticas
# - Manejo de errores centralizado
#
# @example Uso básico del servicio
#   service = BancoService.new
#   resultado = service.crear_banco({
#     nombre: "Banco de Prueba",
#     direccion: "Calle 123",
#     latitud: 4.7110,
#     longitud: -74.0721
#   })
class BancoService
  attr_reader :errors

  # Inicializa una nueva instancia del servicio
  #
  # @return [BancoService] Nueva instancia del servicio
  def initialize
    @errors = []
  end

  # ============================================================================
  # MÉTODOS PÚBLICOS
  # ============================================================================

  # Crea un nuevo banco en la base de datos
  #
  # Valida los parámetros y crea el banco. Si hay errores de validación,
  # los almacena en el atributo @errors para su posterior consulta.
  #
  # @param params [Hash] Parámetros del banco a crear
  # @option params [String] :nombre Nombre del banco
  # @option params [String] :direccion Dirección del banco
  # @option params [Float] :latitud Latitud del banco
  # @option params [Float] :longitud Longitud del banco
  # @return [Hash] Resultado de la operación
  # @option return [Boolean] :success true si se creó exitosamente
  # @option return [Banco] :banco Banco creado (solo si success es true)
  # @option return [Array<String>] :errors Lista de errores (solo si success es false)
  #
  # @example Crear banco exitosamente
  #   service = BancoService.new
  #   resultado = service.crear_banco({
  #     nombre: "Banco de Bogotá",
  #     direccion: "Calle 72 # 10-07, Bogotá",
  #     latitud: 4.7110,
  #     longitud: -74.0721
  #   })
  #   if resultado[:success]
  #     puts "Banco creado: #{resultado[:banco].nombre}"
  #   else
  #     puts "Errores: #{resultado[:errors]}"
  #   end
  def crear_banco(params)
    banco = Banco.new(params)

    if banco.save
      { success: true, banco: banco }
    else
      @errors = banco.errors.full_messages
      { success: false, errors: @errors }
    end
  end

  # Busca un banco por su ID
  #
  # @param id [Integer] ID del banco a buscar
  # @return [Hash] Resultado de la búsqueda
  # @option return [Boolean] :success true si se encontró el banco
  # @option return [Banco] :banco Banco encontrado (solo si success es true)
  # @option return [Array<String>] :errors Lista de errores (solo si success es false)
  #
  # @example Buscar banco existente
  #   service = BancoService.new
  #   resultado = service.buscar_por_id(1)
  #   if resultado[:success]
  #     puts "Banco encontrado: #{resultado[:banco].nombre}"
  #   else
  #     puts "Error: #{resultado[:errors].first}"
  #   end
  def buscar_por_id(id)
    banco = Banco.find_by(id: id)

    if banco
      { success: true, banco: banco }
    else
      @errors = ['Banco no encontrado']
      { success: false, errors: @errors }
    end
  end

  # Encuentra el banco más cercano a un punto geográfico específico
  #
  # Este método valida las coordenadas, busca el banco más cercano y
  # notifica si la distancia supera el límite configurado.
  #
  # @param lat [Float] Latitud del punto de búsqueda
  # @param lng [Float] Longitud del punto de búsqueda
  # @param limite_km [Float] Límite de distancia en kilómetros (por defecto 10.0)
  # @return [Hash] Resultado de la búsqueda
  # @option return [Boolean] :success true si se encontró un banco
  # @option return [Banco] :banco Banco más cercano (solo si success es true)
  # @option return [Float] :distancia_km Distancia en kilómetros
  # @option return [Boolean] :supera_limite Indica si supera el límite
  # @option return [Float] :limite_km Límite utilizado
  # @option return [Array<String>] :errors Lista de errores (solo si success es false)
  #
  # @example Encontrar banco más cercano
  #   service = BancoService.new
  #   resultado = service.encontrar_mas_cercano(4.7110, -74.0721, 10.0)
  #   if resultado[:success]
  #     puts "Banco más cercano: #{resultado[:banco].nombre}"
  #     puts "Distancia: #{resultado[:distancia_km]} km"
  #     puts "¿Supera límite? #{resultado[:supera_limite]}"
  #   else
  #     puts "Error: #{resultado[:errors].first}"
  #   end
  def encontrar_mas_cercano(lat, lng, limite_km = 10.0)
    # Validar que las coordenadas sean válidas
    unless coordenadas_validas?(lat, lng)
      @errors = ['Coordenadas inválidas']
      return { success: false, errors: @errors }
    end

    # Buscar el banco más cercano usando el método del modelo
    resultado = Banco.mas_cercano_a(lat, lng, limite_km)

    if resultado.nil?
      @errors = ['No hay bancos disponibles']
      return { success: false, errors: @errors }
    end

    # Notificar si la distancia supera el límite configurado
    if resultado[:supera_limite]
      notificar_distancia_excesiva(resultado[:banco], resultado[:distancia_km], lat, lng, limite_km)
    end

    # Retornar resultado exitoso con toda la información
    {
      success: true,
      banco: resultado[:banco],
      distancia_km: resultado[:distancia_km],
      supera_limite: resultado[:supera_limite],
      limite_km: limite_km
    }
  end

  # Genera estadísticas de los bancos en la base de datos
  #
  # Calcula métricas básicas sobre los bancos almacenados.
  #
  # @return [Hash] Estadísticas de los bancos
  # @option return [Integer] :total_bancos Número total de bancos
  #
  # @example Obtener estadísticas
  #   service = BancoService.new
  #   stats = service.estadisticas
  #   puts "Total de bancos: #{stats[:total_bancos]}"
  def estadisticas
    # Calcular métricas básicas
    total_bancos = Banco.count

    # Retornar hash con todas las estadísticas
    {
      total_bancos: total_bancos
    }
  end

  # ============================================================================
  # MÉTODOS PRIVADOS
  # ============================================================================

  private

  # Valida que las coordenadas geográficas sean válidas
  #
  # Verifica que las coordenadas no sean nil y estén dentro de los
  # rangos válidos para latitud (-90 a 90) y longitud (-180 a 180).
  #
  # @param lat [Float] Latitud a validar
  # @param lng [Float] Longitud a validar
  # @return [Boolean] true si las coordenadas son válidas, false en caso contrario
  def coordenadas_validas?(lat, lng)
    lat.present? && lng.present? &&
    lat.between?(-90, 90) && lng.between?(-180, 180)
  end

  # Notifica cuando la distancia al banco más cercano supera el límite configurado
  #
  # Este método registra una alerta en los logs cuando la distancia al banco
  # más cercano supera el límite especificado. En el futuro, aquí se podrían
  # implementar notificaciones adicionales como emails, notificaciones push,
  # integración con sistemas de monitoreo, etc.
  #
  # @param banco [Banco] Banco más cercano encontrado
  # @param distancia [Float] Distancia en kilómetros al banco
  # @param lat [Float] Latitud del punto de búsqueda
  # @param lng [Float] Longitud del punto de búsqueda
  # @param limite [Float] Límite de distancia configurado
  # @return [void]
  def notificar_distancia_excesiva(banco, distancia, lat, lng, limite)
    # Crear mensaje de alerta
    mensaje = "ALERTA: Banco más cercano '#{banco.nombre}' está a #{distancia}km del punto (#{lat}, #{lng}) - Supera el límite de #{limite}km"

    # Registrar alerta en el log de warnings
    Rails.logger.warn mensaje

    # Aquí se podría implementar notificaciones adicionales como:
    # - Envío de email a administradores
    # - Notificación push a dispositivos móviles
    # - Integración con sistemas de monitoreo (PagerDuty, etc.)
    # - Almacenamiento en base de datos para análisis posterior
    # - Envío a servicios de mensajería (Slack, Teams, etc.)

    # Por ahora solo registramos en el log de información
    Rails.logger.info "Notificación de distancia excesiva registrada: #{mensaje}"
  end
end
