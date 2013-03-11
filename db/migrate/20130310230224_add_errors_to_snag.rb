class AddErrorsToSnag < ActiveRecord::Migration
  def change
    add_column :snags, :error, :string
    add_column :snags, :backtrace, :text
  end
end
