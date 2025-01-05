class EventsController < ApplicationController
        def index
            @event = Event.new
            @events = Event.all # カレンダーに表示するイベント
        end
      
        def create
          if @current_user
            event = @current_user.events.build(event_params)
            if event.save
              redirect_to events_path, notice: "Added events イベントを作成しました"
            else
              render :new, alart: "Faild 失敗しました"
            end
          else
            redirect_to("/login")
          end
        end
      
        def update
          # イベントを更新
          @event = @current_user.events.find(params[:id])
          Rails.logger.debug "Updating event with ID: #{params[:id]}"
          if @event.update(event_params)
            redirect_to events_path, notice: "Update events イベントを更新しました"
          else
            render :edit, alart: "Faild 失敗しました"
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
      
        before_action :authorize_event, only: [:edit, :update, :destroy]

        private

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
            redirect_to events_path, alert: "イベントが見つかりませんでした。"
          end
          
        end
end