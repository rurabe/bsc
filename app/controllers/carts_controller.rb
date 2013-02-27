class CartsController < ApplicationController

	def create
    @query = query(params[:vendor]).new(params)
    redirect_to @query.link
	end

  private

    def query(vendor)
      _module = vendor.titlecase.gsub(' ','')
      "#{_module}::CartQuery".constantize
    end
end
