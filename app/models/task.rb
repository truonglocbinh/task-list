class Task < ApplicationRecord
  belongs_to :user
  has_many_attached :attachments

  validates :title, presence: true

  # Attachment validations
  validates :attachments, content_type: {
    in: [ "image/png", "image/jpeg", "image/gif", "image/webp", "image/svg+xml",
         "application/pdf",
         "application/msword", # .doc
         "application/vnd.openxmlformats-officedocument.wordprocessingml.document", # .docx
         "application/vnd.ms-excel", # .xls
         "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", # .xlsx
         "text/plain" ],
    message: "must be an image, PDF, Word document, Excel file, or text file"
  },
  size: {
    less_than: 10.megabytes,
    message: "must be less than 10MB"
  },
  limit: {
    max: 10,
    message: "You can only attach up to 10 files per task"
  }

  # Scopes
  scope :by_due_date, -> { order(Arel.sql("CASE WHEN due_at IS NULL THEN 1 ELSE 0 END, due_at ASC")) }
  scope :due_today, -> { where("due_at <= ?", Time.current.end_of_day).where("due_at >= ?", Time.current.beginning_of_day) }
  scope :overdue, -> { where("due_at < ? AND completed_at IS NULL", Time.current) }

  # Search scopes
  scope :search_text, ->(query) {
    return all if query.blank?
    where("title ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%")
  }

  scope :by_status, ->(status) {
    return all if status.blank?
    case status
    when "completed"
      where.not(completed_at: nil)
    when "pending"
      where(completed_at: nil).where("due_at IS NULL OR due_at >= ?", Time.current)
    when "overdue"
      where(completed_at: nil).where("due_at < ?", Time.current)
    else
      all
    end
  }

  scope :by_due_date_filter, ->(date) {
    return all if date.blank?
    date_obj = Date.parse(date) rescue nil
    return all if date_obj.nil?
    where("DATE(due_at) = ?", date_obj)
  }

  scope :by_due_date_range, ->(from_date, to_date) {
    return all if from_date.blank? && to_date.blank?

    scope = all

    if from_date.present?
      from_date_obj = Date.parse(from_date) rescue nil
      scope = scope.where("due_at >= ?", from_date_obj.beginning_of_day) if from_date_obj
    end

    if to_date.present?
      to_date_obj = Date.parse(to_date) rescue nil
      scope = scope.where("due_at <= ?", to_date_obj.end_of_day) if to_date_obj
    end

    scope
  }

  # Instance methods
  def overdue?
    due_at.present? && due_at < Time.current && completed_at.nil?
  end

  def due_today?
    due_at.present? && due_at.to_date == Date.current
  end
end
