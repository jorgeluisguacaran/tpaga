# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::DocumentacionController, type: :controller do
  describe 'GET #index' do
    it 'retorna el estatus HTTP ok' do
      get :index, format: :json
      expect(response).to have_http_status(:ok)
    end

    it 'retorna la documentación en formato JSON con la estructura correcta' do
      get :index, format: :json
      json_response = response.parsed_body

      expect(json_response).to include(
        success: true,
        data: a_hash_including(
          nombre: 'Bancos API',
          version: '1.0.0',
          descripcion: 'API para gestión de bancos y búsqueda del banco más cercano',
        ),
      )
    end

    it 'incluye los endpoints de la API' do
      get :index, format: :json
      json_response = response.parsed_body

      endpoints = json_response['data']['endpoints']
      expect(endpoints).to be_an(Array)
      expect(endpoints.length).to eq(4)

      # Verificar que incluye el endpoint de creación
      create_endpoint = endpoints.find { |e| e['metodo'] == 'POST' && e['ruta'] == '/api/bancos' }
      expect(create_endpoint).to be_present
      expect(create_endpoint['descripcion']).to eq('Crear un nuevo banco')

      # Verificar que incluye el endpoint de mostrar
      show_endpoint = endpoints.find { |e| e['metodo'] == 'GET' && e['ruta'] == '/api/bancos/:id' }
      expect(show_endpoint).to be_present
      expect(show_endpoint['descripcion']).to eq('Obtener un banco por ID')

      # Verificar que incluye el endpoint de cercano
      cercano_endpoint = endpoints.find { |e| e['metodo'] == 'GET' && e['ruta'] == '/api/bancos/cercano' }
      expect(cercano_endpoint).to be_present
      expect(cercano_endpoint['descripcion']).to eq('Encontrar el banco más cercano a un punto')

      # Verificar que incluye el endpoint de estadísticas
      stats_endpoint = endpoints.find { |e| e['metodo'] == 'GET' && e['ruta'] == '/api/documentacion/estadisticas' }
      expect(stats_endpoint).to be_present
      expect(stats_endpoint['descripcion']).to eq('Obtener estadísticas de los bancos')
    end

    it 'incluye la información de respuestas' do
      get :index, format: :json
      json_response = response.parsed_body

      respuestas = json_response['data']['respuestas']
      expect(respuestas).to include('exito', 'error')

      expect(respuestas['exito']).to include(
        success: true,
        data: 'datos del recurso',
      )

      expect(respuestas['error']).to include(
        success: false,
        error: 'Mensaje de error',
        details: ['Detalles adicionales'],
      )
    end

    it 'incluye los códigos de estado HTTP' do
      get :index, format: :json
      json_response = response.parsed_body

      codigos = json_response['data']['codigos_estado']
      expect(codigos).to include(
        '200': 'OK - Operación exitosa',
        '201': 'Created - Recurso creado exitosamente',
        '400': 'Bad Request - Parámetros inválidos',
        '404': 'Not Found - Recurso no encontrado',
        '422': 'Unprocessable Entity - Error de validación',
      )
    end

    it 'el endpoint de creación incluye parámetros y ejemplo' do
      get :index, format: :json
      json_response = response.parsed_body

      create_endpoint = json_response['data']['endpoints'].find { |e| e['metodo'] == 'POST' }
      expect(create_endpoint['parametros']).to include('banco')
      expect(create_endpoint['ejemplo']).to include('banco')
      expect(create_endpoint['ejemplo']['banco']).to include(
        nombre: 'Banco de Bogotá',
        direccion: 'Calle 123 # 45-67, Bogotá',
      )
    end
  end

  describe 'GET #estadisticas' do
    before do
      # Limpiar bancos existentes y crear solo los necesarios para la prueba
      Banco.destroy_all
      @banco1 = create(:banco_bogota)
      @banco2 = create(:banco_medellin)
    end

    it 'retorna el estatus HTTP ok' do
      get :estadisticas, format: :json
      expect(response).to have_http_status(:ok)
    end

    it 'retorna las estadísticas en formato JSON' do
      get :estadisticas, format: :json
      json_response = response.parsed_body

      expect(json_response).to include(
        success: true,
        data: a_hash_including(
          estadisticas: a_hash_including('total_bancos'),
          timestamp: be_present,
        ),
      )
    end

    it 'incluye el número correcto de bancos' do
      get :estadisticas, format: :json
      json_response = response.parsed_body

      expect(json_response['data']['estadisticas']['total_bancos']).to eq(2)
    end

    it 'incluye un timestamp en formato ISO8601' do
      get :estadisticas, format: :json
      json_response = response.parsed_body

      timestamp = json_response['data']['timestamp']
      expect(timestamp).to match(%r{\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}})
    end

    it 'actualiza las estadísticas cuando se agregan bancos' do
      get :estadisticas, format: :json
      initial_count = response.parsed_body['data']['estadisticas']['total_bancos']

      create(:banco_cali)

      get :estadisticas, format: :json
      new_count = response.parsed_body['data']['estadisticas']['total_bancos']

      expect(new_count).to eq(initial_count + 1)
    end
  end
end
