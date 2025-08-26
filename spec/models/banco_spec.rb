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

    it 'retorna nil cuando la latitud es nil' do
      expect(banco.distancia_a(nil, -74.0721)).to be_nil
    end

    it 'retorna nil cuando la longitud es nil' do
      expect(banco.distancia_a(4.7110, nil)).to be_nil
    end
  end

  describe '.mas_cercano_a' do
    let!(:banco_bogota) { create(:banco_bogota) }
    let!(:banco_medellin) { create(:banco_medellin) }
    let!(:banco_cali) { create(:banco_cali) }

    context 'cuando hay bancos disponibles' do
      # Pruebas para encontrar el banco más cercano
      it 'encuentra un resultado' do
        resultado = Banco.mas_cercano_a(4.7110, -74.0721)
        expect(resultado).to be_present
      end

      it 'encuentra el banco más cercano por nombre' do
        resultado = Banco.mas_cercano_a(4.7110, -74.0721)
        expect(resultado[:banco].nombre).to include('Bogotá').or(include('Prueba'))
      end

      it 'calcula la distancia correctamente' do
        resultado = Banco.mas_cercano_a(4.7110, -74.0721)
        expect(resultado[:distancia_km]).to be_within(0.1).of(0.0)
      end

      it 'indica que no supera el límite de distancia' do
        resultado = Banco.mas_cercano_a(4.7110, -74.0721)
        expect(resultado[:supera_limite]).to be false
      end

      # Pruebas para notificar cuando supera el límite
      it 'notifica cuando supera el límite' do
        resultado = Banco.mas_cercano_a(-34.6037, -58.3816, 10.0) # Buenos Aires
        expect(resultado[:supera_limite]).to be true
      end
      
      it 'calcula una distancia mayor al límite' do
        resultado = Banco.mas_cercano_a(-34.6037, -58.3816, 10.0)
        expect(resultado[:distancia_km]).to be > 10.0
      end

      # Pruebas para personalizar el límite
      it 'permite personalizar el límite' do
        resultado = Banco.mas_cercano_a(-34.6037, -58.3816, 1.0)
        expect(resultado[:limite_km]).to eq(1.0)
      end

      it 'indica que supera el límite personalizado' do
        resultado = Banco.mas_cercano_a(-34.6037, -58.3816, 1.0)
        expect(resultado[:supera_limite]).to be true
      end
    end

    context 'cuando no hay bancos' do
      before { Banco.destroy_all }

      it 'retorna nil' do
        resultado = Banco.mas_cercano_a(4.7110, -74.0721)
        expect(resultado).to be_nil
      end
    end

    context 'con coordenadas inválidas' do
      it 'retorna nil para latitud nil' do
        resultado = Banco.mas_cercano_a(nil, -74.0721)
        expect(resultado).to be_nil
      end

      it 'retorna nil para longitud nil' do
        resultado = Banco.mas_cercano_a(4.7110, nil)
        expect(resultado).to be_nil
      end
    end
  end

  describe '#dentro_del_radio?' do
    let(:banco) { create(:banco_bogota) }

    it 'retorna true cuando está dentro del radio' do
      # Punto muy cercano a Bogotá
      expect(banco.dentro_del_radio?(4.7110, -74.0721, 1.0)).to be true
    end

    it 'retorna false cuando está fuera del radio' do
      # Punto lejano (Medellín)
      expect(banco.dentro_del_radio?(6.2442, -75.5812, 1.0)).to be false
    end

    it 'usa 10km como radio por defecto' do
      # Punto a 5km de Bogotá
      expect(banco.dentro_del_radio?(4.7560, -74.0721)).to be true
    end

    it 'retorna false cuando la latitud es nil' do
      expect(banco.dentro_del_radio?(nil, -74.0721)).to be false
    end

    it 'retorna false cuando la longitud es nil' do
      expect(banco.dentro_del_radio?(4.7110, nil)).to be false
    end
  end
end
