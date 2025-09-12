class PostsController < ApplicationController
  before_action :authorize_post, only: [ :edit, :update, :destroy ]

  def index
    return redirect_to root_path, alert: "ログインしてください" unless @current_user

    @posts = Post.includes(:user, :group, comments: :user)
                 .where(group: @current_user.groups)
                 .order(created_at: :desc)
    @like = Like.where(user_id: @current_user.id).pluck(:post_id)

    # 共通メソッドを使用してJSON用データを整形
    @posts_data = @posts.map { |post| post_json_data(post) }
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
        format.json { render json: post_json_data(@post), status: :created }
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
      format.json { render json: post_json_data(@post) }
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
      respond_to do |format|
        format.html { redirect_to @post, notice: "更新しました" }
        format.json { render json: post_json_data(@post) }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity }
      end
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

  # 投稿のJSON形式データを生成する共通メソッド
  def post_json_data(post)
    # いいね情報を取得
    current_like = @current_user ? post.likes.find_by(user_id: @current_user.id) : nil

    # コメントデータの生成（N+1問題を避けるため、既にincludesされていることを前提）
    comments_data = if post.comments.loaded?
      post.comments.order(created_at: :desc).map { |c| comment_json_data(c) }
    else
      post.comments.includes(:user).order(created_at: :desc).map { |c| comment_json_data(c) }
    end

    {
      id: post.id,
      content: post.content,
      created_at: post.created_at,
      updated_at: post.updated_at,
      likes_count: post.likes_count, # モデルメソッドを使用
      liked: current_like.present?,
      like_id: current_like&.id,
      image_url: post.image_url, # モデルメソッドを使用
      user: user_json_data(post.user),
      group: post.group ? group_json_data(post.group) : nil,
      comments: comments_data,
      ai_comment: post.ai_comment,
      sentiment: post.sentiment,
      sentiment_score: post.sentiment_score
    }
  end

  # ユーザーのJSON形式データを生成する共通メソッド
  def user_json_data(user)
    {
      id: user.id,
      name: user.name,
      image_url: user.respond_to?(:image_url) ? user.image_url :
                 (user.image.attached? ? rails_blob_path(user.image, only_path: true) : nil)
    }
  end

  # グループのJSON形式データを生成する共通メソッド
  def group_json_data(group)
    {
      id: group.id,
      name: group.name
    }
  end

  # コメントのJSON形式データを生成する共通メソッド
  def comment_json_data(comment)
    {
      id: comment.id,
      content: comment.content,
      created_at: comment.created_at,
      likes_count: comment.respond_to?(:likes_count) ? comment.likes_count :
                   (comment.likes.loaded? ? comment.likes.size : comment.likes.count),
      image_url: comment.respond_to?(:image_url) ? comment.image_url : nil,
      user: user_json_data(comment.user)
    }
  end
end
