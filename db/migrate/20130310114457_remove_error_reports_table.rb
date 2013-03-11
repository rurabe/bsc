class RemoveErrorReportsTable < ActiveRecord::Migration
  def change
    drop_table :error_reports
  end
end
