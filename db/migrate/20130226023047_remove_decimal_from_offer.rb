class RemoveDecimalFromOffer < ActiveRecord::Migration
  def change
    remove_column :offers, :decimal
  end
end
