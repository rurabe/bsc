class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :id
      t.string :password

      t.timestamps
    end
  end
end
