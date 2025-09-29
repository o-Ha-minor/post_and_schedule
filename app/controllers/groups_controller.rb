# class GroupsController < ApplicationController
#   def join
#     group = Group.find(params[:id])
#     unless @current_user.groups.include?(group)
#       @current_user.groups << group
#       message = "グループに参加しました"
#       status = :ok
#     else
#       message = "すでに参加しています"
#       status = :unprocessable_entity
#     end

#     respond_to do |format|
#       format.html {
#         flash[:notice] = message
#         redirect_to root_path
#       }
#       format.json {
#         if status == :ok
#           render json: { message: message }, status: status
#         else
#           render json: { error: message }, status: status
#         end
#       }
#     end
#   end

#   def leave
#     group = Group.find(params[:id])
#     if @current_user.groups.include?(group)
#       @current_user.groups.delete(group)
#       message = "グループから退会しました"
#       status = :ok
#     else
#       message = "参加していません"
#       status = :unprocessable_entity
#     end

#     respond_to do |format|
#       format.html {
#         flash[:notice] = message
#         redirect_to root_path
#       }
#       format.json {
#         if status == :ok
#           render json: { message: message }, status: status
#         else
#           render json: { error: message }, status: status
#         end
#       }
#     end
#   end

#   def index
#     @group = Group.new
#     @groups = @current_user.groups
#     respond_to do |format|
#       format.html
#       format.json { render json: @groups.select(:id, :name) }
#     end
#   end

#   def new
#     @group = Group.new
#   end

#   def create
#     @group = Group.new(group_params)
#     if @group.save
#       @group.users << @current_user

#       respond_to do |format|
#         format.html { redirect_to root_path, notice: "グループを作成しました" }
#         format.json do
#           render json: {
#             id: @group.id,
#             name: @group.name,
#             description: @group.description,
#             members_count: 1
#           }, status: :created
#         end
#       end
#     else
#       respond_to do |format|
#         format.html { render :new, alert: "作成に失敗しました" }
#         format.json { render json: { errors: @group.errors.full_messages }, status: :unprocessable_entity }
#       end
#     end
#   end
#   def show
#     @group = Group.find_by(id: params[:id])
#     unless @group
#       redirect_to root_path, alert: "グループが見つかりません" and return
#     end
#     @users = @group.users.order(created_at: :desc)

#     # JSON形式での応答を追加
#     respond_to do |format|
#       format.html
#       format.json do
#         render json: {
#           id: @group.id,
#           name: @group.name,
#           description: @group.description,
#           users: @users.map do |user|
#             {
#               id: user.id,
#               name: user.name,
#               image_url: user.image_url,
#               created_at: user.created_at
#             }
#           end,
#           members_count: @users.count
#         }
#       end
#     end
#   end

#     private

#     def group_params
#       params.require(:group).permit(:name, :description)
#     end
# end
