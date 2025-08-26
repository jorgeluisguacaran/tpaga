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
          service.crear_banco(valid_params)
        }.to change(Banco, :count).by(1)
      end

      it 'el resultado es exitoso' do
        resultado = service.crear_banco(valid_params)
        expect(resultado[:success]).to be true
      end

      it 'el resultado retorna un objeto Banco' do
        resultado = service.crear_banco(valid_params)
        expect(resultado[:banco]).to be_a(Banco)
      end

      it 'el banco creado tiene el nombre correcto' do
        resultado = service.crear_banco(valid_params)
        expect(resultado[:banco].nombre).to eq('Banco de Prueba')
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

      it 'no crea el banco' do
        expect {
          service.crear_banco(invalid_params)
        }.not_to change(Banco, :count)
      end

      it 'el resultado es falso' do
        resultado = service.crear_banco(invalid_params)
        expect(resultado[:success]).to be false
      end

      it 'retorna los errores de validación' do
        resultado = service.crear_banco(invalid_params)
        expect(resultado[:errors]).to include("Nombre can't be blank")
      end
    end
  end

  describe '#buscar_por_id' do
    let!(:banco) { create(:banco_bogota) }

    context 'cuando el banco existe' do
      it 'el resultado es exitoso' do
        resultado = service.buscar_por_id(banco.id)
        expect(resultado[:success]).to be true
      end

      it 'retorna el banco encontrado' do
        resultado = service.buscar_por_id(banco.id)
        expect(resultado[:banco]).to eq(banco)
      end
    end

    context 'cuando el banco no existe' do
      it 'retorna que el resultado no fue exitoso' do
        resultado = service.buscar_por_id(99999)
        expect(resultado[:success]).to be false
      end

      it 'retorna un mensaje de error' do
        resultado = service.buscar_por_id(99999)
        expect(resultado[:errors]).to include('Banco no encontrado')
      end
    end
  end

  describe '#encontrar_mas_cercano' do
    let!(:banco_bogota) { create(:banco_bogota) }
    let!(:banco_medellin) { create(:banco_medellin) }

    context 'con coordenadas válidas' do
      it 'retorna un resultado exitoso' do
        resultado = service.encontrar_mas_cercano(4.7110, -74.0721)
        expect(resultado[:success]).to be true
      end

      it 'encuentra el banco más cercano y retorna su nombre' do
        resultado = service.encontrar_mas_cercano(4.7110, -74.0721)
        expect(resultado[:banco].nombre).to include('Bogotá').or(include('Prueba'))
      end

      it 'calcula la distancia correctamente' do
        resultado = service.encontrar_mas_cercano(4.7110, -74.0721)
        expect(resultado[:distancia_km]).to be_within(0.1).of(0.0)
      end

      it 'indica que la distancia no supera el límite' do
        resultado = service.encontrar_mas_cercano(4.7110, -74.0721)
        expect(resultado[:supera_limite]).to be false
      end

      it 'retorna el límite de distancia por defecto' do
        resultado = service.encontrar_mas_cercano(4.7110, -74.0721)
        expect(resultado[:limite_km]).to eq(10.0)
      end

      it 'permite personalizar el límite de distancia' do
        resultado = service.encontrar_mas_cercano(4.7110, -74.0721, 5.0)
        expect(resultado[:limite_km]).to eq(5.0)
      end
    end

    context 'con coordenadas inválidas' do
      it 'retorna que el resultado no fue exitoso' do
        resultado = service.encontrar_mas_cercano(nil, -74.0721)
        expect(resultado[:success]).to be false
      end

      it 'retorna un mensaje de error' do
        resultado = service.encontrar_mas_cercano(nil, -74.0721)
        expect(resultado[:errors]).to include('Coordenadas inválidas')
      end
    end

    context 'cuando no hay bancos' do
      before { Banco.destroy_all }

      it 'retorna que el resultado no fue exitoso' do
        resultado = service.encontrar_mas_cercano(4.7110, -74.0721)
        expect(resultado[:success]).to be false
      end

      it 'retorna un mensaje de error' do
        resultado = service.encontrar_mas_cercano(4.7110, -74.0721)
        expect(resultado[:errors]).to include('No hay bancos disponibles')
      end
    end

    context 'cuando supera el límite de distancia' do
      it 'envía una advertencia al log sobre el banco más cercano' do
        expect(Rails.logger).to receive(:warn).with(/Banco más cercano/).at_least(:once)
        service.encontrar_mas_cercano(-34.6037, -58.3816, 10.0)
      end

      it 'envía una notificación al log sobre la distancia excesiva' do
        expect(Rails.logger).to receive(:info).with(/Notificación de distancia excesiva/).at_least(:once)
        service.encontrar_mas_cercano(-34.6037, -58.3816, 10.0)
      end

      it 'retorna que el resultado fue exitoso' do
        resultado = service.encontrar_mas_cercano(-34.6037, -58.3816, 10.0)
        expect(resultado[:success]).to be true
      end

      it 'indica que la distancia supera el límite' do
        resultado = service.encontrar_mas_cercano(-34.6037, -58.3816, 10.0)
        expect(resultado[:supera_limite]).to be true
      end

      it 'calcula una distancia mayor al límite' do
        resultado = service.encontrar_mas_cercano(-34.6037, -58.3816, 10.0)
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
