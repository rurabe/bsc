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
                  :bookstore_used_rental_price,
                  :amazon_new_price,
                  :amazon_new_offer_listing_id,
                  :amazon_used_price,
                  :amazon_used_offer_listing_id,
                  :bn_new_price,
                  :bn_used_price,
                  :bn_used_ean

  belongs_to :course

  default_scope order('requirement DESC')

  before_create :clean_isbns

  def query_amazon
    query = Amazon::ItemSearch.new(ean)
    assign_attributes(query.parsed_response)
  end

  def query_bn
    query = BarnesAndNoble::ItemLookup.new(ean)
    assign_attributes(query.parsed_response)
  end

  private

    def clean_isbns
      [isbn_10,ean].each do |isbn|
        isbn.gsub!(/[\W_]/,"") if isbn
      end
    end
end
