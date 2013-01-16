class Section < ActiveRecord::Base
  belongs_to :course
  has_many :books

  attr_accessible :school_unique_id,
                  :course_id,
                  :instructor,
                  :books_attributes

  accepts_nested_attributes_for :books
end
