class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :set_current_user

  protected
  def render_api_response(message: nil, data: {}, success: true, errors: [], status: :ok)
   response_data = {
     success: success,
     message: message
   }

  response_data[:data] = data unless data.empty?
  response_data[:errors] = errors unless errors.empty?

  render json: response_data, status: status
  end

  def logged_in?
    current_user.present?
  end

  def current_user
    return unless session[:user_id]
    user = User.find_by(id: session[:user_id])
    unless user
      session[:user_id] = nil
      return nil
    end
    @current_user ||= user
  end

  # デフォルトグループの割り当て
  def set_current_user
    @current_user = current_user
  end

  def require_login
      unless logged_in?
        if request.format.json?
          render_api_response(
            message: "ログインが必要です",
            success: false,
            status: :unauthorized
           )
        else
          redirect_to login_path, alert: "ログインが必要です"
        end
      end
  end

  private

  def ensure_default_group(user)
    return unless user
    default_name = "#{user.name}のグループ"
    default_group = Group.find_or_create_by(name: default_name) do |g|
      g.description = "自動作成グループ"
    end
    user.groups << default_group unless user.groups.exists?(default_group.id)
  end
end
