class UserMailer < ApplicationMailer
    default from: ENV["MAILER_EMAIL"], subject: "ようこそCOMPASSへ"
  
    def send_auth_email(name, email, url)
        @name = name
        @email = email
        @url = url
        mail to: email, subject: "COMPASS | 認証コードの確認"
    end

    def welcome_email(user)
        @user=user
        mail to: user.email
    end
end
