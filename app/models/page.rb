class Page < ActiveRecord::Base
  belongs_to :booklist
  attr_accessible :html
end
