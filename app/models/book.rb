class Book < ActiveRecord::Base
  attr_accessible :asin,
                  :author, 
                  :edition, 
                  :isbn_10, 
                  :ean, 
                  :requirement, 
                  :title,
                  :bookstore_new_price,
                  :bookstore_new_rental_price,
                  :bookstore_used_price,
                  :bookstore_used_rental_price

  belongs_to :course

  default_scope order('requirement DESC')

  before_create :clean_isbns

  private

    def clean_isbns
      [isbn_10,ean].each do |isbn|
        isbn.gsub!(/[\W_]/,"") if isbn
      end
    end
end
