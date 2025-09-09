class EventsController < ApplicationController
  before_action :set_event, only: [ :show, :update, :destroy ]
  before_action :authorize_event, only: [ :update, :destroy ]

  def index
    if @current_user
      @events = Event.where(group: @current_user.groups).order(created_at: :desc)

      respond_to do |format|
        format.html
        format.json {
          render json: @events.map { |event|
            {
              id: event.id,
              title: event.title,
              start: event.start_time&.iso8601,
              end: event.end_time&.iso8601,
              description: event.description,
              group_id: event.group_id,
              group: event.group ? { id: event.group.id, name: event.group.name } : nil
            }
          }
        }
      end
    else
      respond_to do |format|
        format.html { redirect_to login_path }
        format.json { render json: { error: "ログインしてください" }, status: :unauthorized }
      end
    end
  end
  def create
    if @current_user
      @event = @current_user.events.build(event_params)
      @event.group ||= @current_user.groups.first

      if @event.save
        render json: {
          id: @event.id,
          title: @event.title,
          start: @event.start_time&.iso8601,
          end: @event.end_time&.iso8601,
          description: @event.description,
          group_id: @event.group_id,
          group: @event.group ? { id: @event.group.id, name: @event.group.name } : nil
        }, status: :created
      else
        render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "ログインしてください" }, status: :unauthorized
    end
  end
  def update
    if @event.update(event_params)
      render json: {
        id: @event.id,
        title: @event.title,
        start: @event.start_time&.iso8601,
        end: @event.end_time&.iso8601,
        description: @event.description,
        group_id: @event.group_id,
        group: @event.group ? { id: @event.group.id, name: @event.group.name } : nil
      }
    else
      render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @event.destroy
      head :no_content
    else
      render json: { error: "削除に失敗しました" }, status: :unprocessable_entity
    end
  end

  def show
    if @event
      render json: {
        id: @event.id,
        title: @event.title,
        start: @event.start_time&.iso8601,
        end: @event.end_time&.iso8601,
        description: @event.description,
        group_id: @event.group_id,
        group: @event.group ? { id: @event.group.id, name: @event.group.name } : nil
      }
    else
      render json: { error: "イベントが見つかりませんでした。" }, status: :not_found
    end
  end
  private

  def authorize_event
    @event = Event.find_by(id: params[:id])
    unless @event && @event.user == @current_user
      render json: { error: "権限が不足しています" }, status: :forbidden
    end
  end

  def set_event
    @event = @current_user.events.find_by(id: params[:id])
    unless @event
      render json: { error: "イベントが見つかりませんでした" }, status: :not_found
    end
  end

  def event_params
    params.require(:event).permit(:title, :start, :end, :description, :group_id)
  end
end
