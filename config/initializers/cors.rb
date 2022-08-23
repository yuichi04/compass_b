Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    
    origins ENV['CLIENT_URL']

    resource '*',
        headers: :any,

        methods: [:get, :post, :put, :patch, :delete, :options, :head],

        credentials: true # リクエストにCookieの付与を許可
  end
end

# mysqlにはjsonデータを保存する