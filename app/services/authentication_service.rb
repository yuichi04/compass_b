class AuthenticationService

    # メールアドレスとパスワードによるユーザー取得
    def self.authenticate_user_with_password(email, password)
        begin
            user = User.find_by(email:email)&.authenticate(password)
        rescue
            render json: { status: 401, message: "unauthorized" }
        end
        user
    end

    # JWTによるユーザー取得
    def self.authenticate_user_with_token(token)
        # 秘密鍵の取得
        rsa_private = OpenSSL::PKey::RSA.new(File.read(Rails.root.join('auth/service.key')))

        # JWTをデコードする。ペイロードを取得できない場合は認証エラーにする
        begin
            decoded_token = JWT.decode(token, rsa_private, true, { algorithm: "RS256" })
        rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError
            return render json: { status: 401, message: "unauthorized" }
        end

        # ユーザー検索
        user_id = decoded_token.first["sub"]
        user = User.find(user_id)
        render json: { status: 401, message: "unauthorized" } if user.nil?
        user
    end
end