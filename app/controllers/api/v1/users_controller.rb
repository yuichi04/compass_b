class Api::V1::UsersController < ApplicationController

    wrap_parameters :user, include: [:name, :email, :password, :password_confirmation]

    # ユーザー登録
    def create
        # トークンを取得
        token = params[:token]
        render json: { status: 401, message: "token is null" } if token.nil?

        # 秘密鍵の取得
        if Rails.env.production?
            tmp = ENV['SERVICE_KEY_F'] + ENV['SERVICE_KEY_L']
            str = tmp.gsub(/\\n/, "\n")
            rsa_private = OpenSSL::PKey::RSA.new(str);
        elsif Rails.env.development?
            rsa_private = OpenSSL::PKey::RSA.new(File.read(Rails.root.join('auth/service.key')))
        end
        
        # JWTをデコードする。ペイロードを取得できない場合は認証エラーにする
        begin
            decoded_token = JWT.decode(token, rsa_private, true, { algorithm: "RS256" })
        rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError
            return render json: { status: 401, message: "unauthorized" }
        end

        # ユーザー登録
        name = decoded_token.first["name"]
        email = decoded_token.first["email"]
        password = decoded_token.first["password"]
        password_confirmation = decoded_token.first["password_confirmation"]
        user = User.new(name: name, email: email, password: password, password_confirmation: password_confirmation);

        if user.save
             # ログイン用のJWTを発行し、cookiesにセット
            jwt = TokenService.issue_by_password(user.email, user.password)
            cookies[:token] = { value: jwt, httponly: true }
            
            UserMailer.welcome_email(user).deliver_now
            res_data = { name: user.name, email: user.email, created_at: user.created_at }
            render json: { status: 200, message: "success", user: res_data }
        else
            render json: { status: 401, message: "unauthorized" }
        end
    end

    # ユーザー情報の更新
    def update
        token = cookies[:token]
        user = AuthenticationService.authenticate_user_with_token(token) if token

        if user.update(update_params)
            render json: { status: 200, message: "success" }
        else
            render json: { status: 401, message: "unauthorized" }
        end
    end

    # アカウント削除
    def destroy
        token = cookies[:token]
        user = AuthenticationService.authenticate_user_with_token(token) if token
        if user.destroy
            cookies.delete(:token)
            render json: { status: 200, message: "success" }
        else
            render json: { status: 401, message: "unauthorized" }
        end
    end

    private
        def update_params
            params.require(:user).permit(:name, :email, :password)
        end
end