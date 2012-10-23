class AddInfoToCartItem < ActiveRecord::Migration
  def change
    add_column :cart_items, :price, :decimal, :precision => 6, :scale => 2
    add_column :cart_items, :vendor, :string
  end
end
