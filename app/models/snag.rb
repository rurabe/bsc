class Snag < ActiveRecord::Base
  belongs_to :school
  attr_accessible :error,
                  :backtrace,
                  :current_page_html, 
                  :current_url,
                  :history
end
