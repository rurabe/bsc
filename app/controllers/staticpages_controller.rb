class StaticpagesController < ApplicationController
  def about
    @school = School.find_by_slug(cookies[:school])
  end
end
