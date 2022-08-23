Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resource :users, only: [:create, :destroy, :update] do
        collection do
          patch 'update_username'
          post 'send_auth_email_for_update'
          patch 'update_email'
          patch 'update_password'
        end
      end
      resource :answers, only: [:create, :show, :destroy]
      resource :sessions, only: [:create, :show, :destroy]
      post "/registrations", to: "registrations#create"
      post "/inquiry", to: "inquiry#create"
      # 通信テスト用
      resources :test, only: %i[index]
    end
  end
end


# model
# データベース作る

# controller
# def create
# json形式で保存する処理を作る
# def show
# データを返す処理を作る