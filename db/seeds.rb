# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Creando bancos de prueba..."

# Bancos en Bogotá
Banco.create!(
  nombre: "Banco de Bogotá - Centro",
  direccion: "Calle 72 # 10-07, Bogotá",
  latitud: 4.7110,
  longitud: -74.0721,
  evaluacion: 4.5
)

Banco.create!(
  nombre: "Banco de Bogotá - Chapinero",
  direccion: "Carrera 7 # 26-20, Bogotá",
  latitud: 4.6682,
  longitud: -74.0537,
  evaluacion: 4.2
)

Banco.create!(
  nombre: "Banco de Bogotá - Usaquén",
  direccion: "Calle 119 # 7-14, Bogotá",
  latitud: 4.6975,
  longitud: -74.0337,
  evaluacion: 4.0
)

# Bancos en Medellín
Banco.create!(
  nombre: "Banco de Medellín - Centro",
  direccion: "Carrera 64C # 78-580, Medellín",
  latitud: 6.2442,
  longitud: -75.5812,
  evaluacion: 4.3
)

Banco.create!(
  nombre: "Banco de Medellín - El Poblado",
  direccion: "Carrera 43A # 6-15, Medellín",
  latitud: 6.2088,
  longitud: -75.5677,
  evaluacion: 4.7
)

# Bancos en Cali
Banco.create!(
  nombre: "Banco de Cali - Centro",
  direccion: "Calle 9 # 37-00, Cali",
  latitud: 3.4516,
  longitud: -76.5320,
  evaluacion: 4.1
)

Banco.create!(
  nombre: "Banco de Cali - Granada",
  direccion: "Carrera 66 # 10-15, Cali",
  latitud: 3.4280,
  longitud: -76.5432,
  evaluacion: 4.4
)

# Bancos en Barranquilla
Banco.create!(
  nombre: "Banco de Barranquilla - Centro",
  direccion: "Calle 44 # 44-66, Barranquilla",
  latitud: 10.9685,
  longitud: -74.7813,
  evaluacion: 3.9
)

# Bancos en Cartagena
Banco.create!(
  nombre: "Banco de Cartagena - Centro Histórico",
  direccion: "Calle de la Media Luna # 10-89, Cartagena",
  latitud: 10.3932,
  longitud: -75.4792,
  evaluacion: 4.6
)

# Bancos en Bucaramanga
Banco.create!(
  nombre: "Banco de Bucaramanga - Cabecera",
  direccion: "Calle 45 # 26-50, Bucaramanga",
  latitud: 7.1253,
  longitud: -73.1367,
  evaluacion: 4.0
)

puts "¡Bancos creados exitosamente!"
puts "Total de bancos: #{Banco.count}"
