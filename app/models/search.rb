class Search < ActiveRecord::Base
  attr_accessible :username, :password

  has_many :courses
  has_many :books, :through => :courses
  has_many :carts

  before_create :set_slug

 	extend FriendlyId
 	friendly_id :slug, :use => :slugged

  def push_book_info
    BookLookupWorker.perform_async(:amazon,id)
    BookLookupWorker.perform_async(:bn,id)
    eans.each { |ean| UsedBnBookLookupWorker.perform_async(ean,id) }
  end

  def lookup(vendor)
    case vendor
      when "amazon" then Amazon::ItemLookup.new(eans)
      when "bn" then BarnesAndNoble::ItemLookup.new(eans)
    end
  end

  private
  
    def eans
      books.pluck(:ean)
    end

	  def set_slug
	  	self.slug = SecureRandom.urlsafe_base64(7)
	  end
end
