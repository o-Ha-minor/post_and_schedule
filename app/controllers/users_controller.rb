class UsersController < ApplicationController
    def index
        
        @users = User.all.order(created_at: :desc)
    end
    def new
    end
    def create
        @user = User.new(
            name: params[:name],
            password: params[:password],
            email: params[:email],
            image_name: "default_image.png"
            )
        if    @user.save
            flash[:notice] = "You got account!(登録できました)"
            session[:user_id] = @user.id
            redirect_to("/users/index")
        else
            flash[:alert] = @user.errors.full_messages
            render("users/new")
        end
    end
    def show
        @user = User.find_by(id: params[:id])
            if params[:id] == 'sign_in'
              redirect_to login_path  # ログインページへリダイレクト
            else
              @user = User.find_by(id: params[:id])  # 他のユーザー情報を取得
            end
          
    end

    def edit
        @user = User.find(params[:id])
    end

    def update
        Rails.logger.debug "==== DEBUG: params ===="
        Rails.logger.debug params.inspect
        Rails.logger.debug "======================="
        @user = User.find_by(id: params[:id])
        if @user.update(user_params)
            if params[:image].present?
            @user.image.attach(params[:image])
            end
           flash[:notice] = "success(編集しました)"
           render("home/top")
        else
           flash[:alert] = "faild(失敗しました)"
           render("posts/:id/edit")
        end
    end

    def user_params
        params.require(:user).permit(:name,:image,:email)
    end

    def login_form
        
    end
    def login
        @user = User.find_by(name: params[:name])
        if @user&.authenticate(params[:password])
            session[:user_id] = @user.id
            flash[:notice] = "ログインしました"
            render("home/top")
        else
            flash[:alert] = "失敗しました"
            render("users/login_form")
        end
        
    end

    def logout
        session[:user_id] = nil
        flash[:notice] = "ログアウトしました"
        render("home/top")
    end
    def destroy
        @user = User.find_by(id: params[:id])
        if @user != nil
            @user.destroy
            flash[:notice] = "deleted（削除しました）"
            render("home/top")
        else
            flash[:alert] = "not found(対象が見つかりません)"
            render("home/top")
        end
    end

end

private
