class ChangeIsbn13ToEanFromBook < ActiveRecord::Migration
  def change
  	remove_column :books, :isbn_13
  	add_column :books, :ean, :string, :limit => 13
  end
end
