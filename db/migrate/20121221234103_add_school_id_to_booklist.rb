class AddSchoolIdToBooklist < ActiveRecord::Migration
  def change
    change_table :booklists do |t|
	    t.references :school
	  end
  end
end
