# app/controllers/api/users_controller.rb
class Api::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token # API 用。トークン認証を導入するなら外してOK

  def index
    users = User.with_profile_data.order(created_at: :desc)
    render json: { success: true, data: users.map(&:profile_data_for_json) }
  end

  def show
    user = User.with_profile_data.find(params[:id])
    render json: user.profile_data_for_json
  end

  def create
    user = User.new(user_params)
    if user.save
      # JWT などのトークンを返すならここ
      render json: { message: "登録完了", user: user.profile_data_for_json }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    user = User.find(params[:id])
    if user.update(user_params)
      render json: user.profile_data_for_json
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    user = User.find_by(id: params[:id])
    if user
      user.destroy
      render json: { message: "削除しました", id: user.id }, status: :ok
    else
      render json: { error: "削除できませんでした" }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :image)
  end
end
