class AmazonbooksController < ApplicationController
	def update
		@book = Book.find(params[:id])
		@book.query_amazon
		@book.save
		render :update, :layout => false
	end
end
