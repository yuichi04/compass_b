class Api::V1::AnswersController < ApplicationController

    # 解答の保存
    def create
        # ログイン中のユーザーか確認
        token = cookies[:token]
        # ログインしていなければ処理を中止
        render json: { status: 401, message: "unauthorized" } if token.nil?

        # ログイン中のユーザーを取得
        user = AuthenticationService.authenticate_user_with_token(token)
        
        # paramsからデータベースに保存するデータを作成
        uid = params[:uid]
        course = params[:course]
        consultation = params[:consultation]
        conclusion = params[:conclusion]
        common = params[:common]
        info = params[:info]
        
        answer = Answer.new(uid: uid, course: course, consultation: consultation, conclusion: conclusion, common: common, info: info)

        # 保存したデータをクライアントに送信
        if answer.save
            render json: { status: 200, message: "success", data: answer }
        else
            render json: { status: 500, message: "failed save answer" }
        end
    end

    # ユーザーの解答一覧の返却
    def show
        # ログイン中のユーザーか確認
        token = cookies[:token]
        # ログインしていなければ処理を中止
        render json: { status: 401, message: "unauthorized" } if token.nil?

        # ログイン中のユーザーを取得
        user = AuthenticationService.authenticate_user_with_token(token)
        # ログイン中ならユーザーidと紐づく解答一覧を取得
        if user
            answer_list = Answer.where(uid: user.id)
            render json: { status: 200, message: "success", data: answer_list }
        else
            render json: { status: 500, message: "failed save answer" }
        end
    end

    # 解答の削除
    def destroy
    end
end
