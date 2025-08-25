FactoryBot.define do
  factory :banco do
    nombre { Faker::Company.name }
    direccion { Faker::Address.full_address }
    latitud { Faker::Address.latitude }
    longitud { Faker::Address.longitude }
    evaluacion { Faker::Number.between(from: 1.0, to: 5.0).round(2) }

    # Factory para bancos en Bogotá
    factory :banco_bogota do
      latitud { Faker::Number.between(from: 4.5, to: 4.8) }
      longitud { Faker::Number.between(from: -74.2, to: -73.9) }
    end

    # Factory para bancos en Medellín
    factory :banco_medellin do
      latitud { Faker::Number.between(from: 6.1, to: 6.4) }
      longitud { Faker::Number.between(from: -75.7, to: -75.4) }
    end

    # Factory para bancos con alta evaluación
    factory :banco_alta_evaluacion do
      evaluacion { Faker::Number.between(from: 4.0, to: 5.0).round(2) }
    end

    # Factory para bancos con baja evaluación
    factory :banco_baja_evaluacion do
      evaluacion { Faker::Number.between(from: 1.0, to: 2.5).round(2) }
    end
  end
end
