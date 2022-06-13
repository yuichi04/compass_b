class Api::V1::SessionsController < ApplicationController

  # ログイン
  def create
    user = AuthenticationService.authenticate_user_with_password(params[:email], params[:password])
    if user
      token = TokenService.issue_token(user.id)
      cookies[:token] = { value: token, httponly:true, domain: "compass-lo.link" }
      data = {name: user.name, email: user.email, created_at: user.created_at }
      render json: { status: 200, message: "success", user: data }
    else
      render json: { status: 401, message: "unauthorized" }
    end
  end

  def show
    token = cookies[:token]
    user = AuthenticationService.authenticate_user_with_token(token) if token
    if user
      data = {name: user.name, email: user.email, created_at: user.created_at }
      render json: { status: 200, message: "success", user: data}
    else
      render json: { status: 401, message: "unauthorized"}
    end
  end

  def destroy
    if cookies[:token]
      cookies.delete(:token)
      render json: { status: 200, message: "success" }
    else
      render json: { status: 401, message: "unauthorized" }
    end
  end
end
