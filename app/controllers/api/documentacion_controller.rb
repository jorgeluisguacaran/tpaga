# frozen_string_literal: true

# Controller para la documentación de la API
module Api
  class DocumentacionController < ApplicationController
    # GET /api/documentacion
    def index
      endpoints = build_endpoints_data

      render json: {
        success: true,
        data: {
          nombre: 'Bancos API',
          version: '1.0.0',
          descripcion: 'API para gestión de bancos y búsqueda del banco más cercano',
          endpoints: endpoints,
          respuestas: {
            exito: {
              success: true,
              data: 'datos del recurso',
            },
            error: {
              success: false,
              error: 'Mensaje de error',
              details: ['Detalles adicionales'],
            },
          },
          codigos_estado: {
            '200': 'OK - Operación exitosa',
            '201': 'Created - Recurso creado exitosamente',
            '400': 'Bad Request - Parámetros inválidos',
            '404': 'Not Found - Recurso no encontrado',
            '422': 'Unprocessable Entity - Error de validación',
          },
        },
      }
    end

    # GET /api/documentacion/estadisticas
    def estadisticas
      stats = build_stats_data
      timestamp = Time.current.iso8601

      render json: {
        success: true,
        data: {
          estadisticas: stats,
          timestamp: timestamp,
        },
      }
    end

    private

    # Construye los datos de los endpoints para la documentación
    def build_endpoints_data
      [
        build_create_endpoint,
        build_show_endpoint,
        build_cercano_endpoint,
        build_stats_endpoint,
      ]
    end

    # Construye el endpoint de creación de bancos
    def build_create_endpoint
      {
        metodo: 'POST',
        ruta: '/api/bancos',
        descripcion: 'Crear un nuevo banco',
        parametros: build_create_params,
        ejemplo: build_create_example,
      }
    end

    # Construye los parámetros del endpoint de creación
    def build_create_params
      {
        banco: {
          nombre: 'string (requerido, 2-100 caracteres)',
          direccion: 'string (requerido, 5-200 caracteres)',
          latitud: 'decimal (requerido, -90 a 90)',
          longitud: 'decimal (requerido, -180 a 180)',
        },
      }
    end

    # Construye el ejemplo del endpoint de creación
    def build_create_example
      {
        banco: {
          nombre: 'Banco de Bogotá',
          direccion: 'Calle 123 # 45-67, Bogotá',
          latitud: 4.7110,
          longitud: -74.0721,
        },
      }
    end

    # Construye el endpoint de mostrar banco
    def build_show_endpoint
      {
        metodo: 'GET',
        ruta: '/api/bancos/:id',
        descripcion: 'Obtener un banco por ID',
        parametros: {
          id: 'integer (requerido)',
        },
        ejemplo: '/api/bancos/1',
      }
    end

    # Construye el endpoint de banco más cercano
    def build_cercano_endpoint
      {
        metodo: 'GET',
        ruta: '/api/bancos/cercano',
        descripcion: 'Encontrar el banco más cercano a un punto',
        parametros: {
          latitud: 'decimal (requerido, -90 a 90)',
          longitud: 'decimal (requerido, -180 a 180)',
          limite_km: 'decimal (opcional, por defecto 10.0)',
        },
        ejemplo: '/api/bancos/cercano?latitud=4.7110&longitud=-74.0721&limite_km=5.0',
      }
    end

    # Construye el endpoint de estadísticas
    def build_stats_endpoint
      {
        metodo: 'GET',
        ruta: '/api/documentacion/estadisticas',
        descripcion: 'Obtener estadísticas de los bancos',
        parametros: 'Ninguno',
      }
    end

    # Construye los datos de estadísticas
    def build_stats_data
      {
        total_bancos: Banco.count,
      }
    end
  end
end
