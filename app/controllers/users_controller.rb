class UsersController < ApplicationController
    def index
        @users = User.all.order(created_at: :desc)
    end
    def new
        @user = User.new
    end
    def create
        @user = User.new(user_params)
        if  @user.save
            flash[:notice] = "登録完了"
            session[:user_id] = @user.id
            redirect_to users_path
        else
            flash[:alert] = @user.errors.full_messages
            render("users/new")
        end
    end

    def show
        @user = User.find_by(id: params[:id])
            if @user.nil?
                flash[:alert] = "ユーザが見つかりません"
              redirect_to users_path and return
            else
              @user = User.find_by(id: params[:id])
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
            if params[:user][:image].present?
            @user.image.attach(params[:user][:image])
            end
           flash[:notice] = "編集しました"
           render("home/top")
        else
           flash[:alert] = "失敗しました"
           render("posts/:id/edit")
        end
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
        render("home/top")
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
end

private

def user_params
    params.require(:user).permit(:name, :password, :email, :image)
end
