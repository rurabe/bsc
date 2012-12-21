class ChangeSearchesToBooklists < ActiveRecord::Migration
  def change
  	rename_table :searches, :booklists
  end
end
