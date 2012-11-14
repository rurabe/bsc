module BarnesAndNoble
	class ItemLookup
		include ApiMethods

		attr_reader :response, :parsed_response

		def initialize(eans)
			@eans = eans
			@default_params = {
				:operation => 'ProductLookup',
				:product_code => 'Book'
			}
			@response = nil
			@parsed_response = {}
			control
		end

		def ui_data
			products = response.xpath('./ProductLookupResponse/ProductLookupResult/Product')
			if products.count == 1
				ui_data_parsers(products)
			else
				products.map { |product| ui_data_parsers(product) }
			end
		end

		private

			def control
				@response = send_request(build_lookup_params)
			end

			def build_lookup_params
				@default_params.merge(:ean => parameterized_eans)
			end

			def parameterized_eans
				if @eans.class == String
					@eans
				elsif @eans.class == Array
					@eans.delete_if { |product| product.nil? }.join(",")
				end
			end

			def ui_data_parsers(product)
					{
						:ean      		=> product.xpath('./Ean').text,
						:price 				=> product.xpath('./Prices/BnPrice').text.to_d,
						:condition 		=> "new",
						:vendor				=> "bn"
					}
			end
	end
end