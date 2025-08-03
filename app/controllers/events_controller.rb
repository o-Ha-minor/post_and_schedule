class EventsController < ApplicationController
    def index
      if @current_user
        @event = Event.new
        @events = Event.where(group: @current_user.groups).order(created_at: :desc)
      else
        redirect_to root_path alert: "ログインしてください"
      end
    end
    def create
      if @current_user
        start_datetime = to_datetime(params[:event][:start_date], params[:event][:start_time])
        end_datetime = to_datetime(params[:event][:end_date], params[:event][:end_time])

        @event = @current_user.events.build(event_params)
        @event.start = start_datetime
        @event.end = end_datetime
        @event.group ||= @current_user.groups.first
        if @event.save
          redirect_to events_path, notice: "イベントを作成しました"
        else
          render :index, alert: "イベントを作成できませんでした"
        end
      else
        redirect_to login_path
      end
    end
    def update
      @event = @current_user.events.find(params[:id])
      start_datetime = to_datetime(params[:event][:start_date], params[:event][:start_time])
      end_datetime = to_datetime(params[:event][:end_date], params[:event][:end_time])

      if @event.update(event_params.merge(start: start_datetime, end: end_datetime))
        redirect_to events_path, notice: "イベントを更新しました"
      else
        render :edit, alert: "更新に失敗しました"
      end
    end
    def destroy
      @event = @current_user.events.find_by(id: params[:id])
      if @event.destroy
        redirect_to events_path, notice: "イベントを削除しました。"
      else
        redirect_to events_path, alert: "削除に失敗しました。"
      end
    end
    def edit
      @event = Event.find_by(id: params[:id], user_id: @current_user.id)
      if @event.nil?
        redirect_to events_path, alert: "イベントが見つかりませんでした。"
      elsif @event.user_id != @current_user.id
        render "show"
      end
    end
    before_action :authorize_event, only: [ :edit, :update, :destroy ]

    def authorize_event
      @event = Event.find_by(id: params[:id])
      if @event.user != @current_user
        render "show", alert: "権限が不足しています"
      end
    end
    def event_params
      params.require(:event).permit(:title, :start, :end, :description, :group_id)
    end
    def show
      @event = Event.find_by(id: params[:id])
      if @event.nil?
        redirect_to events_path, alert: "イベントが見つかりませんでした。" and return
      end
    end
    private
    def to_datetime(date_str, time_str)
      DateTime.parse("#{date_str} #{time_str}")
    rescue ArgumentError
      nil
    end
end
