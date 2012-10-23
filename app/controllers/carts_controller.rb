class CartsController < ApplicationController

	def create
		@search = Search.find(params[:search_id])
		@cart = @search.carts.build(params[:cart])
		@cart.update_item_details
		query = AmazonCartQuery.new(@cart)
		@cart.update_attributes(query.create_cart)
	end
end
