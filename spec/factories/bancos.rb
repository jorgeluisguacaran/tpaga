FactoryBot.define do
  factory :banco do
    sequence(:nombre) { |n| "Banco #{Faker::Company.name} #{n}" }
    direccion { "#{Faker::Address.street_address}, #{Faker::Address.city}" }
    latitud { Faker::Address.latitude }
    longitud { Faker::Address.longitude }
    evaluacion { Faker::Number.between(from: 1.0, to: 5.0).round(2) }

    # Factory para bancos en Bogotá
    factory :banco_bogota do
      nombre { "Banco de Bogotá" }
      direccion { "Calle 123 # 45-67, Bogotá" }
      latitud { 4.7110 }
      longitud { -74.0721 }
      evaluacion { 4.5 }
    end

    # Factory para bancos en Medellín
    factory :banco_medellin do
      nombre { "Banco de Medellín" }
      direccion { "Carrera 70 # 12-34, Medellín" }
      latitud { 6.2442 }
      longitud { -75.5812 }
      evaluacion { 4.2 }
    end

    # Factory para bancos en Cali
    factory :banco_cali do
      nombre { "Banco de Cali" }
      direccion { "Avenida 4N # 6-78, Cali" }
      latitud { 3.4516 }
      longitud { -76.5320 }
      evaluacion { 4.0 }
    end

    # Factory para bancos con alta evaluación
    factory :banco_alta_evaluacion do
      evaluacion { Faker::Number.between(from: 4.5, to: 5.0).round(2) }
    end

    # Factory para bancos con baja evaluación
    factory :banco_baja_evaluacion do
      evaluacion { Faker::Number.between(from: 1.0, to: 2.5).round(2) }
    end
  end
end
