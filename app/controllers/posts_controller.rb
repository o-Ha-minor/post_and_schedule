class PostsController < ApplicationController
    def index
        @posts = Post.order(created_at: :desc)
        @post = Post.find_by(id: params[:id])
        if @current_user
            @like = Like.where(user_id: @current_user.id).pluck(:post_id)
        end
    end
    def new
        @post = Post.new
    end
    def create
        if @current_user
            @post = @current_user.posts.build(post_params)
            if @post.save
                flash[:notice] = "Post has created(投稿できました)"
                redirect_to(@post)
            else
                render("posts/index")
            end
        else
            redirect_to("/login")
        end
    end
    def show
        @post = Post.find_by(id: params[:id])
        if @post.nil?
          flash[:alert] = "投稿が見つかりませんでした"
          redirect_to posts_path and return
        end
        @like = Like.where(user_id: @current_user.id).pluck(:post_id)
        @user = User.find_by(id: @post.user_id)
        @comment = Comment.new
    end

    def destroy
        @post = Post.find_by(id: params[:id])
        if @post != nil
            @post.destroy
            flash[:notice] = "deleted（削除しました）"
        else
            flash[:alert] = "not found(対象が見つかりません)"
        end
        redirect_to root_path
    end

    def edit
        @post = Post.find(params[:id])
    end

    def update
        @post = Post.find_by(id: params[:id])
        if @post.update(post_params)
           flash[:notice] = "success(編集しました)"
           render("home/top")
        else
           flash[:alert] = "faild(失敗しました)"
           render "posts/edit"
        end
    end

    def post_params
        params.require(:post).permit(:content, :image)
    end

before_action :authorize_post, only: [ :edit, :update, :destroy ]

    private
        def authorize_post
        @post = Post.find(params[:id])
        redirect_to posts_path, alert: "権限が不足しています" if @post.user != @current_user
        end
end
