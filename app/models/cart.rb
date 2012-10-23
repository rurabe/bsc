class Cart < ActiveRecord::Base
  belongs_to :search
  has_many :cart_items

  attr_accessible :link, 
  								:vendor,
  								:cart_items_attributes

  accepts_nested_attributes_for :cart_items

  def update_item_details
  	cart_items.each { |item| item.import_book_details }
  end
end
