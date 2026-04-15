# app/controllers/api/users_controller.rb
class Api::UsersController < ApplicationController
  before_action :set_user, only: [ :show, :update, :destroy ]
  before_action :ensure_current_user!, only: [ :update, :destroy ]

  def update_ai_images
    raw = params[:avatar_name].to_s
    return render_api_response(message: "パラメータが空です", success: false, status: :unprocessable_entity) if raw.blank?

    # ファイル名からベース部分だけ取り出し
    base = File.basename(raw).sub(/\.(png|jpe?g|gif)\z/i, "")
    char = base.split("_").first

    # 強制的に neutral に統一
    filename = "#{char}_neutral.png"
    ai_images_dir = Rails.root.join("public", "ai_images")

    unless File.exist?(ai_images_dir.join(filename))
      return render_api_response(
        message: "アバターが見つかりません (#{filename})",
        success: false,
        status: :unprocessable_entity
      )
    end

    # バリデーション無視してDB更新
    current_user.update_columns(ai_character: char, ai_expression: "neutral")

    render_api_response(
      message: "アバターを更新しました",
      data: {
        ai_character: char,
        ai_expression: "neutral",
        avatar_url: "/ai_images/#{filename}"
      }
    )
  end
  # 感情分析の結果を受け取り、ai_expression を更新する
  def update_ai_expression
    expression = params[:expression]
    valid_expressions = %w[positive neutral negative]

    unless valid_expressions.include?(expression)
      return render_api_response(message: "感情値が不正です", success: false, status: :unprocessable_entity)
    end
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
    render json: { success: true, data: @user.profile_data_for_json }
  end

  def create
    user = User.new(user_params)
    if user.save
      session[:user_id] = user.id
      render_api_response(
        message: "登録完了",
        success: true,
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
    if @user.update(user_params)
      render json: { success: true, data: @user.profile_data_for_json }
    else
      render json: { success: false, errors: @user.errors.full_messages },
      status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      render json: { success: true, message: "削除しました", id: @user.id }, status: :ok
    else
      render json: { success: false, errors: @user.errors.full_messages },
      status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :image)
  end

  def set_user
    @user = User.with_profile_data.find(params[:id])
  end

  def ensure_current_user!
    unless @user == current_user
      render json: { error: "権限がありません" }, status: :forbidden
    end
  end
end
