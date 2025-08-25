require 'rails_helper'

RSpec.describe Banco, type: :model do
  describe 'validaciones' do
    subject { build(:banco) }

    it { should validate_presence_of(:nombre) }
    it { should validate_length_of(:nombre).is_at_least(2).is_at_most(100) }

    it { should validate_presence_of(:direccion) }
    it { should validate_length_of(:direccion).is_at_least(5).is_at_most(200) }

    it { should validate_presence_of(:latitud) }
    it { should validate_numericality_of(:latitud).is_greater_than_or_equal_to(-90).is_less_than_or_equal_to(90) }

    it { should validate_presence_of(:longitud) }
    it { should validate_numericality_of(:longitud).is_greater_than_or_equal_to(-180).is_less_than_or_equal_to(180) }

    it { should validate_numericality_of(:evaluacion).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(5).allow_nil }
  end

  describe 'scopes' do
    let!(:banco_alto) { create(:banco_alta_evaluacion, evaluacion: 4.8) }
    let!(:banco_medio) { create(:banco, evaluacion: 3.5) }
    let!(:banco_bajo) { create(:banco_baja_evaluacion, evaluacion: 2.0) }

    describe '.ordenados_por_evaluacion' do
      it 'ordena los bancos por evaluación descendente' do
        resultado = Banco.ordenados_por_evaluacion
        expect(resultado.first.evaluacion).to be >= resultado.last.evaluacion
      end
    end

    describe '.con_evaluacion_minima' do
      it 'filtra bancos con evaluación mínima de 4.0' do
        expect(Banco.con_evaluacion_minima(4.0)).to include(banco_alto)
        expect(Banco.con_evaluacion_minima(4.0)).not_to include(banco_medio, banco_bajo)
      end

      it 'usa 3.0 como valor por defecto' do
        expect(Banco.con_evaluacion_minima).to include(banco_alto, banco_medio)
        expect(Banco.con_evaluacion_minima).not_to include(banco_bajo)
      end
    end
  end

  describe '#distancia_a' do
    let(:banco) { create(:banco_bogota) }

    it 'calcula la distancia correctamente' do
      # Punto cercano a Bogotá
      distancia = banco.distancia_a(4.7110, -74.0721)
      expect(distancia).to be_within(0.1).of(0.0)
    end

    it 'calcula distancia a un punto lejano' do
      # Punto en Medellín
      distancia = banco.distancia_a(6.2442, -75.5812)
      expect(distancia).to be > 200 # Debería ser más de 200km
    end

    it 'retorna nil para coordenadas inválidas' do
      expect(banco.distancia_a(nil, -74.0721)).to be_nil
      expect(banco.distancia_a(4.7110, nil)).to be_nil
    end
  end

  describe '.mas_cercano_a' do
    let!(:banco_bogota) { create(:banco_bogota) }
    let!(:banco_medellin) { create(:banco_medellin) }
    let!(:banco_cali) { create(:banco_cali) }

    context 'cuando hay bancos disponibles' do
      it 'encuentra el banco más cercano' do
        # Punto en Bogotá
        resultado = Banco.mas_cercano_a(4.7110, -74.0721)

        expect(resultado).to be_present
        expect(resultado[:banco].nombre).to include('Bogotá').or(include('Prueba'))
        expect(resultado[:distancia_km]).to be_within(0.1).of(0.0)
        expect(resultado[:supera_limite]).to be false
      end

      it 'notifica cuando supera el límite' do
        # Punto muy lejano (ej: en el sur de Argentina)
        resultado = Banco.mas_cercano_a(-34.6037, -58.3816, 10.0)

        expect(resultado).to be_present
        expect(resultado[:supera_limite]).to be true
        expect(resultado[:distancia_km]).to be > 10.0
      end

      it 'permite personalizar el límite' do
        # Punto muy lejano con límite de 1km
        resultado = Banco.mas_cercano_a(-34.6037, -58.3816, 1.0) # Buenos Aires

        expect(resultado[:supera_limite]).to be true
        expect(resultado[:limite_km]).to eq(1.0)
      end
    end

    context 'cuando no hay bancos' do
      it 'retorna nil' do
        Banco.destroy_all
        resultado = Banco.mas_cercano_a(4.7110, -74.0721)
        expect(resultado).to be_nil
      end
    end

    context 'con coordenadas inválidas' do
      it 'retorna nil' do
        expect(Banco.mas_cercano_a(nil, -74.0721)).to be_nil
        expect(Banco.mas_cercano_a(4.7110, nil)).to be_nil
      end
    end
  end

  describe '#dentro_del_radio?' do
    let(:banco) { create(:banco_bogota) }

    it 'retorna true para puntos dentro del radio' do
      # Punto muy cercano
      expect(banco.dentro_del_radio?(4.7110, -74.0721, 1.0)).to be true
    end

    it 'retorna false para puntos fuera del radio' do
      # Punto lejano
      expect(banco.dentro_del_radio?(6.2442, -75.5812, 1.0)).to be false
    end

    it 'usa 10km como radio por defecto' do
      # Punto a 5km (aproximadamente)
      expect(banco.dentro_del_radio?(4.7560, -74.0721)).to be true
    end
  end
end
