class StaticpagesController < ApplicationController

  before_filter :define_schools
  before_filter :define_school
  
  def about
    
  end

  def faq

  end

  def team

  end

  def join
    
  end

  def terms
    
  end

  def example
    @booklist = Booklist.find("example")
    @deals = Deal.all
    render 'booklists/show'
  end

  private

    def define_schools
      @schools = School.all
    end

    def define_school
      @school = @schools.find { |school| school.slug == cookies[:school] }
    end
end
