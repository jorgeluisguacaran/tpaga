# Migración para crear la tabla de bancos
#
# Esta migración define la estructura de la tabla 'bancos' que almacena
# información sobre entidades bancarias, incluyendo su ubicación geográfica
# y evaluación de calidad.
#
# La tabla incluye:
# - Campos básicos de identificación (nombre, dirección)
# - Coordenadas geográficas (latitud, longitud) para cálculos de distancia
# - Campo de evaluación para análisis de calidad
# - Timestamps para auditoría
# - Índices para optimizar consultas geográficas y por nombre
class CreateBancos < ActiveRecord::Migration[8.0]
  def change
    # Crear la tabla principal de bancos
    create_table :bancos do |t|
      # ============================================================================
      # CAMPOS BÁSICOS
      # ============================================================================

      # Nombre del banco (obligatorio, 2-100 caracteres)
      t.string :nombre, null: false

      # Dirección física del banco (obligatorio, 5-200 caracteres)
      t.string :direccion, null: false

      # ============================================================================
      # COORDENADAS GEOGRÁFICAS
      # ============================================================================
      #
      # Las coordenadas se almacenan como decimales con alta precisión
      # para cálculos geográficos precisos usando la fórmula de Haversine

      # Latitud del banco (-90 a 90 grados)
      # Precision: 10 dígitos totales, 8 decimales
      # Ejemplo: 4.71100000 (Bogotá)
      t.decimal :latitud, precision: 10, scale: 8, null: false

      # Longitud del banco (-180 a 180 grados)
      # Precision: 11 dígitos totales, 8 decimales
      # Ejemplo: -74.07210000 (Bogotá)
      t.decimal :longitud, precision: 11, scale: 8, null: false

      # ============================================================================
      # EVALUACIÓN Y METADATOS
      # ============================================================================

      # Evaluación del banco (0.0 a 5.0 estrellas, opcional)
      # Precision: 3 dígitos totales, 2 decimales
      # Ejemplo: 4.50
      t.decimal :evaluacion, precision: 3, scale: 2, default: 0.0

      # Timestamps automáticos para auditoría
      t.timestamps
    end

    # ============================================================================
    # ÍNDICES PARA OPTIMIZACIÓN
    # ============================================================================

    # Índice compuesto para consultas geográficas
    # Optimiza búsquedas por proximidad y cálculos de distancia
    add_index :bancos, [:latitud, :longitud]

    # Índice simple para búsquedas por nombre
    # Optimiza consultas que filtran o buscan por nombre de banco
    add_index :bancos, :nombre
  end
end
