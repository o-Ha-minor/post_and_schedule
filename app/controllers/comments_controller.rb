class CommentsController < ApplicationController
    def create
        @post = Post.find_by(id: params[:post_id])
        if @post == nil
            flash[:alert] = "Post not found（投稿が見つかりません）"
            redirect_to(posts_path)
            return
        end
        @comment = @post.comments.new(comment_params.merge(user_id: @current_user.id))
        if @comment.save
            flash[:notice] = "Comment has created(コメントできました)"
            redirect_to(@post)
        
        else
            render :new
            
        end
    end
    def destroy
        @comment = Comment.find_by(id: params[:id])
        @comment.destroy
        redirect_to post_path(@comment.post), notice: "コメントを削除しました。"
    end
    private
    def comment_params
        params.require(:comment) .permit(:content)
    end

end
