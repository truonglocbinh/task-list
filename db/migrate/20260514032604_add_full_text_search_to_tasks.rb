class AddFullTextSearchToTasks < ActiveRecord::Migration[7.2]
  def change
    enable_extension 'pg_trgm'
    add_index :tasks, :title, using: :gin, opclass: :gin_trgm_ops
    add_index :tasks, :description, using: :gin, opclass: :gin_trgm_ops
  end
end
