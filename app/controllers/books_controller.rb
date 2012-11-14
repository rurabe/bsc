class BooksController < ApplicationController
	def update
		@book = Book.find_by_ean(params[:id])
		query = BarnesAndNoble::UsedBooks.new(@book.ean)
		render :json => query.ui_data.to_json
	end
end
