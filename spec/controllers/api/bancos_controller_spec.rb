require 'rails_helper'

RSpec.describe Api::BancosController, type: :controller do
  describe 'POST #create' do
    let(:valid_params) do
      {
        banco: {
          nombre: 'Banco de Prueba',
          direccion: 'Calle 123 # 45-67, Ciudad',
          latitud: 4.7110,
          longitud: -74.0721,
          evaluacion: 4.5
        }
      }
    end

    context 'con parámetros válidos' do
      it 'crea un nuevo banco' do
        expect {
          post :create, params: valid_params
        }.to change(Banco, :count).by(1)
      end

      it 'retorna status 201' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'retorna el banco creado' do
        post :create, params: valid_params
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be true
        expect(json_response['message']).to eq('Banco creado exitosamente')
        expect(json_response['data']['nombre']).to eq('Banco de Prueba')
        expect(json_response['data']['direccion']).to eq('Calle 123 # 45-67, Ciudad')
        expect(json_response['data']['latitud']).to eq(4.711)
        expect(json_response['data']['longitud']).to eq(-74.0721)
        expect(json_response['data']['evaluacion']).to eq(4.5)
      end
    end

    context 'con parámetros inválidos' do
      let(:invalid_params) do
        {
          banco: {
            nombre: '', # Inválido: nombre vacío
            direccion: 'Calle 123',
            latitud: 4.7110,
            longitud: -74.0721
          }
        }
      end

      it 'no crea un banco' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Banco, :count)
      end

      it 'retorna status 422' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'retorna errores de validación' do
        post :create, params: invalid_params
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be false
        expect(json_response['error']).to eq('Error al crear el banco')
        expect(json_response['details']).to include("Nombre can't be blank")
      end
    end
  end

  describe 'GET #show' do
    let!(:banco) { create(:banco_bogota) }

    context 'cuando el banco existe' do
      it 'retorna el banco' do
        get :show, params: { id: banco.id }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be true
        expect(json_response['data']['id']).to eq(banco.id)
        expect(json_response['data']['nombre']).to eq(banco.nombre)
        expect(json_response['data']['direccion']).to eq(banco.direccion)
      end
    end

    context 'cuando el banco no existe' do
      it 'retorna status 404' do
        get :show, params: { id: 99999 }
        expect(response).to have_http_status(:not_found)
      end

      it 'retorna mensaje de error' do
        get :show, params: { id: 99999 }
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be false
        expect(json_response['error']).to eq('Banco no encontrado')
      end
    end
  end

  describe 'GET #cercano' do
    let!(:banco_bogota) { create(:banco_bogota) }
    let!(:banco_medellin) { create(:banco_medellin) }

    context 'con parámetros válidos' do
      it 'encuentra el banco más cercano' do
        get :cercano, params: { latitud: 4.7110, longitud: -74.0721 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be true
        expect(json_response['data']['banco']['nombre']).to include('Bogotá').or(include('Prueba'))
        expect(json_response['data']['distancia_km']).to be_within(0.1).of(0.0)
        expect(json_response['data']['supera_limite']).to be false
      end

      it 'permite personalizar el límite' do
        get :cercano, params: { latitud: -34.6037, longitud: -58.3816, limite_km: 1.0 } # Buenos Aires

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data']['supera_limite']).to be true
        expect(json_response['data']['limite_km']).to eq(1.0)
      end
    end

    context 'con parámetros faltantes' do
      it 'retorna error cuando falta latitud' do
        get :cercano, params: { longitud: -74.0721 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be false
        expect(json_response['error']).to eq('Los parámetros latitud y longitud son requeridos')
      end

      it 'retorna error cuando falta longitud' do
        get :cercano, params: { latitud: 4.7110 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be false
        expect(json_response['error']).to eq('Los parámetros latitud y longitud son requeridos')
      end
    end

    context 'con coordenadas fuera de rango' do
      it 'retorna error para latitud inválida' do
        get :cercano, params: { latitud: 100, longitud: -74.0721 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be false
        expect(json_response['error']).to include('Coordenadas fuera de rango válido')
      end

      it 'retorna error para longitud inválida' do
        get :cercano, params: { latitud: 4.7110, longitud: 200 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be false
        expect(json_response['error']).to include('Coordenadas fuera de rango válido')
      end
    end

    context 'cuando no hay bancos disponibles' do
      it 'retorna error' do
        Banco.destroy_all
        get :cercano, params: { latitud: 4.7110, longitud: -74.0721 }

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be false
        expect(json_response['error']).to eq('No hay bancos disponibles en la base de datos')
      end
    end
  end
end
