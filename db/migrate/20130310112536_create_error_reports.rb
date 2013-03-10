class CreateErrorReports < ActiveRecord::Migration
  def change
    create_table :error_reports do |t|
      t.text :current_url
      t.text :current_page_html
      t.text :history
      t.references :booklist

      t.timestamps
    end
  end
end
