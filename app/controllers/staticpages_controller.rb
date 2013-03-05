class StaticpagesController < ApplicationController

  before_filter :define_schools
  before_filter :define_school
  
  def about
    
  end

  def faq

  end

  private

    def define_schools
      @schools = School.all
    end

    def define_school
      @school = @schools.find { |school| school.slug == cookies[:school] }
    end
end
