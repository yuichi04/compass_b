class InquiryMailer < ApplicationMailer

    def send_inquiry_email(name, email, category, content)
        @name = name
        @email = email
        @category = category
        @content = content
        mail to: ENV["MAILER_EMAIL"], subject: "COMPASS | お問い合わせがありました"
    end
end
