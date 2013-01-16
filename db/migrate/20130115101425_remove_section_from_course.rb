class RemoveSectionFromCourse < ActiveRecord::Migration
  def change
    remove_column :courses, :section
    remove_column :courses, :instructor
  end
end
