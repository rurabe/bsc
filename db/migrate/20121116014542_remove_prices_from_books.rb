class RemovePricesFromBooks < ActiveRecord::Migration
  def change
		remove_column :books, :amazon_new_price
    remove_column :books, :amazon_new_offer_listing_id
    remove_column :books, :amazon_used_price
    remove_column :books, :amazon_used_offer_listing_id
    remove_column :books, :bn_new_price
    remove_column :books, :bn_used_price
    remove_column :books, :bn_used_ean
  end
end
