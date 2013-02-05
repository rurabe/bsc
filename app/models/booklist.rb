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

  def offer_data
    merge_offers
  end

  private

    def merge_offers
      all_offer_data = get_offer_data
      eans.map do |ean|
        { :ean               => ean,
          :offers_attributes => consolidate_offers(all_offer_data,ean) }
      end
    end

    def consolidate_offers(all_offer_data,ean)
      select_offers(all_offer_data,ean).flat_map { |offer| offer[:offers_attributes] }
    end

    def select_offers(all_offer_data,ean)
      all_offer_data.select { |offer| offer[:ean] == ean }
    end

    def get_offer_data
      e = eans
      threads = [ lambda{ Amazon::ItemLookup.new(e).parse },
                  lambda{ BarnesAndNoble::ItemLookup.new(e).parse } ]
      Automatron::Needle.thread(threads)
    end
  
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
