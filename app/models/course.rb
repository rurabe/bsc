class Course < ActiveRecord::Base
  attr_accessible :department, 
  								:instructor, 
  								:number, 
  								:section,
  								:books_attributes

  belongs_to :booklist
  has_many :books

  accepts_nested_attributes_for :books

end
