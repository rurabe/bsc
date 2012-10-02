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
                  :amazon_used_price

  belongs_to :course

  default_scope order('requirement DESC')

  def amazon_referral_link
  	"https://www.amazon.com/dp/#{self.asin}?tag=booksupply-20" if asin
  end

  def query_amazon
    response = amazon_item_search(keywords)
    parse_amazon_response(response)
  end

  private

    def amazon_item_search(keywords,options={})
      default_options = {:response_group => 'Offers',
                         :search_index => 'Books', 
                         :sort => 'relevancerank'}
      parameters = default_options.merge(options)

      response = Amazon::Ecs.item_search(keywords,parameters).items
      response.first if response
    end

    def parse_amazon_response(response)
      self.asin = parse_amazon_asin(response)
      self.amazon_new_price = parse_amazon_new_price(response)
    end

    def parse_amazon_asin(response)
      response.get('//ASIN')
    end

    def parse_amazon_new_price(response)
      response.get('//OfferListing/Price/Amount').to_d / 100
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
