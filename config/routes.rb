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
      resource :sessions, only: [:create, :show, :destroy]
      post "/registrations", to: "registrations#create"
      post "/inquiry", to: "inquiry#create"
      # 通信テスト用
      resources :test, only: %i[index]
    end
  end
end