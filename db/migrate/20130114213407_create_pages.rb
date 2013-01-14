class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.references :booklist
      t.text :html

      t.timestamps
    end
    add_index :pages, :booklist_id
  end
end
