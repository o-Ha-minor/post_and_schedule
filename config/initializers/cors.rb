# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    allowed_origins = if Rails.env.production?
      [ "http://54.65.172.159" ]
    else
      [ "http://localhost:3000", "http://localhost:3036" ]
    end

    origins allowed_origins
    
    resource "/api/*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options ],
      credentials: true
  end
end
