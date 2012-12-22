class RemoveCredentialsFromBooklist < ActiveRecord::Migration
  def change
  	remove_column :booklists, :username
  	remove_column :booklists, :password
  end
end
