require 'rails_helper'

RSpec.describe "Api::Bancos", type: :request do
  describe "POST /api/bancos" do
    let(:valid_attributes) do
      {
        banco: {
          nombre: "Banco de Prueba",
          direccion: "Calle 123 # 45-67, Bogotá",
          latitud: 4.7110,
          longitud: -74.0721,
          evaluacion: 4.5
        }
      }
    end

    let(:invalid_attributes) do
      {
        banco: {
          nombre: "",
          direccion: "Calle 123",
          latitud: 100.0, # Inválido
          longitud: -74.0721,
          evaluacion: 6.0 # Inválido
        }
      }
    end

    context "con parámetros válidos" do
      it "crea un nuevo banco" do
        expect {
          post "/api/bancos", params: valid_attributes
        }.to change(Banco, :count).by(1)
      end

      it "retorna el banco creado" do
        post "/api/bancos", params: valid_attributes

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)

        expect(json_response["success"]).to be true
        expect(json_response["message"]).to eq("Banco creado exitosamente")
        expect(json_response["data"]["nombre"]).to eq("Banco de Prueba")
        expect(json_response["data"]["latitud"]).to eq(4.7110)
        expect(json_response["data"]["longitud"]).to eq(-74.0721)
        expect(json_response["data"]["evaluacion"]).to eq(4.5)
      end
    end

    context "con parámetros inválidos" do
      it "no crea un banco" do
        expect {
          post "/api/bancos", params: invalid_attributes
        }.not_to change(Banco, :count)
      end

      it "retorna errores de validación" do
        post "/api/bancos", params: invalid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)

        expect(json_response["success"]).to be false
        expect(json_response["error"]).to eq("Error al crear el banco")
        expect(json_response["details"]).to include("Nombre no puede estar en blanco")
        expect(json_response["details"]).to include("Latitud debe ser menor o igual a 90")
        expect(json_response["details"]).to include("Evaluacion debe ser menor o igual a 5")
      end
    end
  end

  describe "GET /api/bancos/:id" do
    let(:banco) { create(:banco) }

    context "cuando el banco existe" do
      it "retorna el banco" do
        get "/api/bancos/#{banco.id}"

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response["success"]).to be true
        expect(json_response["data"]["id"]).to eq(banco.id)
        expect(json_response["data"]["nombre"]).to eq(banco.nombre)
        expect(json_response["data"]["direccion"]).to eq(banco.direccion)
        expect(json_response["data"]["latitud"]).to eq(banco.latitud.to_f)
        expect(json_response["data"]["longitud"]).to eq(banco.longitud.to_f)
        expect(json_response["data"]["evaluacion"]).to eq(banco.evaluacion.to_f)
      end
    end

    context "cuando el banco no existe" do
      it "retorna error 404" do
        get "/api/bancos/999999"

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)

        expect(json_response["success"]).to be false
        expect(json_response["error"]).to eq("Banco no encontrado")
      end
    end
  end

  describe "GET /api/bancos/cercano" do
    let!(:banco_bogota) { create(:banco, nombre: "Banco Bogotá", latitud: 4.7110, longitud: -74.0721) }
    let!(:banco_medellin) { create(:banco, nombre: "Banco Medellín", latitud: 6.2442, longitud: -75.5812) }

    context "con coordenadas válidas" do
      it "encuentra el banco más cercano" do
        get "/api/bancos/cercano", params: { latitud: 4.7110, longitud: -74.0721 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response["success"]).to be true
        expect(json_response["data"]["banco"]["nombre"]).to eq("Banco Bogotá")
        expect(json_response["data"]["distancia_km"]).to be_within(0.1).of(0.0)
        expect(json_response["data"]["supera_limite"]).to be false
        expect(json_response["data"]["limite_km"]).to eq(10.0)
      end

      it "notifica cuando supera el límite de distancia" do
        get "/api/bancos/cercano", params: { latitud: 10.0, longitud: -80.0, limite_km: 5.0 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response["success"]).to be true
        expect(json_response["data"]["supera_limite"]).to be true
        expect(json_response["data"]["limite_km"]).to eq(5.0)
      end
    end

    context "con coordenadas inválidas" do
      it "retorna error cuando faltan parámetros" do
        get "/api/bancos/cercano", params: { latitud: 4.7110 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)

        expect(json_response["success"]).to be false
        expect(json_response["error"]).to eq("Los parámetros latitud y longitud son requeridos")
      end

      it "retorna error cuando las coordenadas están fuera de rango" do
        get "/api/bancos/cercano", params: { latitud: 100.0, longitud: -74.0721 }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)

        expect(json_response["success"]).to be false
        expect(json_response["error"]).to eq("Coordenadas fuera de rango válido (latitud: -90 a 90, longitud: -180 a 180)")
      end
    end

    context "cuando no hay bancos" do
      it "retorna error 404" do
        Banco.destroy_all

        get "/api/bancos/cercano", params: { latitud: 4.7110, longitud: -74.0721 }

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)

        expect(json_response["success"]).to be false
        expect(json_response["error"]).to eq("No hay bancos disponibles en la base de datos")
      end
    end
  end
end
