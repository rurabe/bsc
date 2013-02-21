class Book < ActiveRecord::Base
  attr_accessible :asin,
                  :author, 
                  :edition, 
                  :isbn_10, 
                  :ean, 
                  :link,
                  :requirement, 
                  :title,
                  :notes,
                  :bookstore_new_price,
                  :bookstore_new_rental_price,
                  :bookstore_used_price,
                  :bookstore_used_rental_price,
                  :offers_attributes

  belongs_to :section
  has_many   :offers, :dependent => :destroy
  accepts_nested_attributes_for :offers

  default_scope order('requirement DESC')

  before_create :clean_isbns
  
  private

    def clean_isbns
      [isbn_10,ean].each do |isbn|
        isbn.gsub!(/[\W_]/,"") if isbn
      end
    end
end
