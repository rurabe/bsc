class Course < ActiveRecord::Base
  attr_accessible :department, :instructor, :number, :section
end
