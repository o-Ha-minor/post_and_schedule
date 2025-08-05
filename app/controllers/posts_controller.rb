class PostsController < ApplicationController
    def index
        if @current_user
            @posts = Post.where(group: @current_user.groups).order(created_at: :desc)
            @post = Post.find_by(id: params[:id])
            @like = Like.where(user_id: @current_user.id).pluck(:post_id)
        else
            redirect_to root_path, alert: "ログインしてください"
        end
    end
    def new
        @post = Post.new
        @groups = @current_user.groups
    end
    def create
        if @current_user
            @post = @current_user.posts.build(post_params)
            @post.group ||= @current_user.groups.first
            if @post.save
                Rails.logger.info("DEBUG: Post content = #{@post.content.inspect}")
                sentiment_result = EmotionAnalyzer.analyze(@post.content)
                ai_comment = AiCommentGenerator.generate_comment(
                    @post.content,
                    sentiment_result[:label],
                    sentiment_result[:score])

                @post.update(
                    sentiment: sentiment_result[:label],
                    sentiment_score: sentiment_result[:score],
                    ai_comment: ai_comment
                )
                redirect_to post_path(@post), notice: "投稿しました"
            else
                render :new
            end
        else
            redirect_to login_path
        end
    end
    def show
        @post = Post.find_by(id: params[:id])
        unless @post
          redirect_to posts_path
        end
        @like = []
        if @current_user
          @like = Like.where(user_id: @current_user.id).pluck(:post_id)
          @user = User.find_by(id: @post.user_id)
        end
        @comment = Comment.new
    end

    def destroy
        @post = Post.find_by(id: params[:id])
        if @post != nil
            @post.destroy
            flash[:notice] = "削除しました"
        else
            flash[:alert] = "対象が見つかりません"
        end
        redirect_to root_path
    end

    def edit
        @post = Post.find(params[:id])
    end

    def update
        @post = Post.find_by(id: params[:id])
        if @post.update(post_params)
           flash[:notice] = "編集しました"
           render("home/top")
        else
           flash[:alert] = "失敗しました"
           render "posts/edit"
        end
    end

    def post_params
        params.require(:post).permit(:content, :image, :group_id)
    end

before_action :authorize_post, only: [ :edit, :update, :destroy ]

    private
        def authorize_post
        @post = Post.find(params[:id])
        redirect_to posts_path, alert: "権限が不足しています" if @post.user != @current_user
        end
end
