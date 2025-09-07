class GroupsController < ApplicationController
  def join
    group = Group.find(params[:id])
    unless @current_user.groups.include?(group)
      @current_user.groups << group
      flash[:notice] = "グループに参加しました"
    else
      flash[:alert] = "すでに参加しています"
    end
    redirect_to root_path
  end

  def leave
    group = Group.find(params[:id])
  if @current_user.groups.include?(group)
    @current_user.groups.delete(group)
    flash[:notice] = "グループから退会しました"
  else
    flash[:alert] = "参加していません"
  end
  redirect_to root_path
  end

  def index
    @group = Group.new
    @groups = @current_user.groups
    respond_to do |format|
      format.html
      format.json { render json: @groups.select(:id, :name) }
    end
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      @group.users << @current_user
      redirect_to root_path, notice: "グループを作成しました"
    else
      render :new, alert: "作成に失敗しました"
    end
  end
  def show
    @group = Group.find_by(id: params[:id])
    unless @group
      redirect_to root_path, alert: "グループが見つかりません" and return
    end
    @users = @group.users.order(created_at: :desc)
  end

    private

    def group_params
      params.require(:group).permit(:name, :description)
    end
end
