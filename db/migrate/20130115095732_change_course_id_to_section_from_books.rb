class ChangeCourseIdToSectionFromBooks < ActiveRecord::Migration
  def change
    remove_column :books, :course_id
    add_column    :books, :section_id, :integer
    add_index     :books, :section_id
  end
end
