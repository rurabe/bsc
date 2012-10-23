class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.references :search
      t.string :vendor
      t.string :link

      t.timestamps
    end
    add_index :carts, :search_id
  end
end
