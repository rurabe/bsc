class ChangeSearchIdToBooklist < ActiveRecord::Migration
  def change
  	rename_column :courses, :search_id, :booklist_id
  end
end
