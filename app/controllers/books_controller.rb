class BooksController < ApplicationController
	def update
		@book = Book.find(params[:id])
		@book.query_amazon
		@book.save
	end
end
