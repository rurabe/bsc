class SchoolsController < ApplicationController
  before_filter :https_redirect,  :only     => [:index]

  def index
  	@schools = School.all
  end
end
