class Snag < ActiveRecord::Base
  belongs_to :booklist
  attr_accessible :current_page_html, :current_url, :history
end
