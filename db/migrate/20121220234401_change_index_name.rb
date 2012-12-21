class ChangeIndexName < ActiveRecord::Migration
  def change
  	rename_index :booklists, :index_searches_on_slug, :index_booklists_on_slug
  end
end
