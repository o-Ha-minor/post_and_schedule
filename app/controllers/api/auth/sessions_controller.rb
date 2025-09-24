# app/controllers/api/auth_controller.rb
module Api
  module Auth
    # 共通の認証ロジックをここに追加できます
    class SessionsController < ApplicationController
      before_action :set_current_user, except: [ :login, :register ]
      skip_before_action :set_current_user
      before_action :require_login, only: [ :check ]

      # 認証状態確認
      def check
        if logged_in?
          render json: {
            success: true,
            user: {
              id: current_user.id,
              name: current_user.name,
              email: current_user.email,
              image_url: current_user.image.attached? ? url_for(current_user.image) : nil
            },
            groups: current_user.groups.map { |g| { id: g.id, name: g.name } }
          }
        else
          render json: { success: false }, status: :unauthorized
        end
      end

      # ログイン
      def login
        user = User.find_by(name: params[:name])

        unless user&.authenticate(params[:password])
          render_api_response(
            message: "ユーザが見つかりません", success: false, status: :unauthorized)
            return
        end
        unless user.authenticate(params[:password])
          render_api_response(
            message: "passwordが違います", success: false, status: :unauthorized)
            return
        end
        session[:user_id] = user.id
      end

      # ユーザー登録
      def register
        user = User.new(user_params)

        if user.save
          session[:user_id] = user.id
          ensure_default_group(user)

          render_api_response(
            message: "アカウントを作成しました",
            data: {
              user: user_data(user),
              groups: user.groups.map { |g| group_data(g) }
            }
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

      # ログアウト
      def logout
        session[:user_id] = nil
        render_api_response(message: "ログアウトしました")
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :image)
      end

      def user_data(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          image_url: user.image.attached? ? rails_blob_path(user.image, only_path: true) : nil,
          created_at: user.created_at
        }
      end

      def group_data(group)
        {
          id: group.id,
          name: group.name,
          description: group.description,
          members_count: group.users.count
        }
      end
    end
  end
end
