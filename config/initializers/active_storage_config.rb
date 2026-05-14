# frozen_string_literal: true

# Active Storage Configuration
Rails.application.config.after_initialize do
  # Set default maximum file size for uploads (default is 5TB)
  # This is a hard limit enforced by Rails
  # Individual model validations can be more restrictive
  # ActiveStorage::Blob.max_file_size = 10.megabytes

  # Note: For production, you may also want to configure:
  # - Nginx/Apache file upload size limits
  # - AWS S3 bucket policies
  # - Content Security Policy headers
end

# Task Attachment Configuration
module TaskAttachmentConfig
  # Maximum file size per attachment
  MAX_FILE_SIZE = 10.megabytes

  # Maximum number of attachments per task
  MAX_ATTACHMENTS = 10

  # Allowed content types
  ALLOWED_CONTENT_TYPES = [
    "image/png",
    "image/jpg",
    "image/jpeg",
    "image/gif",
    "image/webp",
    "application/pdf",
    "application/msword", # .doc
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document", # .docx
    "application/vnd.ms-excel", # .xls
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", # .xlsx
    "text/plain"
  ].freeze

  # Human-readable allowed types
  ALLOWED_TYPES_DESCRIPTION = "images, PDFs, Word documents, Excel files, or text files".freeze
end
