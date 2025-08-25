# frozen_string_literal: true

FactoryBot.define do
  # Factory básica para crear un banco con datos mínimos
  factory :banco do
    sequence(:nombre) { |n| "Banco de Prueba #{n}" }
    direccion { Faker::Address.full_address }
    latitud { Faker::Address.latitude }
    longitud { Faker::Address.longitude }
  end

  # Factory para banco en Bogotá
  factory :banco_bogota, parent: :banco do
    nombre { "Banco de Bogotá" }
    direccion { "Calle 72 # 10-07, Bogotá" }
    latitud { 4.7110 }
    longitud { -74.0721 }
  end

  # Factory para banco en Medellín
  factory :banco_medellin, parent: :banco do
    nombre { "Banco de Medellín" }
    direccion { "Carrera 64C # 78-580, Medellín" }
    latitud { 6.2442 }
    longitud { -75.5812 }
  end

  # Factory para banco en Cali
  factory :banco_cali, parent: :banco do
    nombre { "Banco de Cali" }
    direccion { "Calle 15 # 30-25, Cali" }
    latitud { 3.4516 }
    longitud { -76.5320 }
  end
end
