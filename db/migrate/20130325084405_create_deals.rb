class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
      t.string :description
      t.text :link

      t.timestamps
    end
  end
end
