Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # origins "https://d26naxoetp9qtj.cloudfront.net/"
    origins ENV['CLIENT_URL']

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end