class UsersController < ApplicationController
    def index
        # モデルのスコープを使用してN+1問題を解決
        @users = User.with_profile_data.order(created_at: :desc)

        respond_to do |format|
          format.html
          format.json do
            render json: @users.map(&:profile_data_for_json)
          end
        end
    end

      def show
        # 効率的にデータをロード
        @user = User.with_profile_data.find(params[:id])

        respond_to do |format|
          format.html
          format.json do
            render json: @user.profile_data_for_json
          end
        end
      end

      def update
        @user = User.find_by(id: params[:id])

        if @user != @current_user
          respond_to do |format|
            format.html {
              flash[:alert] = "アクセス権限がありません"
              redirect_to user_path(@user)
            }
            format.json { render json: { error: "アクセス権限がありません" }, status: :forbidden }
          end
          return
        end

        if @user.update(user_params)
          # 更新後に最新データをロード
          @user = User.with_profile_data.find(@user.id)

          respond_to do |format|
            format.html {
              flash[:notice] = "編集しました"
              redirect_to user_path(@user)
            }
            format.json {
              render json: @user.profile_data_for_json
            }
          end
        else
          respond_to do |format|
            format.html {
              flash[:alert] = "失敗しました"
              render :edit
            }
            format.json { render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity }
          end
        end
      end


    # 既存のメソッドは維持...
    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.save
        flash[:notice] = "登録完了"
        session[:user_id] = @user.id
        redirect_to users_path
      else
        flash[:alert] = @user.errors.full_messages
        render("users/new")
      end
    end

    def edit
      @user = User.find(params[:id])
    end

    def login_form
    end

    def login
      @user = User.find_by(name: params[:name])
      if @user&.authenticate(params[:password])
        session[:user_id] = @user.id
        flash[:notice] = "ログインしました"
        redirect_to("/")
      else
        flash[:alert] = "失敗しました"
        render("users/login_form")
      end
    end

    def logout
      session[:user_id] = nil
      flash[:notice] = "ログアウトしました"
      redirect_to root_path
    end

    def destroy
      @user = User.find_by(id: params[:id])
      if @user != nil
        @user.destroy
        flash[:notice] = "削除しました"
        render("home/top")
      else
        flash[:alert] = "対象が見つかりません"
        render("home/top")
      end
    end

    private

    def user_params
      params.require(:user).permit(:name, :password, :email, :image)
    end
end
