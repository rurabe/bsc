class AddColorsToSchools < ActiveRecord::Migration
  def change
    add_column :schools, :primary_color, :string, :limit => 6
    add_column :schools, :secondary_color, :string, :limit => 6
  end
end
