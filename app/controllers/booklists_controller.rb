class BooklistsController < ApplicationController

  before_filter :https_redirect,  :only 		=> [:new, :create]
  before_filter :http_redirect,   :only 		=> [:show]
  before_filter :define_school,   :only 		=> [:new, :create]
  before_filter :define_booklist,	:only			=> [:show, :update]

  rescue_from StandardError, :with => :error_handling

  def new
  end

  def create
    if params[:booklist][:username] == "test"
      show_example
    else
      @booklist = @school.booklists.build
      @booklist.get_books(params[:booklist])
      if @booklist.save
        redirect_to booklist_url(@booklist, :protocol => "http")
      else
        rerender_and_show_error
      end
    end

  end

  def show
    @school = @booklist.school || School.find(params[:school])
  end

  def update
    query = @booklist.lookup(params[:vendor])
    render :json => query.ui_data
  end

  private

  def define_booklist
    @booklist = Booklist.find(params[:id])
  end

  def define_school
    @school = School.find(params[:school])
  end

  def show_example
    @booklist = Booklist.find("example")
    redirect_to booklist_url(@booklist,:protocol => "http", :school => @school.slug)
  end

  def rerender_and_show_error
    flash[:error] = @booklist.errors.full_messages
    render 'new'
  end

  # Error handling
  def error_handling(error)
    flash[:error] = [error.message]
    pp error
    pp error.backtrace
    render 'new'
  end

  # SSL Redirects

  def https_redirect
    if ENV["ENABLE_HTTPS"] == "yes"
      if !request.ssl?
        flash.keep
        redirect_to( {:protocol => "https", :status => :moved_permanently}.merge(params) )
      end
    end
  end

  def http_redirect
    if ENV["ENABLE_HTTPS"] == "yes"
      if request.ssl?
        flash.keep
        redirect_to( {:protocol => "http", :status => :moved_permanently}.merge(params) )
      end
    end
  end

end
