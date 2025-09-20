# app/controllers/api/posts_controller.rb
module Api
  class PostsController < ApplicationController
    before_action :require_login, only: [ :create, :update, :destroy ]
    before_action :set_post, only: [ :show, :update, :destroy ]

    def index
      if @current_user
        posts = Post.includes(:user, :group, :comments, :likes)
        if params[:group_id].present?
          posts = posts.where(group_id: params[:group_id])
        else
          posts = posts.where(group_id: @current_user.group_ids)
        end
        posts = posts.order(created_at: :desc)
      else
        Post.none
      end

      posts_data = posts.map { |post| format_post(post) }
      render json: { success: true, data: posts_data }
    end

    def show
      @post = Post.find_by(id: params[:id])
      @current_user = current_user
      # より詳細な情報を含むフォーマット
      formatted_post = {
        id: @post.id,
        content: @post.content,
        image_url: @post.image.attached? ? rails_blob_url(@post.image) : nil,
        created_at: @post.created_at,
        updated_at: @post.updated_at,
        ai_comment: @post.ai_comment,
        sentiment: @post.sentiment,
        sentiment_score: @post.sentiment_score,
        user: {
          id: @post.user.id,
          name: @post.user.name,
          image_url: @post.user.image.attached? ? rails_blob_url(@post.user.image) : nil
        },
        group: @post.group ? {
          id: @post.group.id,
          name: @post.group.name
        } : nil,
        comments: @post.comments.includes(:user).map do |comment|
          {
            id: comment.id,
            content: comment.content,
            created_at: comment.created_at,
            updated_at: comment.updated_at,
            user: {
              id: comment.user.id,
              name: comment.user.name,
              image_url: comment.user.image.attached? ? rails_blob_url(comment.user.image) : nil
            }
          }
        end,
        likes_count: @post.likes.count,
        liked: @current_user ? @post.likes.exists?(user: @current_user) : false,
        like_id: @current_user ? @post.likes.find_by(user: @current_user)&.id : nil
      }

      render json: {
        success: true,
        data: formatted_post
      }
    end

    def create
      @post = @current_user.posts.build(post_params)

      if @post.save
        begin
          ai_comment = AiCommentGenerator.generate_comment(@post.content)
          if ai_comment.present?
            @post.update(
              sentiment: ai_comment[:label],
              sentiment_score: ai_comment[:score],
              ai_comment: ai_comment[:comment]
            )
          end
        rescue => e
          Rails.logger.error("AI comment error: #{e.message}")
        end

        render json: {
          success: true,
          message: "\u6295\u7A3F\u304C\u4F5C\u6210\u3055\u308C\u307E\u3057\u305F",
          data: format_post(@post)
        }, status: :created
      else
        render json: {
          success: false,
          message: "\u6295\u7A3F\u306E\u4F5C\u6210\u306B\u5931\u6557\u3057\u307E\u3057\u305F",
          errors: @post.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    def update
      unless @post.user == @current_user
        render json: {
          success: false,
          message: "\u6A29\u9650\u304C\u3042\u308A\u307E\u305B\u3093"
        }, status: :forbidden
        return
      end

      if @post.update(post_params)
        render json: {
          success: true,
          message: "\u6295\u7A3F\u304C\u66F4\u65B0\u3055\u308C\u307E\u3057\u305F",
          data: format_post(@post)
        }
      else
        render json: {
          success: false,
          message: "\u6295\u7A3F\u306E\u66F4\u65B0\u306B\u5931\u6557\u3057\u307E\u3057\u305F",
          errors: @post.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    def destroy
      unless @post.user == @current_user
        render json: {
          success: false,
          message: "\u6A29\u9650\u304C\u3042\u308A\u307E\u305B\u3093"
        }, status: :forbidden
        return
      end

      if @post.destroy
        render json: {
          success: true,
          message: "\u6295\u7A3F\u304C\u524A\u9664\u3055\u308C\u307E\u3057\u305F"
        }
      else
        render json: {
          success: false,
          message: "\u6295\u7A3F\u306E\u524A\u9664\u306B\u5931\u6557\u3057\u307E\u3057\u305F"
        }, status: :unprocessable_entity
      end
    end

    private

    def set_post
      @post = Post.find_by(id: params[:id])
      unless @post
        render json: {
          success: false,
          message: "\u6295\u7A3F\u304C\u898B\u3064\u304B\u308A\u307E\u305B\u3093"
        }, status: :not_found
      end
    end

    def post_params
      params.require(:post).permit(:content, :group_id, :image)
    end

    def format_post(post)
      {
        id: post.id,
        content: post.content,
        image_url: post.image.attached? ? rails_blob_url(post.image) : nil,
        created_at: post.created_at,
        updated_at: post.updated_at,
        user: {
          id: post.user.id,
          name: post.user.name,
          image_url: post.user.image.attached? ? rails_blob_url(post.user.image) : nil
        },
        group: post.group ? {
          id: post.group.id,
          name: post.group.name
        } : nil,
        comments_count: post.comments.count,
        likes_count: post.likes.count,
        liked_by_current_user: @current_user ? post.likes.exists?(user: @current_user) : false
      }
    end

    def require_login
      unless logged_in?
        render json: {
          success: false,
          message: "\u30ED\u30B0\u30A4\u30F3\u304C\u5FC5\u8981\u3067\u3059"
        }, status: :unauthorized
      end
    end
  end
end
