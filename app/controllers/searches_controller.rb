class SearchesController < ApplicationController

	rescue_from Mecha::AuthenticationError, :with => :error_handling

	def new
		@search = Search.new
	end

	def create
		@search = Search.new
		Mecha::PortlandState.execute(	:username => params[:search][:username], 
																	:password => params[:search][:password],
																	:search => @search)
		if @search.save
			redirect_to search_url(@search)
		else
			flash[:error] = @search.errors.full_messages
			redirect_to new_search_url
		end
	end

	def show
		@search = Search.find(params[:id])
	end

	def destroy

	end

	def error_handling(error)
		flash[:error] = [error.message]
		redirect_to new_search_url
	end


end
