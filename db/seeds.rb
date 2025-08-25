# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Crear bancos de ejemplo en diferentes ciudades de Colombia
puts "Creando bancos de ejemplo..."

# Bancos en Bogotá
bancos_bogota = [
  {
    nombre: "Banco de Bogotá - Centro",
    direccion: "Calle 72 # 10-07, Bogotá",
    latitud: 4.7110,
    longitud: -74.0721,
    evaluacion: 4.2
  },
  {
    nombre: "Banco Popular - Chapinero",
    direccion: "Carrera 7 # 26-20, Bogotá",
    latitud: 4.6682,
    longitud: -74.0536,
    evaluacion: 4.5
  },
  {
    nombre: "Banco Colpatria - Usaquén",
    direccion: "Calle 127 # 7-35, Bogotá",
    latitud: 4.7176,
    longitud: -74.0332,
    evaluacion: 4.0
  }
]

# Bancos en Medellín
bancos_medellin = [
  {
    nombre: "Banco de Medellín - Centro",
    direccion: "Calle 50 # 50-48, Medellín",
    latitud: 6.2442,
    longitud: -75.5812,
    evaluacion: 4.3
  },
  {
    nombre: "Banco Popular - Laureles",
    direccion: "Carrera 70 # 44-42, Medellín",
    latitud: 6.2518,
    longitud: -75.6044,
    evaluacion: 4.7
  }
]

# Bancos en Cali
bancos_cali = [
  {
    nombre: "Banco de Cali - Centro",
    direccion: "Calle 15 # 6-64, Cali",
    latitud: 3.4516,
    longitud: -76.5320,
    evaluacion: 4.1
  },
  {
    nombre: "Banco Popular - Granada",
    direccion: "Carrera 66 # 3-45, Cali",
    latitud: 3.4289,
    longitud: -76.5432,
    evaluacion: 4.4
  }
]

# Bancos en Barranquilla
bancos_barranquilla = [
  {
    nombre: "Banco de Barranquilla - Centro",
    direccion: "Calle 45 # 44-85, Barranquilla",
    latitud: 10.9685,
    longitud: -74.7813,
    evaluacion: 3.9
  }
]

# Bancos en Bucaramanga
bancos_bucaramanga = [
  {
    nombre: "Banco de Bucaramanga - Centro",
    direccion: "Calle 35 # 19-52, Bucaramanga",
    latitud: 7.1253,
    longitud: -73.1367,
    evaluacion: 4.0
  }
]

# Combinar todos los bancos
todos_los_bancos = bancos_bogota + bancos_medellin + bancos_cali + bancos_barranquilla + bancos_bucaramanga

# Crear los bancos en la base de datos
todos_los_bancos.each do |banco_data|
  Banco.find_or_create_by!(nombre: banco_data[:nombre]) do |banco|
    banco.direccion = banco_data[:direccion]
    banco.latitud = banco_data[:latitud]
    banco.longitud = banco_data[:longitud]
    banco.evaluacion = banco_data[:evaluacion]
  end
end

puts "Se crearon #{Banco.count} bancos de ejemplo"
puts "Bancos creados:"
Banco.all.each do |banco|
  puts "- #{banco.nombre} (#{banco.direccion}) - Evaluación: #{banco.evaluacion}"
end
