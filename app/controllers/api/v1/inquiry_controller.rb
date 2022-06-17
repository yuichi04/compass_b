class Api::V1::InquiryController < ApplicationController

    # フォームから送られてきた内容を管理者にメール送信する処理
    def create
        # InquiryMailer.send_inquiry_email(inquiry_params).deliver_now # DB登録する場合の処理
        user = User.find_by(email: params[:email])
        if user
            InquiryMailer.send_inquiry_email(user.name, params[:email], params[:category], params[:content]).deliver_now
            render json: { status: 200, message: "success" }
        else
            InquiryMailer.send_inquiry_email("未ログインのユーザー", params[:email], params[:category], params[:content]).deliver_now
            render json: { status: 200, message: "success" }
        end
    end

    # private
    #     def inquiry_params
    #         params.require(:inquiry).permit(:email, :category, :content)
    #     end
end
