class BooklistsController < ApplicationController

	before_filter :root_redirect, :only => [:new]
	before_filter :https_redirect, :only => [:create]
	before_filter :http_redirect, :only => [:show]

	rescue_from Mecha::AuthenticationError, :with => :error_handling

	def new
		@booklist = Booklist.new
		@school = School.find(params[:school])
	end

	def create
		@school = School.find(params[:school])
		case params[:booklist][:username]
		when "test"
			@booklist = Booklist.find("example")
			redirect_to booklist_url(@booklist,:protocol => "http", :school => @school.slug )
		else
			@booklist = @school.booklists.build
			@booklist.get_books(params[:booklist])
			if @booklist.save
				redirect_to booklist_url(@booklist, :protocol => "http", :school => @school.slug )
			else
				flash[:error] = @booklist.errors.full_messages
				redirect_to new_booklist_url
			end
		end
	end

	def show
		@school = School.find(params[:school])
		@booklist = Booklist.find(params[:id])
	end

	def update
		@booklist = Booklist.find(params[:id])
		query = @booklist.lookup(params[:vendor])
		render :json => query.ui_data.to_json
	end


	private

		def define_school

		end

		# Error handling
		def error_handling(error)
			flash[:error] = [error.message]
			redirect_to new_booklist_url
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
