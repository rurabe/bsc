class SearchesController < ApplicationController

	before_filter :root_redirect, :only => [:new]
	before_filter :https_redirect, :only => [:create]
	before_filter :http_redirect, :only => [:show]

	rescue_from Mecha::AuthenticationError, :with => :error_handling

	def new
		@search = Search.new
		@school = School.find(params[:school])
	end

	def create
		@school = params[:school]
		case params[:search][:username]
		when "test"
			@search = Search.find("example")
			redirect_to search_url(@search,:protocol => "http")
		else
			@search = Search.new
			Mecha::PortlandState.execute(	:username => params[:search][:username], 
																		:password => params[:search][:password],
																		:search 	=> @search)
			if @search.save
				redirect_to search_url(@search, :protocol => "http", :school => @school)
			else
				flash[:error] = @search.errors.full_messages
				redirect_to new_search_url
			end
		end
	end

	def show
		@school = params[:school]
		@search = Search.find(params[:id])
	end

	def update
		@search = Search.find(params[:id])
		@school = params[:school]
		query = @search.lookup(params[:vendor])
		render :json => query.ui_data.to_json
	end


	private

		# Error handling
		def error_handling(error)
			flash[:error] = [error.message]
			redirect_to new_search_url
		end

		# SSL Redirects
		def root_redirect
			if ENV["ENABLE_HTTPS"] == "yes"
				if !request.ssl?
			    flash.keep
			    redirect_to root_url(protocol: "https"), status: :moved_permanently
		 		end
		 	end
		end

		def https_redirect
			if ENV["ENABLE_HTTPS"] == "yes"
		    if !request.ssl?
		      flash.keep
		      redirect_to protocol: "https", status: :moved_permanently
			  end
			end
		end

		def http_redirect
			if ENV["ENABLE_HTTPS"] == "yes"
		    if request.ssl?
		      flash.keep
		      redirect_to protocol: "http", status: :moved_permanently
			  end
			end
		end

end
