class AddIndexToBooks < ActiveRecord::Migration
  def change
    add_index :books, :ean
  end
end
