module Api
 class CommentsController < ApplicationController
      before_action :require_login
      before_action :set_post

      def create
        comment = @post.comments.build(comment_params.merge(user_id: @current_user.id))
        if comment.save
          render json: comment.as_json(
            only: [ :id, :content, :created_at ],
            methods: [],
            include: { user: { only: [ :id, :name ] } }
          ), status: :created
        else
          render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        comment = @post.comments.find_by(id: params[:id])
        return render json: { error: "not found" }, status: :not_found unless comment

        if comment.user_id != @current_user.id
          return render json: { error: "forbidden" }, status: :forbidden
        end

        comment.destroy
        render json: { message: "コメントが削除されました", comment_id: params[:id] }, status: :ok
      end

      def update
        comment = @post.comments.find(params[:id])
        return render json: { error: "forbidden" }, status: :forbidden unless comment.user_id == @current_user.id

        if comment.update(comment_params)
          render json: comment, status: :ok
        else
          render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      end


      private
      def set_post
        @post = Post.find_by(id: params[:post_id])
        render json: { error: "post not found" }, status: :not_found unless @post
      end

      def comment_params
        params.require(:comment).permit(:content)
      end

      def require_login
        render json: { error: "unauthorized" }, status: :unauthorized unless @current_user
      end
 end
end
