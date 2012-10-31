class CartsController < ApplicationController

	def create
		# params = {"amazon"=>{"new"=>["1604067454", "0781760038"], "used"=>["1428312234", "1604062908"]}, "search_id"=>"EGeq16wUNg"}
		@query = Amazon::CartQuery.new(params[:amazon])
		redirect_to @query.link, :status => 303
	end
end
