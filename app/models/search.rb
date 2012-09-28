class Search < ActiveRecord::Base
  attr_accessible :username, :password

  has_many :courses
end
