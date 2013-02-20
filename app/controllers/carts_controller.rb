class CartsController < ApplicationController

	def create
    @query = query(params[:vendor]).new(params)
    render :json => { :link => @query.link }.to_json
	end

  private

    def query(vendor)
      mod = vendor.titlecase.gsub(' ','')
      "#{mod}::CartQuery".constantize
    end
end
