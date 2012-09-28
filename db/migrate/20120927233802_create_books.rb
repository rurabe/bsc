class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.string :isbn_13
      t.string :isbn_10
      t.string :edition
      t.string :requirement
      t.string :asin
      t.references :course

      t.timestamps
    end
  end
end
