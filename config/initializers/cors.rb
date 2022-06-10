Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://d9hacbgtyu7lr.cloudfront.net/" # React側はポート番号3000で作るので「localhost:3000」を指定

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end