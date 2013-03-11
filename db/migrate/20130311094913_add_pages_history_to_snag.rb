class AddPagesHistoryToSnag < ActiveRecord::Migration
  def change
    add_column :snags, :pages_history, :text
  end
end
