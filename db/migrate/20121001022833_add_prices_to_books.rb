class AddPricesToBooks < ActiveRecord::Migration
  def change
    add_column :books, :bookstore_new_price, :decimal, :precision => 6, :scale => 2
    add_column :books, :bookstore_new_rental_price, :decimal, :precision => 6, :scale => 2
    add_column :books, :bookstore_used_price, :decimal, :precision => 6, :scale => 2
    add_column :books, :bookstore_used_rental_price, :decimal, :precision => 6, :scale => 2
  end
end
