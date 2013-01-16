class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :school_unique_id
      t.references :course

      t.timestamps
    end
    add_index :sections, :course_id
  end
end
