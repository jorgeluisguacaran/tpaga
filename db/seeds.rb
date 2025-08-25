# Seeds para la aplicación Bancos API
#
# Este archivo crea datos iniciales de bancos para pruebas y demostración.
# Los bancos se crean con coordenadas reales de ciudades colombianas.

puts "Creando bancos de ejemplo..."

# Banco en Bogotá
Banco.create!(
  nombre: "Banco de Bogotá",
  direccion: "Calle 72 # 10-07, Bogotá",
  latitud: 4.7110,
  longitud: -74.0721
)

# Banco en Medellín
Banco.create!(
  nombre: "Banco de Medellín",
  direccion: "Carrera 64C # 78-580, Medellín",
  latitud: 6.2442,
  longitud: -75.5812
)

# Banco en Cali
Banco.create!(
  nombre: "Banco de Cali",
  direccion: "Calle 15 # 30-25, Cali",
  latitud: 3.4516,
  longitud: -76.5320
)

# Banco en Barranquilla
Banco.create!(
  nombre: "Banco de Barranquilla",
  direccion: "Calle 45 # 54-123, Barranquilla",
  latitud: 10.9685,
  longitud: -74.7813
)

# Banco en Cartagena
Banco.create!(
  nombre: "Banco de Cartagena",
  direccion: "Calle de la Media Luna # 10-20, Cartagena",
  latitud: 10.3932,
  longitud: -75.4792
)

# Banco en Bucaramanga
Banco.create!(
  nombre: "Banco de Bucaramanga",
  direccion: "Calle 35 # 20-15, Bucaramanga",
  latitud: 7.1253,
  longitud: -73.1367
)

# Banco en Pereira
Banco.create!(
  nombre: "Banco de Pereira",
  direccion: "Carrera 8 # 23-45, Pereira",
  latitud: 4.8143,
  longitud: -75.6946
)

# Banco en Manizales
Banco.create!(
  nombre: "Banco de Manizales",
  direccion: "Carrera 22 # 33-12, Manizales",
  latitud: 5.0703,
  longitud: -75.5138
)

# Banco en Ibagué
Banco.create!(
  nombre: "Banco de Ibagué",
  direccion: "Calle 15 # 2-45, Ibagué",
  latitud: 4.4389,
  longitud: -75.2322
)

# Banco en Villavicencio
Banco.create!(
  nombre: "Banco de Villavicencio",
  direccion: "Carrera 40 # 25-67, Villavicencio",
  latitud: 4.1420,
  longitud: -73.6266
)

puts "¡Bancos creados exitosamente!"
puts "Total de bancos en la base de datos: #{Banco.count}"
