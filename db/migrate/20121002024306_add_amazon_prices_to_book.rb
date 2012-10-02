class AddAmazonPricesToBook < ActiveRecord::Migration
  def change
    add_column :books, :amazon_new_price, :decimal, :precision => 6, :scale => 2
    add_column :books, :amazon_used_price, :decimal, :precision => 6, :scale => 2
  end
end
