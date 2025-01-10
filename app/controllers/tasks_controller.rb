class TasksController < ApplicationController
    def index
        @tasks = Task.where(status: "pending")# ここで @tasks に未完成タスク一覧を代入
        @completed_tasks = Task.where(status: "completed").order(completed_at: :desc)# ここで @tasks に完了済タスク一覧を代入
    end
    def new
    end
    def create
        if @current_user
            @task = Task.new(title: params[:title],
                            status: "pending",
                            category: params[:category],
                            priority: params[:priority],
                            user_id: @current_user.id,
                            due_date: params[:due_date]
                            )
            if @task.save
                Event.create(
                    user_id: @current_user.id,
                    task_id: @task.id,
                    title: @task.title,
                    start: @task.due_date,
                    end: @task.due_date,
                    description: "To doから登録" + @task.category
                  )
                redirect_to("/tasks")
                flash[:notice] = "to doを追加しました"
            else
                render("tasks/index")
                flash[:notice] = "to doが保存できませんでした"
            end
        else
            redirect_to("/login")
        end
    end
    def completed
        @task = Task.find_by(id: params[:id])
        if @task
            @task.status = "completed"
            @task.completed_at = Time.current  # 完了日時を記録する
            @task.save
            flash[:notice] = "completed（完了しました！）"
        else
            flash[:notice] = "To do not found(しばらく経ってから、もう一度お願いします。。)"
        end
        redirect_to("/tasks")
    end
    def show
        @task = Task.find_by(id: params[:id])
    end
    def edit
        @task= Task.find(params[:id])
    end

    def update
        @task = Task.find_by(id: params[:id])
        if @task.update(task_params)
           @task.save
           flash[:notice] = "success(編集しました)"
           redirect_to("/tasks")
        else
           flash[:alert] = "faild(失敗しました)"
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
