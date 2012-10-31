class RemoveEanFromBook < ActiveRecord::Migration
  def up
    remove_column :books, :ean
  end

  def down
    add_column :books, :ean, :string
  end
end
