class BooksController < ApplicationController
	def show
		@booklist = Booklist.where( :slug => params[:id] ).includes(:books,:offers).first
    render :json => @booklist.get_offers( params[:vendor] )
	end
end
