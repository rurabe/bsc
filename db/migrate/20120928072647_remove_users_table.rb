class RemoveUsersTable < ActiveRecord::Migration
  def change
  	remove_column :courses, :user_id
  	add_column :courses, :search_id, :integer
  end
end
