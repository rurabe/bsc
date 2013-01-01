class AddUserIdLabelToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :user_id_label, :string
  end
end
