class AddOffersToBooks < ActiveRecord::Migration
  def change
    add_column :books, :amazon_new_offer_listing_id, :string
    add_column :books, :amazon_used_offer_listing_id, :string
  end
end
