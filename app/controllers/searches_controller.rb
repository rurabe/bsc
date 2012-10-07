class SearchesController < ApplicationController

	before_filter :root_redirect, :only => :new

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
			redirect_to new_search_url(:protocol => "https")
		else
			redirect_to search_url(@search, :protocol => "http")
	end

	def show
		@search = Search.find(params[:id])
	end

	def destroy

	end

	private
	
	def root_redirect
    if !request.ssl?
      protocol = "https"
      flash.keep
      redirect_to root_url(:protocol => "https"), status: :moved_permanently
	  end
	end


end
