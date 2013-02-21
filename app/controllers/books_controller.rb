class BooksController < ApplicationController
	def show
		@book = Book.find_by_ean(params[:id])
		render :json => [{:ean => @book.ean, :offers_attributes => @book.offers.map {|offer| offer } }]
	end
end
