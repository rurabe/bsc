class Booklist < ActiveRecord::Base

  belongs_to :school
  has_many :courses, :dependent => :destroy
  has_many :books, :through => :courses
  has_one :page

  after_create :set_slug

 	extend FriendlyId
 	friendly_id :slug, :use => :slugged

  def get_books(options={})
    m = mecha.new(options)
    build_page(:html => m.courses_page.body)
    link_courses(m.parse)
  end

  def lookup(vendor)
    case vendor
      when "amazon"  then Amazon::ItemLookup.new(eans)
      when "bn"      then BarnesAndNoble::ItemLookup.new(eans)
      when "bn-used" then BarnesAndNoble::UsedBooks.new(eans)
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
      mecha.words
    end

    def mecha
      ("mecha/"+ school.slug).classify.constantize
    end

    def link_courses(course_info)
      course_info.map do |course|
        courses.build(course)
      end
    end

end
