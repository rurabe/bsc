class School < ActiveRecord::Base
  attr_accessible :name,
  								:slug,
  								:primary_color,
  								:secondary_color,
                  :user_id_label,
                  :bookstore_name

 	has_many :booklists
  has_many :snags
  
  extend FriendlyId
 	friendly_id :slug, :use => :slugged

  after_save { School.update_cache }


	# Method used in the as the default for the constraint School.
	# Seeks to limit non-404 requests to only those schools listed below.
 	def self.matches?(request)
 		current_schools.include?(request.params[:school])
 	end

  def self.update_cache
    REDIS.del( :schools_all )
    REDIS.set( :schools_all, Marshal.dump( all ) )
  end

  def self.cached_schools
    d = REDIS.get(:schools_all)
    Marshal.load( d ) if d.present?
  end

  def self.all
    cached_schools || super
  end

 	private

	 	def self.current_schools
	 		['pdx','usc','hawaii','saddleback']
	 	end

end
