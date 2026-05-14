class AddIndexToTasks < ActiveRecord::Migration[7.2]
  def change
    add_index :tasks, [ :user_id, :due_at ]
    add_index :tasks, [ :user_id, :completed_at ]
  end
end
