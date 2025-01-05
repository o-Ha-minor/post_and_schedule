class LikesController < ApplicationController
    def create
        @like = Like.new(user_id: @current_user.id, post_id: params[:post_id])
        if @like.save
            @post = Post.find(params[:post_id])
            @post.increment!(:likes_count)  # likes_countを増加
            flash[:notice] = "いいねしました！"
            redirect_to("/posts/#{@post.id}")
        else
            flash[:alert] = "いいねに失敗しました。"
        end
    end
    def destroy
        @like = Like.find_by(user_id: @current_user.id, post_id: params[:post_id])
        if @like
          @like.destroy
          @post = Post.find(params[:post_id])
          @post.decrement!(:likes_count)  # likes_countを減少
          flash[:notice] = "いいねを削除しました"
          redirect_to("/posts/#{@post.id}")
        else
            flash[:alert] = "いいねを消せませんでした"
        end
    end
end
