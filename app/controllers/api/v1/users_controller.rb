class Api::V1::UsersController < ApplicationController

    # パラメーターにuserキーをつける
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
        
        # トークンをデコードする。ペイロードを取得できない場合は認証エラーにする
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
        user = User.new(name: name, email: email, password: password, password_confirmation: password_confirmation)

        if user.save
             # ログイン用のJWTを発行し、cookiesにセット
            jwt = TokenService.issue_by_password(user.email, user.password)
            cookies[:token] = { value: jwt, httponly: true }
            
            UserMailer.welcome_email(user.name, user.email).deliver_now
            res_data = { name: user.name, email: user.email, created_at: user.created_at }
            render json: { status: 200, message: "success", user: res_data }
        else
            render json: { status: 401, message: "unauthorized" }
        end
    end

    # ユーザーネームの変更
    def update_username
        token = cookies[:token]
        user = AuthenticationService.authenticate_user_with_token(token) if token

        if user.update(update_name_params)
            render json: { status: 200, message: "success" }
        else
            render json: { status: 401, message: "unauthorized" }
        end
    end

    # メールアドレス変更用の認証メールを送信する
    def send_auth_email_for_update
        token = cookies[:token]
        user = AuthenticationService.authenticate_user_with_token(token) if token
        if user
            # 既に使用されているメールアドレスか確認
            email = User.find_by(email: params[:email])
            if email.nil?
                # tokenに渡す中身を作成
                payload = {
                    iss: "compass",
                    current_email: user.email,
                    email: params[:email],
                    exp: ( Time.now + 30.minutes ).to_i
                }

                # 秘密鍵を生成
                if Rails.env.production?
                    tmp = ENV['SERVICE_KEY_F'] + ENV['SERVICE_KEY_L']
                    str = tmp.gsub(/\\n/, "\n")
                    rsa_private = OpenSSL::PKey::RSA.new(str);
                elsif  Rails.env.development?
                    rsa_private = OpenSSL::PKey::RSA.new(File.read(Rails.root.join('auth/service.key')))
                end

                jwt = JWT.encode(payload, rsa_private, "RS256")

                # JWTを末尾につけたURLを生成
                url = ENV["UPDATE_EMAIL_AUTH_URL"] + "/" + jwt if jwt

                # urlを記載したメールをログイン中ユーザーのメールアドレスに送信
                UserMailer.send_update_email_auth_email(params[:email], url).deliver_now

                render json: { status: 200, message: "success" }
            else
                render json: { status: 401, message: "already" }
            end
        else
            render json: { status: 401, message: "unauthorized" }
        end
    end

    # メールアドレスの変更
    def update_email
        # トークンを取得
        token = params[:token]
        render json: { status: 401, message: "unauthorized" } if token.nil?

        # 秘密鍵の取得
        if Rails.env.production?
            # 分割していたキーを1つにまとめる
            tmp = ENV['SERVICE_KEY_F'] + ENV['SERVICE_KEY_L']
            str = tmp.gsub(/\\n/, "\n")
            rsa_private = OpenSSL::PKey::RSA.new(str);
        elsif Rails.env.development?
            rsa_private = OpenSSL::PKey::RSA.new(File.read(Rails.root.join('auth/service.key')))
        end

        # トークンをデコード
        begin
            decoded_token = JWT.decode(token, rsa_private, true, { algorithm: "RS256" })
        rescue JWT::DecodeError, JWT::ExpiredSignatrue, JWT::VerificationError
            return render json: { status: 401, message: "unauthorized" }
        end

        
        # ユーザーが存在するか確認
        current_email = decoded_token.first["current_email"]
        user = User.find_by(email: current_email)

        # 更新後のメールアドレス
        email = decoded_token.first["email"]

        # メールアドレスを変更
        if user.update(email: email)
            render json: { status: 200, message: "success" }
        else
            render json: { status: 401, message: user }
        end
    end

    # パスワードの変更
    def update_password
        token = cookies[:token]
        user = AuthenticationService.authenticate_user_with_token(token) if token 
        
        if user.update(update_password_params)
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
            cookies.delete(:token) # cookieを削除
            render json: { status: 200, message: "success" }
        else
            render json: { status: 401, message: "unauthorized" }
        end
    end

    private
        def update_name_params
            params.require(:user).permit(:name)
        end

        def update_email_params
            params.require(:user).permit(:email)
        end

        def update_password_params
            params.require(:user).permit(:password)
        end

end