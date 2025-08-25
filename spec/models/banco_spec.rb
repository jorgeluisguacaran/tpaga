require 'rails_helper'

RSpec.describe Banco, type: :model do
  describe 'validaciones' do
    subject { build(:banco) }

    it { should validate_presence_of(:nombre) }
    it { should validate_presence_of(:direccion) }
    it { should validate_presence_of(:latitud) }
    it { should validate_presence_of(:longitud) }

    it { should validate_length_of(:nombre).is_at_least(2).is_at_most(100) }
    it { should validate_length_of(:direccion).is_at_least(5).is_at_most(200) }

    it { should validate_numericality_of(:latitud).is_greater_than_or_equal_to(-90).is_less_than_or_equal_to(90) }
    it { should validate_numericality_of(:longitud).is_greater_than_or_equal_to(-180).is_less_than_or_equal_to(180) }
    it { should validate_numericality_of(:evaluacion).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(5).allow_nil }
  end

  describe 'scopes' do
    let!(:banco_alto) { create(:banco_alta_evaluacion, evaluacion: 4.5) }
    let!(:banco_medio) { create(:banco, evaluacion: 3.0) }
    let!(:banco_bajo) { create(:banco_baja_evaluacion, evaluacion: 2.0) }

    describe '.ordenados_por_evaluacion' do
      it 'ordena los bancos por evaluación descendente' do
        expect(Banco.ordenados_por_evaluacion).to eq([banco_alto, banco_medio, banco_bajo])
      end
    end

    describe '.con_evaluacion_minima' do
      it 'filtra bancos con evaluación mínima de 3.0' do
        expect(Banco.con_evaluacion_minima(3.0)).to include(banco_alto, banco_medio)
        expect(Banco.con_evaluacion_minima(3.0)).not_to include(banco_bajo)
      end

      it 'usa 3.0 como valor por defecto' do
        expect(Banco.con_evaluacion_minima).to include(banco_alto, banco_medio)
        expect(Banco.con_evaluacion_minima).not_to include(banco_bajo)
      end
    end
  end

  describe '#distancia_a' do
    let(:banco) { create(:banco, latitud: 4.7110, longitud: -74.0721) } # Bogotá centro

    it 'calcula la distancia correctamente a un punto cercano' do
      # Punto cercano en Bogotá
      distancia = banco.distancia_a(4.7110, -74.0721)
      expect(distancia).to be_within(0.1).of(0.0)
    end

    it 'calcula la distancia a un punto lejano' do
      # Punto en Medellín
      distancia = banco.distancia_a(6.2442, -75.5812)
      expect(distancia).to be > 200 # Debería ser más de 200km
    end

    it 'retorna nil si las coordenadas son inválidas' do
      expect(banco.distancia_a(nil, -74.0721)).to be_nil
      expect(banco.distancia_a(4.7110, nil)).to be_nil
    end
  end

  describe '#dentro_del_radio?' do
    let(:banco) { create(:banco, latitud: 4.7110, longitud: -74.0721) }

    it 'retorna true si está dentro del radio' do
      # Punto a 5km del banco
      expect(banco.dentro_del_radio?(4.7110, -74.0721, 10)).to be true
    end

    it 'retorna false si está fuera del radio' do
      # Punto en Medellín (muy lejos)
      expect(banco.dentro_del_radio?(6.2442, -75.5812, 10)).to be false
    end

    it 'usa 10km como radio por defecto' do
      expect(banco.dentro_del_radio?(4.7110, -74.0721)).to be true
    end
  end

  describe '.mas_cercano_a' do
    let!(:banco_bogota) { create(:banco, nombre: 'Banco Bogotá', latitud: 4.7110, longitud: -74.0721) }
    let!(:banco_medellin) { create(:banco, nombre: 'Banco Medellín', latitud: 6.2442, longitud: -75.5812) }

    it 'encuentra el banco más cercano' do
      resultado = Banco.mas_cercano_a(4.7110, -74.0721)
      expect(resultado[:banco]).to eq(banco_bogota)
      expect(resultado[:distancia_km]).to be_within(0.1).of(0.0)
      expect(resultado[:supera_limite]).to be false
    end

    it 'notifica cuando supera el límite de distancia' do
      # Buscar desde un punto muy lejano
      resultado = Banco.mas_cercano_a(10.0, -80.0, 5.0) # Límite de 5km
      expect(resultado[:supera_limite]).to be true
    end

    it 'retorna nil si no hay bancos' do
      Banco.destroy_all
      expect(Banco.mas_cercano_a(4.7110, -74.0721)).to be_nil
    end

    it 'retorna nil si las coordenadas son inválidas' do
      expect(Banco.mas_cercano_a(nil, -74.0721)).to be_nil
      expect(Banco.mas_cercano_a(4.7110, nil)).to be_nil
    end
  end
end
