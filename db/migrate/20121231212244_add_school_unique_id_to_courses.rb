class AddSchoolUniqueIdToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :school_unique_id, :string
  end
end
