class TokenService
    def self.issue_by_password(email, password)
        user = AuthenticationService.authenticate_user_with_password(email, password)
        issue_token(user.id)
    end

    def self.issue_token(id)
        payload = {
            iss: "compass",
            sub: id,
            exp: (DateTime.current + 14.days).to_i
        }
        rsa_private = OpenSSL::PKey::RSA.new(File.read(Rails.root.join('auth/service.key')))
        JWT.encode(payload, rsa_private, "RS256")
    end
end