# class TasksController < ApplicationController
#     def index
#       if @current_user
#         @tasks = Task.where(group: @current_user.groups, status: "pending").order(created_at: :desc)
#         @completed_tasks = Task.where(group: @current_user.groups, status: "completed").order(completed_at: :desc)

#         respond_to do |format|
#           format.html
#           format.json { render json: { tasks: @tasks, completed_tasks: @completed_tasks } }
#         end
#       else
#         redirect_to root_path, alert: "ログインしてください"
#       end
#     end

#     def new
#       @task = Task.new
#     end

#     def create
#       if @current_user
#         @group = @current_user.groups.first
#         @task = @current_user.tasks.build(task_params.merge(group: @group))
#         @task.status = "pending"

#         if @task.save
#             if params[:task][:create_event] == true && @task.due_date.present?
#                 create_event_from_task(@task)
#             end
#             respond_to do |format|
#                 format.html { redirect_to tasks_path, notice: "タスクを作成しました" }
#                 format.json { render json: @task, status: :created }
#             end
#         else
#           respond_to do |format|
#             format.html {
#               flash[:notice] = "タスクが保存できませんでした"
#               redirect_to login_path
#             }
#             format.json { render json: { errors: @task.errors }, status: :unprocessable_entity }
#           end
#         end
#       else
#         respond_to do |format|
#           format.html { redirect_to login_path }
#           format.json { render json: { error: "ログインが必要です" }, status: :unauthorized }
#         end
#       end
#     end

#     def completed
#       @task = Task.find_by(id: params[:id])

#       if @task
#         @task.update(status: "completed", completed_at: Time.current)

#         respond_to do |format|
#           format.html {
#             flash[:notice] = "完了しました"
#             redirect_to tasks_path
#           }
#           format.json { render json: @task, status: :ok }
#         end
#       else
#         respond_to do |format|
#           format.html {
#             flash[:alert] = "タスクが見つかりません"
#             redirect_to tasks_path
#           }
#           format.json { render json: { error: "タスクが見つかりません" }, status: :not_found }
#         end
#       end
#     end

#     def show
#         @task = Task.find_by(id: params[:id])
#         unless @task
#           respond_to do |format|
#             format.html {
#               flash[:alert] = "タスクが見つかりません"
#               redirect_to tasks_path
#             }
#             format.json { render json: { error: "タスクが見つかりません" }, status: :not_found }
#           end
#           return  # 重要：ここでメソッドを終了
#         end

#         # @taskが存在する場合の処理
#         respond_to do |format|
#           format.html  # show.html.erbを表示
#           format.json { render json: @task }  # JSONでタスク情報を返す
#         end
#     end

#     def edit
#       @task = Task.find(params[:id])
#     end

#     def update
#         @task = Task.find_by(id: params[:id])
#         event = @task&.event
#         if @task&.update(task_params)
#           # カレンダー連携チェックが入っていて期限がある場合
#           if params[:task][:create_event].present? && @task.due_date.present?
#             # すでにイベントが存在する場合は更新、なければ新規作成
#             event = Event.find_by(task_id: @task.id)
#             if event
#               event.update(
#                 title: @task.title,
#                 start: @task.due_date.change(hour: 9, min: 0),
#                 end: @task.due_date.change(hour: 10, min: 0),
#                 description: build_event_description(@task),
#                 group_id: @task.group_id
#               )
#             else
#               create_event_from_task(@task)
#             end
#           else
#             event&.destroy
#           end

#           respond_to do |format|
#             format.html {
#               flash[:notice] = "編集しました"
#               redirect_to tasks_path
#             }
#             format.json { render json: @task, status: :ok }
#           end
#         else
#           respond_to do |format|
#             format.html {
#               flash[:alert] = "編集できませんでした"
#               render "tasks/edit"
#             }
#             format.json {
#               render json: {
#                 errors: @task ? @task.errors : { base: [ "タスクが見つかりません" ] }
#               }, status: :unprocessable_entity
#             }
#           end
#         end
#     end

#     def destroy
#       @task = Task.find_by(id: params[:id])

#       if @task
#         @task.destroy
#         respond_to do |format|
#           format.html {
#             flash[:notice] = "削除しました"
#             redirect_to tasks_path
#           }
#           format.json { head :no_content }
#         end
#       else
#         respond_to do |format|
#           format.html {
#             flash[:alert] = "タスクが見つかりません"
#             redirect_to tasks_path
#           }
#           format.json { render json: { error: "タスクが見つかりません" }, status: :not_found }
#         end
#       end
#     end

#     private

#     def create_event_from_task(task)
#         return unless task.due_date.present?

#         begin
#           # due_dateから開始時刻を設定（時刻情報がない場合は9:00に設定）
#           start_time = if task.due_date.hour == 0 && task.due_date.min == 0
#                          task.due_date.change(hour: 9, min: 0)
#           else
#                          task.due_date
#           end

#           # 終了時刻を設定（開始時刻の1時間後）
#           end_time = start_time + 1.hour

#           Event.create!(
#             user_id: @current_user.id,
#             task_id: task.id,
#             title: task.title,
#             start: start_time,
#             end: end_time,
#             description: build_event_description(task),
#             group_id: task.group_id
#           )

#           Rails.logger.info "Event created for task #{task.id}"
#         rescue => e
#           Rails.logger.error "Failed to create event for task #{task.id}: #{e.message}"
#           # エラーがあってもタスク作成は成功させる
#         end
#     end

#       def build_event_description(task)
#         description_parts = [ "タスクから作成" ]
#         description_parts << "カテゴリ: #{task.category}" if task.category.present?
#         description_parts << "優先度: #{priority_label(task.priority)}" if task.priority.present?
#         description_parts << task.description if task.description.present?
#         description_parts.join("\n")
#       end

#       def priority_label(priority)
#         case priority
#         when "high" then "\u9AD8"
#         when "medium" then "\u4E2D"
#         when "low" then "\u4F4E"
#         else priority
#         end
#       end

#     def task_params
#       params.require(:task).permit(:title, :description, :category, :priority, :status, :completed_at, :due_date, :group_id)
#     end
# end
