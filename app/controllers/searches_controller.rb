class SearchesController < ApplicationController

	before_filter :root_redirect, :only => [:new]
	before_filter :https_redirect, :only => [:create]
	before_filter :http_redirect, :only => [:show]

	rescue_from Mecha::AuthenticationError, :with => :error_handling


	def new
		@search = Search.new
	end

	def create
		@search = Search.new
		Mecha::PortlandState.execute(	:username => params[:search][:username], 
																	:password => params[:search][:password],
																	:search 	=> @search)
		if @search.save
			redirect_to search_url(@search, :protocol => "http")
		else
			flash[:error] = @search.errors.full_messages
			redirect_to new_search_url
		end
	end

	def show
		@search = Search.find(params[:id])
	end

	def update
		@search = Search.find(params[:id])
		if params[:vendor] == "amazon"
			Amazon::BooksQuery.new(@search)
			response_format = amazon_response_format
		elsif params[:vendor] == "bn"
			BarnesAndNoble::BooksQuery.new(@search)
			response_format = bn_response_format
		end
			render :json => @search.books.to_json( :only => response_format )
	end


	private

		def amazon_response_format
			[ :id, :asin, :amazon_new_price, :amazon_used_price ]
		end

		def bn_response_format
			[ :id, :ean, :bn_new_price ]
		end

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
