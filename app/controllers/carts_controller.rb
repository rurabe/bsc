class CartsController < ApplicationController

	def create
		# params = {"cart"=> {"books"=>[{"condition" => "used", "ean" => "123..."}], "tag" => "bsc-usc-20"}}
		@query = Amazon::CartQuery.new(params[:cart])
		redirect_to @query.link, :status => 303
	end
end
