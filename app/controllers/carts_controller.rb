class CartsController < ApplicationController

	def create
    @query = query(params[:vendor]).new(params)
    redirect_to @query.link
	end

  private

    def query(vendor)
      mod = vendor.titlecase.gsub(' ','')
      "#{mod}::CartQuery".constantize
    end
end
