class AddLinkToBooks < ActiveRecord::Migration
  def change
    add_column :books, :link, :string
  end
end
