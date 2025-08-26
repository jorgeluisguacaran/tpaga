# frozen_string_literal: true

class ApplicationController < ActionController::API
  # Manejo de errores de parsing JSON
  rescue_from ActionDispatch::Http::Parameters::ParseError do |exception|
    render json: {
      success: false,
      error: 'JSON malformado',
      details: 'El cuerpo de la petición contiene JSON inválido. Verifique la sintaxis.',
      message: exception.message,
    }, status: :bad_request
  end

  # Manejo de errores de parámetros faltantes
  rescue_from ActionController::ParameterMissing do |exception|
    render json: {
      success: false,
      error: 'Parámetros faltantes',
      details: "El parámetro '#{exception.param}' es requerido",
      message: exception.message,
    }, status: :bad_request
  end

  # Manejo de errores de validación de ActiveRecord
  rescue_from ActiveRecord::RecordInvalid do |exception|
    render json: {
      success: false,
      error: 'Error de validación',
      details: exception.record.errors.full_messages,
      message: exception.message,
    }, status: :unprocessable_entity
  end

  # Manejo de errores de registro no encontrado
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {
      success: false,
      error: 'Recurso no encontrado',
      details: 'El recurso solicitado no existe en la base de datos',
      message: exception.message,
    }, status: :not_found
  end
end
