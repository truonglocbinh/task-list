module ApplicationHelper
  def task_status_badge(task)
    if task.completed_at.present?
      content_tag(:span, "Completed", class: "badge bg-success")
    elsif task.overdue?
      content_tag(:span, "Overdue", class: "badge bg-danger")
    else
      content_tag(:span, "Pending", class: "badge bg-warning text-dark")
    end
  end

  def task_row_class(task)
    "table-danger" if task.overdue?
  end
end
