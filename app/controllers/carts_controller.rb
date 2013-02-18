class CartsController < ApplicationController

	def create
    @query = query(params[:vendor]).new
    p @query
	end

  private

  def query(vendor)
    mod = vendor.titlecase.gsub(' ','')
    "#{mod}::CartQuery".constantize
  end
end
