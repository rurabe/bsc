class Booklist < ActiveRecord::Base

  belongs_to :school
  has_many :courses
  has_many :books, :through => :courses

  after_create :set_slug

 	extend FriendlyId
 	friendly_id :slug, :use => :slugged

  def get_books(options={})
    shitty_options = options.merge( :booklist => self )
    get_mecha.execute( shitty_options )
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
	  	self.slug = slugger if self.new_record?
	  end

    def slugger
      slug = assemble_slug
      return slug if !Booklist.find_by_slug(slug)
      slugger
    end

    def assemble_slug
      words = school_words.shuffle
      slug = 2.times.inject([]) { |array| array << words.pop }
      slug << rand(1000)
      slug.join("-")
    end

    def school_words
      get_mecha.words
    end

    def get_mecha
      ("mecha/"+ school.slug).classify.constantize
    end




end
