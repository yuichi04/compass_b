class Api::V1::InquiryController < ApplicationController

    # フォームから送られてきた内容を管理者にメール送信する処理
    def create
        user = User.find_by(email: params[:email])
        if user
            InquiryMailer.send_inquiry_email(user.name, params[:email], params[:category], params[:content]).deliver_now
            render json: { status: 200, message: "success" }
        else
            InquiryMailer.send_inquiry_email("未ログインのユーザー", params[:email], params[:category], params[:content]).deliver_now
            render json: { status: 200, message: "success" }
        end
    end
end
