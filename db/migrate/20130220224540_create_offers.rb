class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.string :condition
      t.string :vendor
      t.decimal :price, :decimal, :precision => 6, :scale => 2
      t.string :vendor_book_id
      t.string :vendor_offer_id
      t.string :detailed_condition
      t.string :availability
      t.string :shipping_time
      t.string :comments
      t.string :link
      t.references :book

      t.timestamps
    end
  end
end
