class School < ActiveRecord::Base
  attr_accessible :name,
  								:slug,
  								:primary_color,
  								:secondary_color,
                  :user_id_label,
                  :bookstore_name

 	has_many :booklists
  
  extend FriendlyId
 	friendly_id :slug, :use => :slugged


	# Method used in the as the default for the constraint School.
	# Seeks to limit non-404 requests to only those schools listed below.
 	def self.matches?(request)
 		current_schools.include?(request.params[:school])
 	end

 	private

	 	def self.current_schools
	 		['pdx','usc','hawaii']
	 	end

end
