class BooklistsController < ApplicationController

  before_filter :define_schools
  before_filter :define_booklist,	:only			=> [:show, :update]
  
  http_basic_authenticate_with :name => "admin", :password => "saintmarys", :only => [:index]

  rescue_from StandardError, :with => :error_handling

  caches_page :new

  def new
    @school = @schools.find { |school| school.slug == params[:school] }
  end

  def create
    @school = School.find( params[:school] )
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
    @school = @booklist.school || School.find( params[:school] )
  end

  def index
    @booklists = Booklist.includes(:school).order(:created_at).reverse_order
  end

  private

    def define_booklist
      @booklist = Booklist.where(:slug => params[:id]).includes(:courses,:books,:offers).first
    end

    def define_schools
      @schools = School.all
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
      render 'new'
    end



end
