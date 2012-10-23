class CartItem < ActiveRecord::Base
  belongs_to :book
  belongs_to :cart

  attr_accessible :book_id,
  								:condition, 
  								:offer_listing_id,
  								:vendor,
  								:price

  def import_book_details
  	self.offer_listing_id = self.book.send("#{vendor}_#{condition}_offer_listing_id".to_sym)
  end

end
