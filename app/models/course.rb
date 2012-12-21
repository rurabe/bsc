class Course < ActiveRecord::Base
  attr_accessible :department, :instructor, :number, :section

  belongs_to :booklist
  has_many :books

end
