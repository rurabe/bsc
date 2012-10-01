class Book < ActiveRecord::Base
  attr_accessible :author, 
                  :edition, 
                  :isbn_10, 
                  :isbn_13, 
                  :requirement, 
                  :title,
                  :bookstore_new_price,
                  :bookstore_new_rental_price,
                  :bookstore_used_price,
                  :bookstore_used_rental_price

  belongs_to :course

  def amazon_referral_link
  	"https://www.amazon.com/dp/#{self.asin}?tag=booksupply-20"
  end

  def set_asin
  	if self.isbn_10
  		self.asin = self.isbn_10
  	elsif self.isbn_13
  		self.asin = search_amazon(self.isbn_13)
  	elsif self.title
  		self.asin = deduce_asin if deduce_asin
  	end
  end

  private

  	def deduce_asin
  		search_string = self.title
  		search_string += ", #{self.author}" if self.author
  		search_string += ", Edition #{self.edition}" if self.edition
  		search_amazon(search_string)
  	end

  	def search_amazon(keywords)
  		response = Amazon::Ecs.item_search( keywords,
  																			 {:response_group => 'ItemIds',
                                          :search_index => 'Books', 
  																			 	:sort => 'relevancerank'})
  		response.items.first.get('ASIN') if !response.items.empty?
  	end
end
