class Course < ActiveRecord::Base
  belongs_to :booklist
  has_many :sections, :dependent => :destroy
  has_many :books, :through => :sections

  attr_accessible :department,
  								:number,
                  :school_unique_id,
                  :sections_attributes


  accepts_nested_attributes_for :sections

  default_scope order('department ASC, number DESC')

end
