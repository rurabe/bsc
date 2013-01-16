class AddNotesToBook < ActiveRecord::Migration
  def change
    add_column :books, :notes, :string
  end
end
