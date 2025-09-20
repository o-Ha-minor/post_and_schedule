# app/controllers/api/groups_controller.rb
module Api
  class GroupsController < ApplicationController
    before_action :require_login, only: [ :create, :join, :leave ]

    def index
      if current_user
        groups = current_user.groups.select(:id, :name)
      else
        groups = Group.select(:id, :name).limit(20)
      end
      render json: { success: true, data: groups }
    end

    def show
      group = Group.find_by(id: params[:id])
      return render_api_response(message: "Group not found", success: false, status: :not_found) unless group

      users = group.users.select(:id, :name)
      render json: { success: true, data: { id: group.id, name: group.name, description: group.description, users: users } }
    end

    def create
      group = Group.new(group_params)
      if group.save
        current_user.groups << group
        render json: { success: true, data: { id: group.id, name: group.name, description: group.description } }, status: :created
      else
        render json: { success: false, errors: group.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def join
      group = Group.find(params[:id])
      unless current_user.groups.exists?(group.id)
        current_user.groups << group
      end
      render json: { success: true }
    end

    def leave
      group = Group.find(params[:id])
      current_user.groups.delete(group)
      render json: { success: true }
    end

    private

    def group_params
      params.require(:group).permit(:name, :description)
    end
  end
end
