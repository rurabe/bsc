class AddUsedBooksToBooks < ActiveRecord::Migration
  def change
    add_column :books, :bn_used_price, :decimal, :precision => 6, :scale => 2
    add_column :books, :bn_used_ean, :string
    remove_column :books, :bn_link
  end
end
