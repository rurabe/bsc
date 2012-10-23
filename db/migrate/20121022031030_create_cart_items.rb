class CreateCartItems < ActiveRecord::Migration
  def change
    create_table :cart_items do |t|
      t.references :book
      t.references :cart
      t.string :condition
      t.string :offer_listing_id

      t.timestamps
    end
    add_index :cart_items, :book_id
    add_index :cart_items, :cart_id
  end
end
