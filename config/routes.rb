Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # ============================================================================
  # API ROUTES - Bancos API
  # ============================================================================
  #
  # Esta sección define todas las rutas de la API REST para la gestión de bancos.
  # La API está organizada bajo el namespace /api para separarla de otras
  # funcionalidades de la aplicación.
  namespace :api do
    # ============================================================================
    # RECURSOS DE BANCOS
    # ============================================================================
    #
    # Rutas para las operaciones CRUD de bancos:
    # - POST /api/bancos - Crear un nuevo banco
    # - GET /api/bancos/:id - Obtener un banco específico por ID
    #
    # Nota: Solo se exponen las operaciones de creación y lectura por ID
    # según los requerimientos del desafío.
    resources :bancos, only: [:create, :show] do
      collection do
        # GET /api/bancos/cercano - Encontrar el banco más cercano a un punto
        #
        # Esta ruta especial permite buscar el banco más cercano a coordenadas
        # geográficas específicas. Es la funcionalidad principal del desafío.
        #
        # Parámetros de query:
        # - latitud: Coordenada de latitud (-90 a 90)
        # - longitud: Coordenada de longitud (-180 a 180)
        # - limite_km: Límite de distancia en kilómetros (opcional, default: 10.0)
        #
        # Ejemplo: GET /api/bancos/cercano?latitud=4.7110&longitud=-74.0721&limite_km=5.0
        get :cercano
      end
    end

    # ============================================================================
    # DOCUMENTACIÓN DE LA API
    # ============================================================================
    #
    # Rutas para la documentación y metadatos de la API:
    # - GET /api/documentacion - Documentación completa de la API
    # - GET /api/documentacion/estadisticas - Estadísticas de los bancos
    #
    # Estas rutas proporcionan información sobre cómo usar la API y
    # métricas sobre los datos almacenados.

    # GET /api/documentacion - Documentación completa de la API
    #
    # Retorna información detallada sobre todos los endpoints disponibles,
    # incluyendo parámetros, ejemplos de uso y códigos de respuesta.
    get 'documentacion', to: 'documentacion#index'

    # GET /api/documentacion/estadisticas - Estadísticas de los bancos
    #
    # Retorna métricas sobre los bancos almacenados en la base de datos,
    # como total de bancos, promedio de evaluación, etc.
    get 'documentacion/estadisticas', to: 'documentacion#estadisticas'
  end

  # ============================================================================
  # RUTAS FUTURAS
  # ============================================================================
  #
  # Aquí se pueden agregar rutas para otras funcionalidades de la aplicación
  # que no estén relacionadas con la API de bancos.

  # Defines the root path route ("/")
  # root "posts#index"
end
