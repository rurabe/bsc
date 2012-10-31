class BooksController < ApplicationController
	def update
		@book = Book.find(params[:id])
		@book.query_amazon
		@book.query_bn
		@book.save
	end
end
