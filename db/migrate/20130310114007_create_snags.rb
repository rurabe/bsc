class CreateSnags < ActiveRecord::Migration
  def change
    create_table :snags do |t|
      t.text :current_url
      t.text :current_page_html
      t.text :history
      t.references :booklist

      t.timestamps
    end
    add_index :snags, :booklist_id
  end
end
