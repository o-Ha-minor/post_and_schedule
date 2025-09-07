class PostsController < ApplicationController
    before_action :authorize_post, only: [ :edit, :update, :destroy ]

    def index
        return redirect_to root_path, alert: "ログインしてください" unless @current_user

        @posts = Post.includes(:user, :group, comments: :user)
                     .where(group: @current_user.groups)
                     .order(created_at: :desc)
        @like = Like.where(user_id: @current_user.id).pluck(:post_id)

        # JSON用に必要なデータだけ整形
        @posts_data = @posts.map do |post|
          {
            id: post.id,
            content: post.content,
            created_at: post.created_at,
            likes_count: post.likes_count,
            image_url: post.image_url,
            user: {
              id: post.user.id,
              name: post.user.name,
              image_url: post.user.respond_to?(:image_url) ? post.user.image_url : nil
            },
            group: post.group ? { id: post.group.id, name: post.group.name } : nil,
            comments: post.comments.map do |comment|
              {
                id: comment.id,
                content: comment.content,
                created_at: comment.created_at,
                likes_count: comment.likes_count,
                image_url: comment.respond_to?(:image_url) ? comment.image_url : nil,
                user: {
                  id: comment.user.id,
                  name: comment.user.name,
                  image_url: comment.user.respond_to?(:image_url) ? comment.user.image_url : nil
                }
              }
            end
          }
        end
    end
    def new
    @post = Post.new
    @groups = @current_user.groups
    end

    def create
      return redirect_to login_path unless @current_user

      @post = @current_user.posts.build(post_params)
      @post.group ||= @current_user.groups.first

      if @post.save
        ai_comment = AiCommentGenerator.generate_comment(@post.content)
        @post.update(sentiment: ai_comment[:label], sentiment_score: ai_comment[:score], ai_comment: ai_comment[:comment])

        respond_to do |format|
          format.html { redirect_to post_path(@post), notice: "投稿しました" }
          format.json {
            render json: {
              id: @post.id,
              content: @post.content,
              created_at: @post.created_at,
              likes_count: @post.likes.count,
              image_url: (@post.image.attached? ? rails_blob_path(@post.image, only_path: true) : nil),
              user: { id: @post.user.id, name: @post.user.name },
              group: (@post.group ? { id: @post.group.id, name: @post.group.name } : nil),
              comments: []
            }, status: :created
          }
        end
      else
          respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity }
          end
      end
    end

    def show
      @post = Post.includes(:user, :group, comments: :user).find(params[:id])

      respond_to do |format|
        format.html
        format.json do
          current_like = @current_user ? @post.likes.find_by(user_id: @current_user.id) : nil

          render json: {
            id: @post.id,
            content: @post.content,
            updated_at: @post.updated_at,
            likes_count: @post.likes.count,
            liked: current_like.present?,
            like_id: current_like&.id,
            image_url: (@post.image.attached? ? rails_blob_path(@post.image, only_path: true) : nil),
            user: { id: @post.user.id, name: @post.user.name },
            group: (@post.group ? { id: @post.group.id, name: @post.group.name } : nil),
            comments: @post.comments.order(created_at: :desc).map { |c|
              {
                id: c.id,
                content: c.content,
                created_at: c.created_at,
                likes_count: c.likes.count,
                user: { id: c.user.id, name: c.user.name }
              }
            }
          }
        end
      end
    end


    def destroy
      @post = Post.find_by(id: params[:id])
      if @post
          @post.destroy
          respond_to do |format|
            format.json { render json: { message: "削除しました", id: @post.id }, status: :ok }
          end
      else
        respond_to do |format|
          format.html { redirect_to root_path, alert: "対象が見つかりません" }
          format.json { render json: { error: "対象が見つかりません" }, status: :not_found }
        end
      end
    end

    def edit
    @post = Post.find(params[:id])
    end

    def update
    @post = Post.find_by(id: params[:id])
    if @post.update(post_params)
        flash[:notice] = "編集しました"
        redirect_to post_path(@post)
    else
        flash[:alert] = "編集に失敗しました"
        render "posts/edit"
    end
    end

    private

    def post_params
    params.require(:post).permit(:content, :image, :group_id)
    end

    def authorize_post
    @post = Post.find(params[:id])
    redirect_to posts_path, alert: "権限が不足しています" if @post.user != @current_user
    end
end
