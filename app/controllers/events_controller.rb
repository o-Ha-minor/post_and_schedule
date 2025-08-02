class EventsController < ApplicationController
        def index
            @event = Event.new
            @events = Event.where(group: @current_user.groups).order(created_at: :desc)
        end
        def create
          if @current_user
            @group = @current_user.groups.first
            @event = @current_user.events.build(event_params.merge(group: @group))
            if @event.save
              redirect_to events_path, notice: "イベントを作成しました"
            else
              render :new, alert: "イベントを作成できませんでした"
            end
          else
            redirect_to login_path
          end
        end
        def update
          @event = @current_user.events.find(params[:id])
          Rails.logger.debug "Updating event with ID: #{params[:id]}"
          if @event.update(event_params)
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
          params.require(:event).permit(:title, :start, :end, :description)
        end
        def show
          @event = Event.find_by(id: params[:id])
          if @event.nil?
            redirect_to events_path, alert: "イベントが見つかりませんでした。" and return
          end
        end
        private
end
