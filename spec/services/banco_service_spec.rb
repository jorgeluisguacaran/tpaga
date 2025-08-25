require 'rails_helper'

RSpec.describe BancoService do
  let(:service) { described_class.new }

  describe '#crear_banco' do
    let(:valid_params) do
      {
        nombre: 'Banco de Prueba',
        direccion: 'Calle 123 # 45-67, Ciudad',
        latitud: 4.7110,
        longitud: -74.0721,
        evaluacion: 4.5
      }
    end

    context 'con parámetros válidos' do
      it 'crea un banco exitosamente' do
        expect {
          service.crear_banco(valid_params)
        }.to change(Banco, :count).by(1)
      end

      it 'retorna success true' do
        resultado = service.crear_banco(valid_params)
        expect(resultado[:success]).to be true
        expect(resultado[:banco]).to be_a(Banco)
        expect(resultado[:banco].nombre).to eq('Banco de Prueba')
      end
    end

    context 'con parámetros inválidos' do
      let(:invalid_params) do
        {
          nombre: '', # Inválido
          direccion: 'Calle 123',
          latitud: 4.7110,
          longitud: -74.0721
        }
      end

      it 'no crea un banco' do
        expect {
          service.crear_banco(invalid_params)
        }.not_to change(Banco, :count)
      end

      it 'retorna success false con errores' do
        resultado = service.crear_banco(invalid_params)
        expect(resultado[:success]).to be false
        expect(resultado[:errors]).to include("Nombre can't be blank")
      end
    end
  end

  describe '#buscar_por_id' do
    let!(:banco) { create(:banco_bogota) }

    context 'cuando el banco existe' do
      it 'retorna el banco' do
        resultado = service.buscar_por_id(banco.id)
        expect(resultado[:success]).to be true
        expect(resultado[:banco]).to eq(banco)
      end
    end

    context 'cuando el banco no existe' do
      it 'retorna error' do
        resultado = service.buscar_por_id(99999)
        expect(resultado[:success]).to be false
        expect(resultado[:errors]).to include('Banco no encontrado')
      end
    end
  end

  describe '#encontrar_mas_cercano' do
    let!(:banco_bogota) { create(:banco_bogota) }
    let!(:banco_medellin) { create(:banco_medellin) }

    context 'con coordenadas válidas' do
      it 'encuentra el banco más cercano' do
        resultado = service.encontrar_mas_cercano(4.7110, -74.0721)

        expect(resultado[:success]).to be true
        expect(resultado[:banco].nombre).to include('Bogotá').or(include('Prueba'))
        expect(resultado[:distancia_km]).to be_within(0.1).of(0.0)
        expect(resultado[:supera_limite]).to be false
      end

      it 'permite personalizar el límite' do
        resultado = service.encontrar_mas_cercano(-34.6037, -58.3816, 1.0) # Buenos Aires

        expect(resultado[:success]).to be true
        expect(resultado[:supera_limite]).to be true
        expect(resultado[:limite_km]).to eq(1.0)
      end
    end

    context 'con coordenadas inválidas' do
      it 'retorna error para latitud inválida' do
        resultado = service.encontrar_mas_cercano(100, -74.0721)

        expect(resultado[:success]).to be false
        expect(resultado[:errors]).to include('Coordenadas inválidas')
      end

      it 'retorna error para longitud inválida' do
        resultado = service.encontrar_mas_cercano(4.7110, 200)

        expect(resultado[:success]).to be false
        expect(resultado[:errors]).to include('Coordenadas inválidas')
      end

      it 'retorna error para coordenadas nil' do
        resultado = service.encontrar_mas_cercano(nil, -74.0721)

        expect(resultado[:success]).to be false
        expect(resultado[:errors]).to include('Coordenadas inválidas')
      end
    end

    context 'cuando no hay bancos disponibles' do
      it 'retorna error' do
        Banco.destroy_all
        resultado = service.encontrar_mas_cercano(4.7110, -74.0721)

        expect(resultado[:success]).to be false
        expect(resultado[:errors]).to include('No hay bancos disponibles')
      end
    end
  end

  describe '#estadisticas' do
    let!(:banco_alto) { create(:banco_alta_evaluacion, evaluacion: 4.8) }
    let!(:banco_medio) { create(:banco, evaluacion: 3.5) }
    let!(:banco_bajo) { create(:banco_baja_evaluacion, evaluacion: 2.0) }

    it 'calcula estadísticas correctamente' do
      stats = service.estadisticas

      expect(stats[:total_bancos]).to be > 0
      expect(stats[:promedio_evaluacion]).to be > 0
      expect(stats[:bancos_alta_evaluacion]).to be >= 0
      expect(stats[:porcentaje_alta_evaluacion]).to be >= 0
    end

    context 'cuando no hay bancos' do
      it 'retorna estadísticas con valores por defecto' do
        Banco.destroy_all
        stats = service.estadisticas

        expect(stats[:total_bancos]).to eq(0)
        expect(stats[:promedio_evaluacion]).to eq(0.0)
        expect(stats[:bancos_alta_evaluacion]).to eq(0)
        expect(stats[:porcentaje_alta_evaluacion]).to eq(0.0)
      end
    end
  end

  describe 'notificaciones de distancia excesiva' do
    let!(:banco_bogota) { create(:banco_bogota) }

    it 'registra notificación en el log cuando supera el límite' do
      # Punto muy lejano
      expect(Rails.logger).to receive(:warn).with(/Banco más cercano/).at_least(:once)
      expect(Rails.logger).to receive(:info).with(/Notificación de distancia excesiva/).at_least(:once)

      service.encontrar_mas_cercano(-34.6037, -58.3816, 10.0) # Buenos Aires
    end
  end
end
