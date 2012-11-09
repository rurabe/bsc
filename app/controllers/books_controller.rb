class BooksController < ApplicationController
	def update
		@book = Book.find(params[:id])
		query = BarnesAndNoble::UsedBooks.new(@book.ean)
		@book.update_attributes(query.parsed_response)
		render :json => @book.to_json( :only => [:bn_used_price, :bn_used_ean] )
	end
end
