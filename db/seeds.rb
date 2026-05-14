# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing data
Task.destroy_all
User.destroy_all

# Create demo user
user = User.create!(
  email: "user@example.com",
  password: "password",
  password_confirmation: "password"
)

5.times do |i|
  Task.create(
    title: "Task #{i + 1}",
    description: "Description for task #{i + 1}",
    due_at: Time.current + (i + 1).days,
    user: user
  )
end

5.times do |i|
  Task.create(
    title: "Completed Task #{i + 1}",
    description: "Description for completed task #{i + 1}",
    due_at: Time.current + (i + 5).days,
    completed_at: Time.current,
    user: user
  )
end

5.times do |i|
  Task.create(
    title: "Overdue Task #{i + 1}",
    description: "Description for overdue task #{i + 1}",
    due_at: Time.current - (i + 1).days,
    user: user
  )
end

5.times do |i|
  Task.create(
    title: "Today's Task #{i + 1}",
    description: "Description for today's task #{i + 1}",
    due_at: Time.current.end_of_day - (i * 2).hours,
    user: user
  )
end
