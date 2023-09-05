Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://pdc-discovery-prod.princeton.edu'
    resource '*', headers: :any, methods: [:get, :post]
  end
end