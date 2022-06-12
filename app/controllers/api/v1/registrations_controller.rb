class Api::V1::RegistrationsController < ApplicationController

  # ユーザー登録の準備
  def create
    # 既に登録されているメールアドレスならエラーを返す
      user = User.find_by(email: params[:email])
      
    if user.nil?
      # メールアドレス認証用のJWTの生成
      payload = {
          iss: "compass",
          name: params[:name],
          email: params[:email],
          password: params[:password],
          password_confirmation: params[:password_confirmation],
          exp: ( Time.now + 30.minutes ).to_i
      }
      rsa_private = OpenSSL::PKey::RSA.new(File.read(Rails.root.join('auth/service.key')))
      token = JWT.encode(payload, rsa_private, "RS256")

      # JWTを末尾につけたURLを生成
      url = ENV["EMAIL_AUTH_URL"] + "/" + token if token
      
      # urlを記載したメールをフォームからpostされたメールアドレスに送信
      UserMailer.send_auth_email(params[:name], params[:email], url).deliver_now

      render json: { status: 200, message: "success" }
    else
       render json: { status: 401 }
    end
  end
end
