require 'rails_helper'

RSpec.describe BancoService do
  let(:service) { BancoService.new }

  describe '#crear_banco' do
    let(:valid_params) do
      {
        nombre: 'Banco de Prueba',
        direccion: 'Calle 123 # 45-67, Bogotá',
        latitud: 4.7110,
        longitud: -74.0721
      }
    end

    context 'con parámetros válidos' do
      it 'crea un banco exitosamente' do
        expect {
          resultado = service.crear_banco(valid_params)
          expect(resultado[:success]).to be true
          expect(resultado[:banco]).to be_a(Banco)
          expect(resultado[:banco].nombre).to eq('Banco de Prueba')
        }.to change(Banco, :count).by(1)
      end
    end

    context 'con parámetros inválidos' do
      let(:invalid_params) do
        {
          nombre: '',
          direccion: 'Calle 123',
          latitud: 4.7110,
          longitud: -74.0721
        }
      end

      it 'no crea el banco y retorna errores' do
        expect {
          resultado = service.crear_banco(invalid_params)
          expect(resultado[:success]).to be false
          expect(resultado[:errors]).to include("Nombre can't be blank")
        }.not_to change(Banco, :count)
      end
    end
  end

  describe '#buscar_por_id' do
    let!(:banco) { create(:banco_bogota) }

    context 'cuando el banco existe' do
      it 'retorna el banco encontrado' do
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
        expect(resultado[:limite_km]).to eq(10.0)
      end

      it 'permite personalizar el límite de distancia' do
        resultado = service.encontrar_mas_cercano(4.7110, -74.0721, 5.0)

        expect(resultado[:limite_km]).to eq(5.0)
      end
    end

    context 'con coordenadas inválidas' do
      it 'retorna error' do
        resultado = service.encontrar_mas_cercano(nil, -74.0721)

        expect(resultado[:success]).to be false
        expect(resultado[:errors]).to include('Coordenadas inválidas')
      end
    end

    context 'cuando no hay bancos' do
      before { Banco.destroy_all }

      it 'retorna error' do
        resultado = service.encontrar_mas_cercano(4.7110, -74.0721)

        expect(resultado[:success]).to be false
        expect(resultado[:errors]).to include('No hay bancos disponibles')
      end
    end

    context 'cuando supera el límite de distancia' do
      it 'notifica la distancia excesiva' do
        # Punto muy lejano (Buenos Aires)
        expect(Rails.logger).to receive(:warn).with(/Banco más cercano/).at_least(:once)
        expect(Rails.logger).to receive(:info).with(/Notificación de distancia excesiva/).at_least(:once)

        resultado = service.encontrar_mas_cercano(-34.6037, -58.3816, 10.0)

        expect(resultado[:success]).to be true
        expect(resultado[:supera_limite]).to be true
        expect(resultado[:distancia_km]).to be > 10.0
      end
    end
  end

  describe '#estadisticas' do
    before do
      create(:banco_bogota)
      create(:banco_medellin)
      create(:banco_cali)
    end

    it 'retorna estadísticas básicas' do
      stats = service.estadisticas

      expect(stats[:total_bancos]).to be > 0
    end

    it 'maneja el caso cuando no hay bancos' do
      Banco.destroy_all
      stats = service.estadisticas

      expect(stats[:total_bancos]).to eq(0)
    end
  end
end
