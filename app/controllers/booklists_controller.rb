class BooklistsController < ApplicationController

  before_filter :define_schools
  before_filter :define_school,   :only     => [:new,:create,:show]
  
  http_basic_authenticate_with :name => "admin", :password => "saintmarys", :only => [:index]

  caches_page :new

  def new
    
  end

  def create
    @school = @schools.find { |school| school.slug == params[:school] }
    if params[:booklist][:username] == "test"
      show_example
    else
      @booklist = @school.booklists.build
      @mecha = @booklist.get_books(params[:booklist])
      if @booklist.save
        redirect_to booklist_url(@booklist, :protocol => "http")
      else
        rerender_and_show_error
      end
    end
  rescue => e
    error_handling(e)
  end

  def show
    @booklist = Booklist.where(:slug => params[:id]).includes(:courses,:books,:offers).first
    @school = @schools.find { |school| school.id == @booklist.school_id } || School.find( params[:school] )
  end

  def index
    @booklists = Booklist.includes(:school).order(:created_at).reverse_order
  end

  private

    def define_schools
      @schools = School.all
    end

    def define_school
      @school = @schools.find { |school| school.slug == params[:school] }
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
      if error.is_a? Mecha::UnknownError
        @booklist.save
        @booklist.snags.create(error.data)
      end
      flash[:error] = [error.message]
      render 'new'
    end



end
