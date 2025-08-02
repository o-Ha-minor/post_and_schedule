class TasksController < ApplicationController
    def index
        @tasks = Task.where(group: @current_user.groups, status: "pending").order(created_at: :desc)
        @completed_tasks = Task.where(group: @current_user.groups, status: "completed").order(completed_at: :desc)
    end
    def new
        @task = Task.new
    end
    def create
        if @current_user
            @group = @current_user.groups.first
            @task = @current_user.tasks.build(task_params.merge(group: @group))
            @task.status = "pending"

            if @task.save
                Event.create(
                    user_id: @current_user.id,
                    task_id: @task.id,
                    title: @task.title,
                    start: @task.due_date,
                    end: @task.due_date,
                    description: "To doから登録" + (@task.category || "")
                  )
                redirect_to tasks_path, notice: "イベントを作成しました"
            else
                flash[:notice] = "to doが保存できませんでした"
                redirect_to login_path

            end
        else
            redirect_to login_path
        end
    end

    def completed
        @task = Task.find_by(id: params[:id])
        if @task
            @task.status = "completed"
            @task.completed_at = Time.current
            @task.save
            flash[:notice] = "完了しました"
        else
            flash[:notice] = "しばらく経ってから、もう一度お願いします)"
        end
        redirect_to("/tasks")
    end
    def show
        @task = Task.find_by(id: params[:id])
        unless @task
          flash[:alert] = "タスクが見つかりません"
          redirect_to tasks_path and return
        end
    end
    def edit
        @task= Task.find(params[:id])
    end

    def update
        @task = Task.find_by(id: params[:id])
        if @task.update(task_params)
           @task.save
           flash[:notice] = "編集しました"
           redirect_to("/tasks")
        else
           flash[:alert] = "編集できませんでした)"
           render("tasks/edit")
        end
    end
    def destroy
        @task = Task.find_by(id: params[:id])
        if @task != nil
            @task.destroy
            flash[:notice] = "deleted（削除しました）"
            render("home/top")
        else
            flash[:alert] = "not found(対象が見つかりません)"
            render("home/top")
        end
    end


    def task_params
        params.require(:task).permit(:title, :category, :priority, :status, :completed_at, :due_date)
    end
end
