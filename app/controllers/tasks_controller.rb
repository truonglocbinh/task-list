class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [ :show, :edit, :update, :destroy, :toggle_complete ]

  def index
    @tasks = TaskSearchService.new(current_user.tasks, params).call.with_attached_attachments
    @overdue_count = current_user.tasks.overdue.count
  end

  def show
  end

  def new
    @task = current_user.tasks.build
  end

  def edit
  end

  def create
    @task = current_user.tasks.build(task_params)

    if @task.save
      redirect_to tasks_path, notice: "Task was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if params[:task][:remove_attachments].present?
      params[:task][:remove_attachments].each do |attachment_id|
        attachment = @task.attachments.find_by(id: attachment_id)
        attachment.purge if attachment
      end
    end

    new_attachments = params[:task][:attachments]
    update_params = task_params.except(:attachments)

    if @task.update(update_params)
      if new_attachments.present?
        new_attachments.each do |attachment|
          @task.attachments.attach(attachment) if attachment.present?
        end
      end

      redirect_to tasks_path, notice: "Task was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, notice: "Task was successfully deleted."
  end

  def toggle_complete
    if @task.completed_at.present?
      @task.update(completed_at: nil)
    else
      @task.update(completed_at: Time.current)
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to tasks_path }
    end
  end

  private

  def set_task
    @task = current_user.tasks.with_attached_attachments.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :due_at, attachments: [])
  end
end
