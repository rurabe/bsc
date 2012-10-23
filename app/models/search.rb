class Search < ActiveRecord::Base
  attr_accessible :username, :password

  has_many :courses
  has_many :carts

  before_create :set_slug

 	extend FriendlyId
 	friendly_id :slug, :use => :slugged


  def permalink
  	"http://book_supply.dev/searches/" + self.slug
  end

  private  
	  def set_slug
	  	self.slug = SecureRandom.urlsafe_base64(7)
	  end
end
