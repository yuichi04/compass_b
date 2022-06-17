Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resource :users, only: [:create, :destroy, :update] do
          collection do
          patch 'update_password'
          patch 'update_username'
        end
      end
      resource :sessions, only: [:create, :show, :destroy]
      post "/registrations", to: "registrations#create"
      post "/inquiry", to: "inquiry#create"
      # 通信テスト用
      resources :test, only: %i[index]
    end
  end
end