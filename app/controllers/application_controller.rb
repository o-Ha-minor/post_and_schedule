class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :set_current_user

  # デフォルトグループの割り当て
  def set_current_user
    @current_user = User.find_by(id: session[:user_id])
    ensure_default_group(@current_user) if @current_user
  end

  def ensure_default_group(user)
    return if user.groups.exists?

    default_group = Group.create(name: "#{user.name}のグループ", description: "自動作成グループ")
    user.groups << default_group
  end
end
