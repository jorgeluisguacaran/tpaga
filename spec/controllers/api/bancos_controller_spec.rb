require 'rails_helper'

RSpec.describe Api::BancosController, type: :controller do
  describe 'GET #show' do
    let(:banco) { create(:banco_bogota) }

    context 'cuando el banco existe' do

      it 'retorna el estatus HTTP ok' do
        get :show, params: { id: banco.id }, format: :json, format: :json
        expect(response).to have_http_status(:ok)
      end

      it 'retorna el banco en formato JSON con los atributos correctos' do
        get :show, params: { id: banco.id }, format: :json, format: :json
        json_response = JSON.parse(response.body)

        expect(json_response).to include(
          'success' => true,
          'data' => a_hash_including(
            'id' => banco.id,
            'nombre' => banco.nombre,
            'direccion' => banco.direccion,
            'latitud' => banco.latitud.to_f,
            'longitud' => banco.longitud.to_f
          )
        )
      end

      it 'el JSON incluye las marcas de tiempo created_at y updated_at' do
        get :show, params: { id: banco.id }, format: :json
        json_response = JSON.parse(response.body)

        expect(json_response['data']).to include(
          'created_at' => be_present,
          'updated_at' => be_present
        )
      end
    end

    context 'cuando el banco no existe' do
      it 'retorna el estatus HTTP de no encontrado' do
        get :show, params: { id: 99999 }, format: :json
        expect(response).to have_http_status(:not_found)
      end

      it 'retorna un mensaje de error en formato JSON' do
        get :show, params: { id: 99999 }, format: :json
        json_response = JSON.parse(response.body)

        expect(json_response).to include(
          'success' => false,
          'error' => 'Banco no encontrado'
        )
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        banco: {
          nombre: 'Banco de Prueba',
          direccion: 'Calle 123 # 45-67, Bogotá',
          latitud: 4.7110,
          longitud: -74.0721
        }
      }
    end

    context 'con parámetros válidos' do
      it 'crea un nuevo banco' do
        expect {
          post :create, params: valid_params, format: :json
        }.to change(Banco, :count).by(1)
      end

      it 'responde con el estatus de HTTP creado' do
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:created)
      end

      it 'responde con el JSON correcto incluyendo los datos del banco' do
        post :create, params: valid_params, format: :json
        json_response = JSON.parse(response.body)

        expect(json_response).to include(
          'success' => true,
          'message' => 'Banco creado exitosamente',
          'data' => a_hash_including(
            'nombre' => 'Banco de Prueba',
            'direccion' => 'Calle 123 # 45-67, Bogotá',
            'latitud' => 4.711,
            'longitud' => -74.0721
          )
        )
      end
    end

    context 'con parámetros inválidos' do
      let(:invalid_params) do
        {
          banco: {
            nombre: '',
            direccion: 'Calle 123',
            latitud: 4.7110,
            longitud: -74.0721
          }
        }
      end

      it 'no crea el banco' do
        expect {
          post :create, params: invalid_params, format: :json
        }.not_to change(Banco, :count)
      end

      it 'responde con el estatus HTTP de entidad no procesable' do
        post :create, params: invalid_params, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'retorna un JSON de error con los detalles de la validación' do
        post :create, params: invalid_params, format: :json
        json_response = JSON.parse(response.body)

        expect(json_response).to include(
          'success' => false,
          'error' => 'Error al crear el banco',
          'details' => include("Nombre can't be blank")
        )
      end
    end
  end

  describe 'GET #cercano' do
    let!(:banco_bogota) { create(:banco_bogota) }
    let!(:banco_medellin) { create(:banco_medellin) }

    context 'con coordenadas válidas' do
      it 'retorna el estatus HTTP ok' do
        get :cercano, params: { latitud: 4.7110, longitud: -74.0721 }, format: :json
        expect(response).to have_http_status(:ok)
      end

      it 'retorna el JSON correcto del banco más cercano' do
        get :cercano, params: { latitud: 4.7110, longitud: -74.0721 }, format: :json
        json_response = JSON.parse(response.body)

        expect(json_response).to include(
          'success' => true,
          'data' => a_hash_including(
            'banco' => a_hash_including('nombre' => include('Bogotá').or(include('Prueba'))),
            'supera_limite' => false,
            'limite_km' => 10.0
          )
        )
      end

      it 'calcula la distancia correctamente' do
        get :cercano, params: { latitud: 4.7110, longitud: -74.0721 }, format: :json
        json_response = JSON.parse(response.body)

        expect(json_response['data']['distancia_km']).to be_within(0.1).of(0.0)
      end

      it 'permite personalizar el límite de distancia' do
        get :cercano, params: { latitud: 4.7110, longitud: -74.0721, limite_km: 5.0 }
        expect(response).to have_http_status(:ok)
      end

      it 'retorna el límite de distancia personalizado en el JSON' do
        get :cercano, params: { latitud: 4.7110, longitud: -74.0721, limite_km: 5.0 }
        json_response = JSON.parse(response.body)

        expect(json_response.dig('data', 'limite_km')).to eq(5.0)
      end
    end

    context 'cuando no hay bancos' do
      before { Banco.destroy_all }

      it 'retorna el estatus HTTP de no encontrado' do
        get :cercano, params: { latitud: 4.7110, longitud: -74.0721 }, format: :json
        expect(response).to have_http_status(:not_found)
      end

      it 'retorna un JSON de error con un mensaje descriptivo' do
        get :cercano, params: { latitud: 4.7110, longitud: -74.0721 }, format: :json
        json_response = JSON.parse(response.body)

        expect(json_response).to include(
          'success' => false,
          'error' => 'No hay bancos disponibles en la base de datos'
        )
      end
    end

    context 'con parámetros faltantes' do
      it 'retorna el estatus HTTP de solicitud incorrecta cuando falta latitud' do
        get :cercano, params: { longitud: -74.0721 }
        expect(response).to have_http_status(:bad_request)
      end

      it 'retorna un JSON de error cuando falta latitud' do
        get :cercano, params: { longitud: -74.0721 }
        json_response = JSON.parse(response.body)

        expect(json_response).to include(
          'success' => false,
          'error' => 'Los parámetros latitud y longitud son requeridos'
        )
      end

      it 'retorna el estatus HTTP de solicitud incorrecta cuando falta longitud' do
        get :cercano, params: { latitud: 4.7110 }
        expect(response).to have_http_status(:bad_request)
      end

      it 'retorna un JSON de error cuando falta longitud' do
        get :cercano, params: { latitud: 4.7110 }
        json_response = JSON.parse(response.body)

        expect(json_response).to include(
          'success' => false,
          'error' => 'Los parámetros latitud y longitud son requeridos'
        )
      end
    end

    context 'con coordenadas inválidas' do
      it 'retorna el estatus HTTP de solicitud incorrecta para latitud fuera de rango' do
        get :cercano, params: { latitud: 100, longitud: -74.0721 }
        expect(response).to have_http_status(:bad_request)
      end

      it 'retorna un JSON de error para latitud fuera de rango' do
        get :cercano, params: { latitud: 100, longitud: -74.0721 }
        json_response = JSON.parse(response.body)

        expect(json_response).to include(
          'success' => false,
          'error' => include('Coordenadas fuera de rango válido')
        )
      end

      it 'retorna el estatus HTTP de solicitud incorrecta para longitud fuera de rango' do
        get :cercano, params: { latitud: 4.7110, longitud: 200 }
        expect(response).to have_http_status(:bad_request)
      end

      it 'retorna un JSON de error para longitud fuera de rango' do
        get :cercano, params: { latitud: 4.7110, longitud: 200 }
        json_response = JSON.parse(response.body)

        expect(json_response).to include(
          'success' => false,
          'error' => include('Coordenadas fuera de rango válido')
        )
      end
    end
  end
end
