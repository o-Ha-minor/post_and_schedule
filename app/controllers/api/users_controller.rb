# app/controllers/api/users_controller.rb
class Api::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def update_ai_images
    ai_images_name = params[:avatar_name].to_s
    ai_images_dir = Rails.root.join("public", "ai_images")
    if ai_images_name.blank? || !File.exist?(ai_images_dir.join(ai_images_name))
      return render_api_response(message: "アバターが見つかりません", success: false, status: :unprocessable_entity)
    end

    if current_user.update(ai_character: avatar_name)
      render_api_response(message: "アバターを更新しました", data: { avatar_url: "/ai_images/#{ai_images_name}" })
    else
      render_api_response(message: "アバターの更新に失敗しました", success: false, errors: current_user.errors.full_messages, status: :unprocessable_entity)
    end
  end

  # 感情分析の結果を受け取り、ai_expression を更新する
  def update_ai_expression
    expression = params[:expression].to_i

    # 感情分析の結果を保存
    if current_user.update(ai_expression: expression)
      render_api_response(message: "感情分析結果を更新しました", data: { expression: expression })
    else
      render_api_response(message: "感情分析結果の更新に失敗しました", success: false, errors: current_user.errors.full_messages, status: :unprocessable_entity)
    end
  end




  def index
    users = User.with_profile_data.order(created_at: :desc)
    render json: { success: true, data: users.map(&:profile_data_for_json) }
  end

  def show
    user = User.with_profile_data.find(params[:id])
    render json: { success: true, data: user.profile_data_for_json }
  end

  def create
    user = User.new(user_params)
    if user.save
      # JWT などのトークンを返すならここ
      session[:user_id] = user.id
      render_api_response(
        message: "登録完了",
        data: { user: user.profile_data_for_json },
        status: :created
      )
    else
      render_api_response(
      message: "登録に失敗しました",
      success: false,
      errors: user.errors.full_messages,
      status: :unprocessable_entity
    )
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
