class TaskSearchService
  attr_reader :tasks, :params

  def initialize(tasks, params)
    @tasks = tasks
    @params = params
  end

  def call
    apply_filters
    apply_sorting
    paginate
  end

  private

  def apply_filters
    @tasks = apply_text_search(@tasks)
    @tasks = apply_status_filter(@tasks)
    @tasks = apply_date_filters(@tasks)
    @tasks = apply_quick_filter(@tasks)
  end

  def apply_text_search(scope)
    return scope if params[:search].blank?
    scope.search_text(params[:search])
  end

  def apply_status_filter(scope)
    return scope if params[:status].blank?
    scope.by_status(params[:status])
  end

  def apply_date_filters(scope)
    if params[:due_date_from].present? || params[:due_date_to].present?
      scope.by_due_date_range(params[:due_date_from], params[:due_date_to])
    else
      scope
    end
  end

  def apply_quick_filter(scope)
    return scope unless params[:filter] == "today"
    scope.due_today
  end

  def apply_sorting
    @tasks = @tasks.by_due_date if params[:search].blank?
  end

  def paginate
    @tasks.page(params[:page]).per(15)
  end
end
