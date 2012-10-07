class SearchesController < ApplicationController

	def new
		@search = Search.new
	end

	def create
		@search = Search.new
		Mecha::PortlandState.execute(	:username => params[:search][:username], 
																	:password => params[:search][:password],
																	:search => @search)
		@search.save
		rescue 
			redirect_to new_search_url
		else
			redirect_to search_url(@search)
	end

	def show
		@search = Search.find(params[:id])
	end

	def destroy

	end


end
