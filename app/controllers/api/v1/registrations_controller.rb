class Api::V1::RegistrationsController < ApplicationController

  # メールアドレス認証用のメールを生成し送信
  def create
    # メールアドレスが既に使われていないか検証
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

      if Rails.env.production?
        tmp = ENV['SERVICE_KEY_F'] + ENV['SERVICE_KEY_L']
        str = tmp.gsub(/\\n/, "\n")
        rsa_private = OpenSSL::PKey::RSA.new(str);
      elsif  Rails.env.development?
        rsa_private = OpenSSL::PKey::RSA.new(File.read(Rails.root.join('auth/service.key')))
      end
      
      token = JWT.encode(payload, rsa_private, "RS256")

      # JWTを末尾につけたURLを生成
      url = ENV["EMAIL_AUTH_URL"] + "/" + token if token

      # urlを記載したメールをフォームからpostされたメールアドレスに送信
      UserMailer.send_auth_email(params[:name], params[:email], url).deliver_now

      render json: { status: 200, message: "success" }
    else
      render json: { status: 401, message: "already" }
    end
  end
end
