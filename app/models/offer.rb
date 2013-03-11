class Offer < ActiveRecord::Base
  attr_accessible :availability, 
                  :comments, 
                  :condition, 
                  :detailed_condition, 
                  :link, 
                  :price, 
                  :shipping_time, 
                  :vendor, 
                  :vendor_book_id, 
                  :vendor_offer_id

  belongs_to :book
end
