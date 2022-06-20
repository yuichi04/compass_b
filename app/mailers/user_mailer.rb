class UserMailer < ApplicationMailer
    default from: ENV["MAILER_EMAIL"], subject: "ようこそCOMPASSへ"
  
    def send_auth_email(name, email, url)
        @name = name
        @email = email
        @url = url
        mail to: email, subject: "COMPASS | 認証コードの確認"
    end

    def welcome_email(name, email)
        @name=name
        mail to: email
    end

    def send_update_email_auth_email(email, url)
        @url = url
        @email = email
        mail to: email, subject: "COMPASS | メールアドレス変更の確認"
    end
end
