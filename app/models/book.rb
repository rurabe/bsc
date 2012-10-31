class Book < ActiveRecord::Base
  attr_accessible :asin,
                  :author, 
                  :edition, 
                  :isbn_10, 
                  :isbn_13, 
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
                  :bn_link

  belongs_to :course

  default_scope order('requirement DESC')

  before_create :clean_isbns

  def query_amazon
    response = amazon_item_search(keywords) # returns an array of 0-20 products
    parse_amazon_response(response)
  end

  def query_bn
    query = BarnesAndNoble::ItemLookup.new(isbn_13)
    assign_attributes(query.parsed_response)
  end

  private

    def clean_isbns
      [isbn_10,isbn_13].each do |isbn|
        isbn.gsub!(/[\W_]/,"") if isbn
      end
    end

    def amazon_item_search(keywords,options={})
      default_options = {:response_group => 'Offers',
                         :search_index => 'Books', 
                         :sort => 'relevancerank',
                         :'ItemSearch.1.Condition'=> 'New', 
                         :'ItemSearch.2.Condition' => 'Used',
                         :'ItemSearch.1.MerchantId'=> 'Amazon', 
                        }
      parameters = default_options.merge(options)

      response = Amazon::Ecs.item_search(keywords,parameters).items
    end

    def parse_amazon_response(response)
      if best_match = response.first
        self.asin               = best_match.get('ASIN')
      end
      
      if new_offer = response.find { |item| item.get('Offers/Offer/OfferAttributes/Condition') == 'New' }
        self.amazon_new_price            = parse_amazon_price(new_offer)
        self.amazon_new_offer_listing_id = parse_amazon_offer_listing_id(new_offer)

      end

      if used_offer = response.find { |item| item.get('Offers/Offer/OfferAttributes/Condition') == 'Used' }
        self.amazon_used_price            = parse_amazon_price(used_offer)
        self.amazon_used_offer_listing_id = parse_amazon_offer_listing_id(used_offer)
      end
      self
    end

    def parse_amazon_price(response)
      price = response.get('Offers/Offer/OfferListing/Price/Amount')
      price.to_d / 100 if price
    end

    def parse_amazon_offer_listing_id(response)
      offer_listing_id = response.get('Offers/Offer/OfferListing/OfferListingId')
    end

    def keywords
      if self.asin
        self.asin
      elsif self.isbn_10
        self.asin = self.isbn_10
      elsif self.isbn_13
        self.isbn_13
      elsif self.title
        build_search_string
      end
    end

  	def build_search_string
  		search_string = self.title
  		search_string += ", #{self.author}" if self.author
  		search_string += ", Edition #{self.edition}" if self.edition
  	end


end
