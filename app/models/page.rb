class Page < ActiveRecord::Base
  belongs_to :booklist
  attr_accessible :html

  def parsed_html
    Nokogiri::HTML(html)
  end
end
