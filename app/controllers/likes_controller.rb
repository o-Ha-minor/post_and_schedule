# # app/controllers/likes_controller.rb
# class LikesController < ApplicationController
#     before_action :require_login

#     def create
#       post = Post.find_by(id: params[:post_id])
#       return render json: { error: "post not found" }, status: :not_found unless post

#       like = Like.find_by(user_id: @current_user.id, post_id: post.id)
#       if like
#         render json: { id: like.id, likes_count: post.likes.count, liked: true }, status: :ok
#         return
#       end

#       like = Like.new(user_id: @current_user.id, post_id: post.id)
#       if like.save
#         render json: { id: like.id, likes_count: post.likes.count, liked: true }, status: :created
#       else
#         render json: { errors: like.errors.full_messages }, status: :unprocessable_entity
#       end
#     end

#     def destroy
#       like = Like.find_by(id: params[:id], user_id: @current_user.id)
#       unless like
#         return render json: { error: "not found" }, status: :not_found
#       end

#       post = like.post
#       like.destroy
#       render json: { likes_count: post.likes.count, liked: false }, status: :ok
#     end

#     private
#     def require_login
#       render json: { error: "unauthorized" }, status: :unauthorized unless @current_user
#     end
# end
