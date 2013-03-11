class ChangeLinksToText < ActiveRecord::Migration
  def change
    remove_column :books,  :link
    remove_column :offers, :link
    add_column    :books,  :link, :text
    add_column    :offers, :link, :text
  end
end
