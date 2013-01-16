class AddIndexToSchools < ActiveRecord::Migration
  def change
    add_index :schools, :slug, :unique => true
    add_index :courses, :booklist_id
  end
end
