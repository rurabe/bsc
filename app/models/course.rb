class Course < ActiveRecord::Base
  attr_accessible :department, :instructor, :number, :section

  belongs_to :search
  has_many :books

end
