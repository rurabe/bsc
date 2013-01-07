class AddBookstoreNameToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :bookstore_name, :string
  end
end
