class ChangeSnagsToBelongToSchools < ActiveRecord::Migration
  def change
    remove_column :snags, :booklist_id
    add_column    :snags, :school_id, :integer
  end
end
