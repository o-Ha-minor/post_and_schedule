class CommentsController < ApplicationController
    def new
      @comment = Comment.new
    end
    def create
        @post = Post.find_by(id: params[:post_id])
        if @post == nil
            flash[:alert] = "投稿が見つかりません"
            redirect_to(posts_path)
            return
        end
        @comment = @post.comments.new(comment_params.merge(user_id: @current_user.id))
        if @comment.save
            flash[:notice] = "コメントできました"
            redirect_to(@post)
        else
            render :new
        end
    end
    def destroy
        @comment = Comment.find_by(id: params[:id])
        @post = @comment.post
        @comment.id = @post.id
        @comment.destroy
        redirect_to post_path(@post), notice: "コメントを削除しました。"
    end
    private
    def comment_params
        params.require(:comment) .permit(:content)
    end
end
