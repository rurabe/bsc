class AddUsernameToSearch < ActiveRecord::Migration
  def change
    add_column :searches, :username, :string
  end
end
