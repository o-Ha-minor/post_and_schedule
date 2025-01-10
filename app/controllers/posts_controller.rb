class PostsController < ApplicationController
    def index
        @posts = Post.order(created_at: :desc)  # 作成日が新しい順に並ぶ
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
        @like = Like.where(user_id: @current_user.id).pluck(:post_id)
        @user = User.find_by(id: @post.user_id)
        @comment = Comment.new
        if @post == nil
            flash[:alert] = "Post not found（投稿が見つかりませんでした）"
            redirect_to()
        end
    end

    def destroy
        @post = Post.find_by(id: params[:id])
        if @post != nil
            @post.destroy
            flash[:notice] = "deleted（削除しました）"
            render("home/top")
        else
            flash[:alert] = "not found(対象が見つかりません)"
            render("home/top")
        end
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
           render("posts/:id/edit")
        end
    end
    def post_params
        params.require(:post).permit(:content, :avatar)
    end

before_action :authorize_post, only: [ :edit, :update, :destroy ]

private

def authorize_post
  @post = Post.find(params[:id])
  redirect_to posts_path, alert: "権限が不足しています" if @post.user != @current_user
end
end
