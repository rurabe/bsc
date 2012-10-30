class AddBnAttrsToBook < ActiveRecord::Migration
  def change
    add_column :books, :ean, :string
    add_column :books, :bn_new_price, :decimal, :precision => 6, :scale => 2
    add_column :books, :bn_link, :string
  end
end
